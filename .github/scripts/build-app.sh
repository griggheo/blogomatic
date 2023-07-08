#!/bin/bash

# install node and npm
pushd /tmp
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh \
	&& bash nodesource_setup.sh \
	&& rm nodesource_setup.sh \
	&& apt-get install -y nodejs --no-install-recommends
popd

make all