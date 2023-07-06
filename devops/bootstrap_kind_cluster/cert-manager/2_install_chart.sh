#!/bin/bash

NAMESPACE=cert-manager
CHART_DIR=cert-manager

helm install \
  cert-manager ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace \
  --set installCRDs=true
