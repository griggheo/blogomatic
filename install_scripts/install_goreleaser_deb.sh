#!/bin/bash

VERSION=1.19.1
wget https://github.com/goreleaser/goreleaser/releases/download/v${VERSION}/goreleaser_${VERSION}_amd64.deb
sudo dpkg -i goreleaser_${VERSION}_amd64.deb
rm -rf goreleaser_${VERSION}_amd64.deb

