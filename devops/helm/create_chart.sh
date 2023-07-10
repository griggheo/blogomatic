#!/bin/bash

CHART_NAME=blogomatic
MANIFEST_FILE=kustomize-alpine-overlay.yaml

cat ${MANIFEST_FILE} | helmify ${CHART_NAME}
