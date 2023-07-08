#!/bin/bash

COSIGN_PRIVATE_KEY=$HOME/.cosign/cosign.key
IMAGE=timoniersystems/blogomatic:distroless-multistage-2f07e41
SCAN_RESULT_FILE=../scan-results/trivy/trivy-scan-code-sbom-cyclonedx.json

echo 'y' | COSIGN_PASSWORD=$(cat ~/.k) cosign attest --predicate $SCAN_RESULT_FILE --key $COSIGN_PRIVATE_KEY "$IMAGE"

#crane manifest ghcr.io/codepraxis-io/spring-music:sha256-acb13064190c9264c12838dacc4cae13d73e31d6f596e101f091b760c02d71fe.att | jq
