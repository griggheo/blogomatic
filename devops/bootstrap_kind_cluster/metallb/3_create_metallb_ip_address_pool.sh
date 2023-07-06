#!/bin/bash

# first run 2_get_kind_ip_range.sh and note the CIDR: e.g. 172.18.0.0/16
# make sure you have the address range in metallb-ip-address-pool.yaml in this CIDR

kubectl apply -f metallb-ip-address-pool.yaml
