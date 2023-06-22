.PHONY: web app

web:
	cd web/blog && npm install && npm run build

app: web
	go build -o bin/blogomatic

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

owasp-depcheck: all
	mkdir -p scan-results/owasp-depcheck; dependency-check.sh -s . \
		--nodePackageSkipDevDependencies --nodeAuditSkipDevDependencies --disableYarnAudit \
		--enableExperimental --disableOssIndex --disableAssembly -o scan-results/owasp-depcheck -f ALL

sonarqube: all coverage
	sonar-scanner -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.token=${SONARQUBE_TOKEN}

go-mod-sbom-cyclonedx:
	mkdir -p sboms
	go mod tidy
	cyclonedx-gomod mod -json -output sboms/go-mod-sbom-cyclonedx.json

go-mod-sbom-spdx:
	mkdir -p sboms
	go mod tidy
	spdx-sbom-generator -f json
	mv bom-go-mod.json sboms/go-mod-sbom-spdx.json

npm-sbom-cyclonedx: web
	mkdir -p sboms
	cyclonedx-npm web/blog/package-lock.json --output-file sboms/npm-sbom-cyclonedx.json

docker-distroless-multistage:
	docker build -t blogomatic:distroless-multistage -f Dockerfile.distroless-multistage .

docker-alpine-multistage:
	docker build -t blogomatic:alpine-multistage -f Dockerfile.alpine-multistage .

docker-alpine-cicd:
	docker build -t blogomatic:alpine-cicd -f ./cicd-docker-images/Dockerfile.alpine ./cicd-docker-images
