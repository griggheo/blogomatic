#!/bin/bash

DOCKER_REGISTRY=https://ghcr.io
DOCKER_REGISTRY=https://docker.io
DOCKER_USERNAME=$1
DOCKER_PASSWORD=$2
NAMESPACE=$3

kubectl create secret docker-registry regcred --namespace $NAMESPACE --docker-server=$DOCKER_REGISTRY \
  --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD

