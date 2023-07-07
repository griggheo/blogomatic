#!/bin/bash


NAMESPACE=postgres-operator
POD_NAME=$(kubectl get pods -l postgres-operator.crunchydata.com/role=master -o jsonpath='{.items[0].metadata.name}' -n postgres-operator)

kubectl exec -it $POD_NAME -n $NAMESPACE -- bash
