#!/bin/bash

COSIGN_PUBLIC_KEY=$HOME/.cosign/cosign.pub
BLOB_TAG=d79b49c3
BLOB=ghcr.io/codepraxis-io/blogomatic-debian-bullseye-bin:${BLOB_TAG}

cosign verify --key $COSIGN_PUBLIC_KEY "$BLOB"

### Triangulation

# show signature artifact
cosign triangulate $BLOB

# show signature manifest
crane manifest $(cosign triangulate $IMAGE) | jq .
