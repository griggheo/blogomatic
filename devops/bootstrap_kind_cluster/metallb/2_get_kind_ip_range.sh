#!/bin/bash

docker network inspect -f '{{.IPAM.Config}}' kind
