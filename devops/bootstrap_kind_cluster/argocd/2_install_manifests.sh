#!/bin/bash

NAMESPACE=argocd
kubectl create namespace $NAMESPACE
kubectl apply -n $NAMESPACE -f install.yaml

