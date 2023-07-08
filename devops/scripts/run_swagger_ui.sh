#!/bin/bash

docker run -p 8080:8080 -e SWAGGER_JSON=/tmp/swagger.json -v `pwd`:/tmp swaggerapi/swagger-ui
