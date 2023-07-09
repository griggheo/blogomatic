#!/bin/bash

COSIGN_PRIVATE_KEY=$HOME/.cosign/cosign.key
IMAGE=timoniersystems/blogomatic:distroless-multistage-2f07e41
IMAGE=ghcr.io/codepraxis-io/blogomatic:9a4f7786-distroless

echo "y" | COSIGN_PASSWORD=$(cat ~/.k) cosign sign --key $COSIGN_PRIVATE_KEY "$IMAGE"
