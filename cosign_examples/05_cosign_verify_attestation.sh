#!/bin/bash

COSIGN_PUBLIC_KEY=$HOME/.cosign/cosign.pub
IMAGE=timoniersystems/blogomatic:distroless-multistage-2f07e41

TMPDIR=./tmp
mkdir -p $TMPDIR
ATTESTATION_PAYLOAD=$TMPDIR/attestation_payload.json
SCANNER_PAYLOAD=$TMPDIR/scanner_payload.json

cosign verify-attestation --key $COSIGN_PUBLIC_KEY "$IMAGE" | jq --slurp 'map(.payload | @base64d | fromjson | .predicate.Data | fromjson)' > $ATTESTATION_PAYLOAD

cat $ATTESTATION_PAYLOAD | jq -r '.[0]' > $SCANNER_PAYLOAD

echo Vulnerabilities:
cat $SCANNER_PAYLOAD |jq -r '.'
#cat $SCANNER_PAYLOAD |jq -r '.Vulnerabilities[] | .VulnerabilityID,.Severity'
