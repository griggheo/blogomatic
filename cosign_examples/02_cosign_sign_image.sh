#!/bin/bash

COSIGN_PRIVATE_KEY=$HOME/.cosign/cosign.key
IMAGE=timoniersystems/blogomatic:distroless-multistage-2f07e41

echo 'y' | COSIGN_PASSWORD=$(cat ~/.k) cosign sign --key $COSIGN_PRIVATE_KEY "$IMAGE"
