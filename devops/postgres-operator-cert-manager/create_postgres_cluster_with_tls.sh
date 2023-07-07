#!/bin/bash

NAMESPACE=postgres-operator

kubectl create ns $NAMESPACE
kubectl apply -k postgres
