#!/bin/bash

KO_VERSION=0.14.1
PACK_VERSION=0.29.0

# install ko
mkdir -p tmpko; cd tmpko
wget https://github.com/ko-build/ko/releases/download/v${KO_VERSION}/ko_${KO_VERSION}_Linux_x86_64.tar.gz
tar xfz ko_${KO_VERSION}_Linux_x86_64.tar.gz
sudo mv ko /usr/local/bin/
cd ..; rm -rf tmpko

# install paketo pack
wget https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz
tar xvfz pack-v${PACK_VERSION}-linux.tgz
rm -rf pack-v${PACK_VERSION}-linux.tgz
sudo mv pack /usr/local/bin

# install jq
sudo apt -y install jq
