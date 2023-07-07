#!/bin/bash

NAMESPACE=pgo
helm upgrade -i pgo --create-namespace -n $NAMESPACE  ./postgres-operator-examples/helm/install \
    -f ./postgres-operator-examples/helm/install/values.yaml

