#!/bin/bash

RELEASE_NAME=blogomatic
NAMESPACE=alpine-helm
CHART_DIR=blogomatic
VALUES=values_alpine.yaml

helm upgrade -i \
  ${RELEASE_NAME} ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace \
  -f ${CHART_DIR}/$VALUES
