#!/bin/bash

NAMESPACE=alpine
kubectl create secret generic cosign-pub-key \
    --from-file=cosign.pub=/home/ubuntu/.cosign/cosign.pub \
    --namespace $NAMESPACE
