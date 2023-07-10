#!/bin/bash

NAMESPACE=signoz
CHART_DIR=signoz

helm upgrade -i \
  signoz ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace 
