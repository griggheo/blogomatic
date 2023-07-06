VERSION=$(shell git describe --tags --always)
COMMIT=$(shell git rev-parse HEAD)
BUILD=$(shell date +%FT%T%z)

CONTAINER ?= docker
CPUTYPE=$(shell uname -m | sed 's/x86_64/amd64/')
GITHUB_REPOSITORY ?= codepraxis-io/blogomatic
LOCAL_IMAGE_NAME ?= blogomatic-local

.PHONY: web app

web:
	cd web/blog && npm install && npm run build

app: web
	go mod tidy
	go build -buildvcs=false -o bin/blogomatic

clean:
	rm -rf bin
	cd web/blog && rm -rf build node_modules

all: clean app

run: app
	./bin/blogomatic

test:
	go test -v ./...

coverage:
	go test --cover  ./... -coverprofile=coverage.out
	gocov convert coverage.out | gocov-xml > coverage.xml


# build bins for goos/goarch of current host
goreleaser_build_bins:
	goreleaser build --clean --snapshot --single-target

goreleaser_build_local_container: GORELEASER_CURRENT_TAG ?= v0.0.0-$(LOCAL_IMAGE_NAME)
goreleaser_build_local_container:
	GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	GORELEASER_CURRENT_TAG=$(GORELEASER_CURRENT_TAG) \
	DOCKER_CONTEXT=$(shell docker context show) \
	goreleaser release --clean --snapshot --skip-sign --skip-sbom

owasp-depcheck: all
	mkdir -p scan-results/owasp-depcheck
	dependency-check.sh -s . \
		--nodePackageSkipDevDependencies --nodeAuditSkipDevDependencies --disableYarnAudit \
		--enableExperimental --disableOssIndex --disableAssembly -o scan-results/owasp-depcheck -f ALL

sonarqube: all coverage
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

docker-build-distroless-multistage:
	docker build -t blogomatic:distroless-multistage -f Dockerfile.distroless-multistage .

docker-tag-push-distroless-multistage: docker-build-distroless-multistage
	# assumes we already ran `docker login`
	docker tag blogomatic:distroless-multistage timoniersystems/blogomatic:distroless-multistage
	docker push timoniersystems/blogomatic:distroless-multistage

docker-alpine-multistage:
	docker build -t blogomatic:alpine-multistage -f Dockerfile.alpine-multistage .

docker-alpine-cicd:
	docker build -t blogomatic:alpine-cicd -f Dockerfile.alpine-cicd .

build-using-docker-alpine-cicd:
	docker run --rm -it -v `pwd`:/tmp/code blogomatic:alpine-cicd bash -c 'cd /tmp/code; make all; chown -R 1000:1000 .'
	docker build -t blogomatic:alpine -f Dockerfile.alpine-insert-binary .

