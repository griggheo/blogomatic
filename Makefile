VERSION=$(shell git describe --tags --always)
COMMIT=$(shell git rev-parse HEAD)
COMMIT_SHORT=$(shell git rev-parse --short HEAD)
BUILD=$(shell date +%FT%T%z)

CONTAINER ?= docker
DOCKERFILE ?= Dockerfile.distroless
CPUTYPE=$(shell uname -m | sed 's/x86_64/amd64/')
GITHUB_REPOSITORY ?= codepraxis-io/blogomatic
LOCAL_IMAGE_NAME ?= blogomatic-local

SONARQUBE_URL ?= https://sonarqube.timonier.cloud
SONARQUBE_TOKEN=$(shell cat ~/.sq)

COSIGN_PRIVATE_KEY=~/.cosign/cosign.key

.PHONY: web app

web:
	cd web/blog && npm install && npm run build

app: web
	go mod tidy
	go build -buildvcs=false -o bin/blogomatic

clean:
	rm -rf bin
	cd web/blog && rm -rf build node_modules

fmt: 
	go fmt
	cd post; go fmt; cd -
	cd db; go fmt; cd -

all: clean app


run: app
	./bin/blogomatic

test:
	go test -v ./...

coverage:
	go test --cover  ./... -coverprofile=coverage.out
	gocov convert coverage.out | gocov-xml > coverage.xml

gotestsum:
	gotestsum --format testname
	gotestsum --jsonfile tmp.json.log \
	--post-run-command "bash -c 'echo; echo Slowest tests;gotestsum tool slowest --num 10 --jsonfile tmp.json.log'"
	rm -rf tmp.json.log

# build bins for goos/goarch of current host
goreleaser_build_bins:
	goreleaser build --clean --snapshot --single-target

goreleaser_build_local_container: GORELEASER_CURRENT_TAG ?= v0.0.0-$(LOCAL_IMAGE_NAME)
goreleaser_build_local_container:
	GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	GORELEASER_CURRENT_TAG=$(GORELEASER_CURRENT_TAG) \
	DOCKER_CONTEXT=$(shell docker context show) \
	goreleaser release --clean --snapshot --skip-sign
	# docker run --rm -p 8080:8080 -e DB_NAME='/data/blogomatic.db' -v `pwd`/data:/data blogomatic:goreleaser

govulncheck:
	govulncheck ./...

semgrep:
	semgrep scan --config auto

owasp-depcheck: all
	mkdir -p scan-results/owasp-depcheck
	dependency-check.sh -s . \
		--nodePackageSkipDevDependencies --nodeAuditSkipDevDependencies --disableYarnAudit \
		--enableExperimental --disableOssIndex --disableAssembly -o scan-results/owasp-depcheck -f ALL

#sonarqube: all coverage owasp-depcheck
sonarqube: 
	sonar-scanner -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.token=${SONARQUBE_TOKEN}

go-mod-sbom-cyclonedx:
	mkdir -p sboms
	make app
	cyclonedx-gomod mod -json -output sboms/go-mod-sbom-cyclonedx.json

go-mod-sbom-spdx:
	mkdir -p sboms
	make app
	spdx-sbom-generator -f json
	mv bom-go-mod.json sboms/go-mod-sbom-spdx.json

go-mod-sboms: go-mod-sbom-cyclonedx go-mod-sbom-spdx

npm-sbom-cyclonedx: web
	mkdir -p sboms
	make web
	cyclonedx-npm web/blog/package-lock.json --output-file sboms/npm-sbom-cyclonedx.json

npm-sboms: npm-sbom-cyclonedx

sbom-syft-json:
	mkdir -p sboms
	make all
	syft packages dir:. -o syft-json --file sboms/sbom-syft.json

sbom-syft-cyclonedx:
	mkdir -p sboms
	make all
	syft packages dir:. -o cyclonedx-json --file sboms/sbom-syft-cyclonedx.json

sbom-syft-spdx:
	mkdir -p sboms
	make all
	syft packages dir:. -o spdx-json --file sboms/sbom-syft-spdx.json

sbom-syft: sbom-syft-json sbom-syft-cyclonedx sbom-syft-spdx

code-sbom-cyclonedx: go-mod-sbom-cyclonedx npm-sbom-cyclonedx

cyclonedx-merge-code-sboms-and-scan: go-mod-sbom-cyclonedx npm-sbom-cyclonedx
	mkdir -p scan-results/trivy
	cyclonedx merge --input-files sboms/go-mod-sbom-cyclonedx.json sboms/npm-sbom-cyclonedx.json  --output-file sboms/code-cyclonedx.json
	trivy sbom sboms/code-cyclonedx.json
	trivy sbom sboms/code-cyclonedx.json -f json -o scan-results/trivy/trivy-scan-code-sbom-cyclonedx.json

trivy-scan-go-mod-sbom-cyclonedx:
	mkdir -p scan-results/trivy
	trivy sbom sboms/go-mod-sbom-cyclonedx.json -f json -o scan-results/trivy/trivy-scan-go-mod-sbom-cyclonedx.json
	trivy sbom sboms/go-mod-sbom-cyclonedx.json -f sarif -o scan-results/trivy/trivy-scan-go-mod-sbom-cyclonedx.sarif

trivy-scan-go-mod-sbom-spdx:
	mkdir -p scan-results/trivy
	trivy sbom sboms/go-mod-sbom-spdx.json -f json -o scan-results/trivy/trivy-scan-go-mod-sbom-spdx.json
	trivy sbom sboms/go-mod-sbom-spdx.json -f sarif -o scan-results/trivy/trivy-scan-go-mod-sbom-spdx.sarif

trivy-scan-npm-sbom-cyclonedx:
	mkdir -p scan-results/trivy
	trivy sbom sboms/npm-sbom-cyclonedx.json -f json -o scan-results/trivy/trivy-scan-npm-sbom-cyclonedx.json
	trivy sbom sboms/npm-sbom-cyclonedx.json -f sarif -o scan-results/trivy/trivy-scan-npm-sbom-cyclonedx.sarif

trivy-scan-code-sboms: trivy-scan-go-mod-sbom-cyclonedx trivy-scan-go-mod-sbom-spdx trivy-scan-npm-sbom-cyclonedx

grype-scan-go-mod-sbom-cyclonedx:
	mkdir -p scan-results/grype
	grype sbom:sboms/go-mod-sbom-cyclonedx.json -o json --file scan-results/grype/grype-scan-go-mod-sbom-cyclonedx.json
	grype sbom:sboms/go-mod-sbom-cyclonedx.json -o sarif --file scan-results/grype/grype-scan-go-mod-sbom-cyclonedx.sarif

grype-scan-go-mod-sbom-spdx:
	mkdir -p scan-results/grype
	grype sbom:sboms/go-mod-sbom-spdx.json -o json --file scan-results/grype/grype-scan-go-mod-sbom-spdx.json
	grype sbom:sboms/go-mod-sbom-spdx.json -o sarif --file scan-results/grype/grype-scan-go-mod-sbom-spdx.sarif

grype-scan-npm-sbom-cyclonedx:
	mkdir -p scan-results/grype
	grype sbom:sboms/npm-sbom-cyclonedx.json -o json --file scan-results/grype/grype-scan-npm-sbom-cyclonedx.json
	grype sbom:sboms/npm-sbom-cyclonedx.json -o sarif --file scan-results/grype/grype-scan-npm-sbom-cyclonedx.sarif

grype-scan-sbom-syft:
	mkdir -p scan-results/grype
	grype sbom:sboms/sbom-syft.json -o json --file scan-results/grype/grype-scan-sbom-syft.json
	grype sbom:sboms/sbom-syft.json -o sarif --file scan-results/grype/grype-scan-sbom-syft.sarif

grype-scan-sbom-syft-cyclonedx:
	mkdir -p scan-results/grype
	grype sbom:sboms/sbom-syft-cyclonedx.json -o json --file scan-results/grype/grype-scan-sbom-syft-cyclonedx.json
	grype sbom:sboms/sbom-syft-cyclonedx.json -o sarif --file scan-results/grype/grype-scan-sbom-syft-cyclonedx.sarif

grype-scan-sbom-syft-spdx:
	mkdir -p scan-results/grype
	grype sbom:sboms/sbom-syft-spdx.json -o json --file scan-results/grype/grype-scan-sbom-syft-spdx.json
	grype sbom:sboms/sbom-syft-spdx.json -o sarif --file scan-results/grype/grype-scan-sbom-syft-spdx.sarif

grype-scan-code-sboms: grype-scan-go-mod-sbom-cyclonedx grype-scan-go-mod-sbom-spdx grype-scan-npm-sbom-cyclonedx grype-scan-sbom-syft grype-scan-sbom-syft-cyclonedx grype-scan-sbom-syft-spdx

hadolint:
	hadolint ${DOCKERFILE}

docker-workflow-distroless-multistage:
	mkdir -p sboms
	# assumes we already ran `docker login`
	docker buildx build -t blogomatic:distroless-multistage-${COMMIT_SHORT} -f Dockerfile.distroless-multistage .
	docker tag blogomatic:distroless-multistage-${COMMIT_SHORT} timoniersystems/blogomatic:distroless-multistage-${COMMIT_SHORT}
	docker push timoniersystems/blogomatic:distroless-multistage-${COMMIT_SHORT}
	echo 'y' | COSIGN_PASSWORD=$(shell cat ~/.k) cosign sign --key ${COSIGN_PRIVATE_KEY} timoniersystems/blogomatic:distroless-multistage-${COMMIT_SHORT}
	trivy image --format cyclonedx timoniersystems/blogomatic:distroless-multistage-${COMMIT_SHORT} -o sboms/trivy-docker-distroless-multistage-sbom-cyclonedx.json

docker-workflow-alpine-multistage:
	# assumes we already ran `docker login`
	docker buildx build -t blogomatic:alpine-multistage-${COMMIT_SHORT} -f Dockerfile.alpine-multistage .
	docker tag blogomatic:alpine-multistage-${COMMIT_SHORT} timoniersystems/blogomatic:alpine-multistage-${COMMIT_SHORT}
	docker push timoniersystems/blogomatic:alpine-multistage-${COMMIT_SHORT}
	echo 'y' | COSIGN_PASSWORD=$(shell cat ~/.k) cosign sign --key ${COSIGN_PRIVATE_KEY} timoniersystems/blogomatic:alpine-multistage-${COMMIT_SHORT}
	trivy image --format cyclonedx timoniersystems/blogomatic:alpine-multistage-${COMMIT_SHORT} -o sboms/trivy-docker-alpine-multistage-sbom-cyclonedx.json

docker-build-alpine-cicd:
	docker buildx build -t blogomatic:alpine-cicd -f ./devops/cicd-images/Dockerfile.alpine-cicd ./devops/cicd-images

docker-workflow-using-alpine-cicd: docker-build-alpine-cicd
	docker run --rm -it -v `pwd`:/tmp/code blogomatic:alpine-cicd bash -c 'cd /tmp/code; make all; chown -R 1000:1000 .'
	docker buildx build -t blogomatic:alpine-${COMMIT_SHORT} -f Dockerfile.alpine-insert-binary .
	docker tag blogomatic:alpine-${COMMIT_SHORT} timoniersystems/blogomatic:alpine-${COMMIT_SHORT}
	docker push timoniersystems/blogomatic:alpine-${COMMIT_SHORT}
	echo 'y' | COSIGN_PASSWORD=$(shell cat ~/.k) cosign sign --key ${COSIGN_PRIVATE_KEY} timoniersystems/blogomatic:alpine-${COMMIT_SHORT}
	trivy image --format cyclonedx timoniersystems/blogomatic:alpine-${COMMIT_SHORT} -o sboms/trivy-docker-alpine-sbom-cyclonedx.json

docker-workflow-paketo:
	pack build blogomatic-paketo --buildpack paketo-buildpacks/go --builder paketobuildpacks/builder-jammy-base
	docker tag blogomatic-paketo timoniersystems/blogomatic:paketo-${COMMIT_SHORT}
	docker push timoniersystems/blogomatic:paketo-${COMMIT_SHORT}
	trivy image --format cyclonedx timoniersystems/blogomatic:paketo-${COMMIT_SHORT} -o sboms/trivy-docker-paketo-sbom-cyclonedx.json
	trivy sbom sboms/trivy-docker-paketo-sbom-cyclonedx.json

full-workflow-local: DOCKERFILE=Dockerfile.local
full-workflow-local: REGISTRY=timoniersystems
full-workflow-local: IMAGE_NAME=blogomatic:local
#full-workflow-local: all govulncheck semgrep owasp-depcheck sonarqube code-sbom-cyclonedx hadolint
full-workflow-local: hadolint
	docker buildx build -t ${IMAGE_NAME}-${COMMIT_SHORT} -f ${DOCKERFILE} .
	docker tag ${IMAGE_NAME}-${COMMIT_SHORT} ${REGISTRY}/${IMAGE_NAME}-${COMMIT_SHORT}
	docker push ${REGISTRY}/${IMAGE_NAME}-${COMMIT_SHORT}
	trivy image ${REGISTRY}/${IMAGE_NAME}-${COMMIT_SHORT} --format cyclonedx -o sboms/trivy-docker-local-sbom-cyclonedx.json
	syft packages blogomatic:local-1b5f36c -o cyclonedx-json  > sboms/syft-docker-local-sbom-cyclonedx.json
	cyclonedx merge --input-files sboms/go-mod-sbom-cyclonedx.json sboms/npm-sbom-cyclonedx.json sboms/syft-docker-local-sbom-cyclonedx.json --output-file sboms/all-cyclonedx.json
	trivy sbom sboms/all-cyclonedx.json
	trivy sbom sboms/trivy-docker-local-sbom-cyclonedx.json
