#!/bin/bash

NAMESPACE=bitnami
CHART_DIR=sealed-secrets

helm install \
  sealed-secrets ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace
