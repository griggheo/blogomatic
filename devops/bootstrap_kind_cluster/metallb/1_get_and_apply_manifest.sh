#!/bin/bash

VERSION=0.13.7
MANIFEST=metallb-native.yaml

rm -rf $MANIFEST
wget https://raw.githubusercontent.com/metallb/metallb/v${VERSION}/config/manifests/metallb-native.yaml
kubectl apply -f $MANIFEST
