#!/bin/bash

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm fetch jetstack/cert-manager
