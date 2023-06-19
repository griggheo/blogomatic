.PHONY: web app

web:
	cd web/blog && npm install && npm run build

app: web
	go build -o bin/blogomatic

clean:
	rm -rf bin
	cd web/blog && rm -rf build node_modules

run: app
	./bin/blogomatic

test:
	go test -v ./...

coverage:
	go test --cover  ./... -coverprofile=coverage.out
	gocov convert coverage.out | gocov-xml > coverage.xml

owasp-depcheck: all
	mkdir -p owasp-scan-results; dependency-check.sh -s . --nodePackageSkipDevDependencies --nodeAuditSkipDevDependencies --disableYarnAudit \
		--enableExperimental --disableOssIndex --disableAssembly -o owasp-scan-results -f ALL

sonarqube: all coverage
	sonar-scanner -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.token=${SONARQUBE_TOKEN}

all: clean app
