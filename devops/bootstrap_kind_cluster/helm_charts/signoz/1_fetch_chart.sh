#!/bin/bash

helm repo add signoz https://charts.signoz.io
helm repo update
helm fetch signoz/signoz
