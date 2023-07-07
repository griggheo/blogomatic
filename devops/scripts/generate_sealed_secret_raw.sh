#!/bin/bash

PUB_CERT_DESTINATION=/tmp/kubeseal-pub-cert.pem
NAMESPACE=$1
PLAIN_TEXT=$2

# get public certificate
kubeseal --fetch-cert \
--controller-name=sealed-secrets \
--controller-namespace=bitnami > $PUB_CERT_DESTINATION

echo -n $PLAIN_TEXT | tr -d \\n |  kubeseal --raw --cert $PUB_CERT_DESTINATION --from-file=/dev/stdin --namespace $NAMESPACE --scope cluster-wide
