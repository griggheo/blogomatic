#!/bin/bash

helm repo add uptrace https://charts.uptrace.dev
helm repo update uptrace
helm fetch uptrace/uptrace
