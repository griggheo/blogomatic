#!/bin/bash

COSIGN_PUBLIC_KEY=$HOME/.cosign/cosign.pub
BLOB=ghcr.io/codepraxis-io/blogomatic-debian-bullseye-bin:bb076a5c

cosign verify --key $COSIGN_PUBLIC_KEY "$BLOB"

### Triangulation

# show signature artifact
cosign triangulate $BLOB

# show signature manifest
crane manifest $(cosign triangulate $IMAGE) | jq .
