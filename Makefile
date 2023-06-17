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

sonarqube: coverage
	sonar-scanner -Dsonar.host.url=${SONARQUBE_URL} -Dsonar.token=${SONARQUBE_TOKEN}

all: clean app
