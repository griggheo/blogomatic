#!/bin/bash

NAMESPACE=uptrace
CHART_DIR=uptrace

helm upgrade -i \
  uptrace ${CHART_DIR} \
  --namespace $NAMESPACE \
  --create-namespace 
