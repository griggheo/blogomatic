#!/bin/bash

COSIGN_PUBLIC_KEY=$HOME/.cosign/cosign.pub
IMAGE=timoniersystems/blogomatic:distroless-multistage-2f07e41
IMAGE=ghcr.io/codepraxis-io/blogomatic:9a4f7786-distroless

cosign verify --key $COSIGN_PUBLIC_KEY "$IMAGE"

### Triangulation

# show signature artifact
cosign triangulate $IMAGE

# show signature manifest
crane manifest $(cosign triangulate $IMAGE) | jq .
