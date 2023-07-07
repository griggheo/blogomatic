#!/bin/bash

# assume AWS_SECRET_ACCESS_KEY was exported in the current shell
echo ${AWS_SECRET_ACCESS_KEY} > aws-secret-key
kubectl create secret generic aws-route53-creds --from-file=aws-secret-key -n cert-manager
rm -rf aws-secret-key
