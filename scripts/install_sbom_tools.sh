#!/bin/bash

# Install cyclonedx golang sbom tool
go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@latest

# Install cyclonedx npm sbom tool
sudo npm install --global @cyclonedx/cyclonedx-npm

# Install spdx sbom tool
VERSION=0.0.15
wget https://github.com/opensbom-generator/spdx-sbom-generator/releases/download/v${VERSION}/spdx-sbom-generator-v${VERSION}-linux-amd64.tar.gz
tar xvfz spdx-sbom-generator-v${VERSION}-linux-amd64.tar.gz
rm -rf spdx-sbom-generator-v${VERSION}-linux-amd64.tar.gz
sudo mv spdx-sbom-generator /usr/local/bin


