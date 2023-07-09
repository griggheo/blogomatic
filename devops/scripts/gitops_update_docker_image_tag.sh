#!/bin/bash


pushd "$KUSTOMIZE_OVERLAY_PATH" || exit 1

#Update docker tag in kustomization.yaml
DOCKER_IMAGE_WITH_REGISTRY=$DESTINATION_REGISTRY/$DOCKER_IMAGE_NAME
echo "Updating kustomize overlay $KUSTOMIZE_OVERLAY_PATH with tag $IMAGE_TAG for image $DOCKER_IMAGE_WITH_REGISTRY"
kustomize edit set image $DOCKER_IMAGE_WITH_REGISTRY=$DOCKER_IMAGE_WITH_REGISTRY:$IMAGE_TAG

# git config --global user.email "$GITHUB_USERNAME"
# git config --global user.name "$GITHUB_USERNAME"
# echo "${GITHUB_TOKEN}" > "${GITHUB_TOKEN_PATH}"
# gh auth login --hostname "${GIT_HOSTNAME}" --with-token < "${GITHUB_TOKEN_PATH}" || exit 1


git add kustomization.yaml
git commit -m "Updating kustomize overlay $KUSTOMIZE_OVERLAY_PATH with tag $IMAGE_TAG for image $DOCKER_IMAGE_WITH_REGISTRY"

MAX_RETRIES=10
WAIT_TIME=30

# Pull latest changes from main branch
git pull --rebase origin main

# Initialize counter for retries
retries=0

while [ $retries -lt $MAX_RETRIES ]; do
    # Push changes to main branch
    git push origin main
    
    # Check exit status of git push
    if [ $? -eq 0 ]; then
        echo "Push successful, exiting loop."
        break
    else
        echo "Push failed, retrying in ${WAIT_TIME} seconds..."
        retries=$((retries+1))
        sleep ${WAIT_TIME}
    fi
done

# If loop exited after max retries
if [ $retries -eq $MAX_RETRIES ]; then
    echo "Maximum retries (${MAX_RETRIES}) reached. Exiting script."
    exit 1
fi

popd || exit 1
