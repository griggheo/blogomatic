#!/bin/bash

# Install go 1.20
VERSION=1.20.5
wget https://go.dev/dl/go${VERSION}.linux-amd64.tar.gz
tar xvfz go${VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local
rm -rf go${VERSION}.linux-amd64.tar.gz
echo Make sure you set PATH=/usr/local/go/bin:$PATH

# Install node 18.x / npm 9.x
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
rm nodesource_setup.sh 
sudo apt-get install -y nodejs
npm version

# Install jre for openjdk17
sudo apt install openjdk-17-jre-headless
