#!/bin/bash

NAMESPACE=kyverno
CHART_DIR=kyverno

helm upgrade -i \
  kyverno ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace 
