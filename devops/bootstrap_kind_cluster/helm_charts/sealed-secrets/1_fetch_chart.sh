#!/bin/bash

helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm fetch sealed-secrets/sealed-secrets
