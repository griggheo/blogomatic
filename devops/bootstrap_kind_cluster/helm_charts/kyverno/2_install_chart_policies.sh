#!/bin/bash

NAMESPACE=kyverno
CHART_DIR=kyverno-policies

helm upgrade -i \
  kyverno-policies ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace 
