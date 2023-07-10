#!/bin/bash

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno
helm fetch kyverno/kyverno
helm fetch kyverno/kyverno-policies
