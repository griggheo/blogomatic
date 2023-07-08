#!/bin/bash

PROJECT_NAME=$1

PROJECT_VERSION=0.0.1
DEPTRACK_URL="https://deptrack.timonier.cloud"
API_KEY=$(cat ~/.dt)

curl -vv -X PUT \
    -H "Content-Type: application/json" \
    -H "X-Api-Key: ${API_KEY}" \
    -d "{\"name\": \"${PROJECT_NAME}\", \"version\": \"${PROJECT_VERSION}\"}" \
    ${DEPTRACK_URL}/api/v1/project
