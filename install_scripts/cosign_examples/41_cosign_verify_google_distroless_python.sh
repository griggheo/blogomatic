#!/bin/bash

GOOGLE_COSIGN_PUB_KEY=google_cosign.pub
rm -rf cosign.pub
wget https://raw.githubusercontent.com/GoogleContainerTools/distroless/main/cosign.pub
mv cosign.pub $GOOGLE_COSIGN_PUB_KEY

GOOGLE_DISTROLESS_IMAGES='
gcr.io/distroless/python3-debian11'

TAGS='
latest
nonroot
debug
debug-nonroot'

for IMAGE in $GOOGLE_DISTROLESS_IMAGES; do
	for TAG in $TAGS; do
		docker pull $IMAGE:$TAG
		echo Verifying $IMAGE:$TAG
		cosign verify --key $GOOGLE_COSIGN_PUB_KEY $IMAGE:$TAG
		#/usr/local/bin/cosign-1.13.1 verify --key $GOOGLE_COSIGN_PUB_KEY $IMAGE:$TAG
		echo
	done
done

# found an issue!
#Verifying gcr.io/distroless/python3-debian11:debug
#Error: no matching signatures:
#
#main.go:62: error during command execution: no matching signatures:
