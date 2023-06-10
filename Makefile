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

all: clean app
