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

# Install MS sbom tool
curl -Lo sbom-tool https://github.com/microsoft/sbom-tool/releases/latest/download/sbom-tool-linux-x64
chmod +x sbom-tool
sudo mv sbom-tool /usr/local/bin/
# running the sbom-tool#
# sbom-tool generate -b ./ms-sbom -bc path/to/sourcecode -pn flask-bootstrap -pv 0.0.1 -ps codepraxis -nsb https://codepraxis.io

# Install SBOM scorecard
curl -Lo sbom-scorecard https://github.com/eBay/sbom-scorecard/releases/download/0.0.6/sbom-scorecard-linux-amd64
chmod +x sbom-scorecard
sudo mv sbom-scorecard /usr/local/bin/

