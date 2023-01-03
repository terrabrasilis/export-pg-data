#!/bin/bash

VERSION=$(git describe --tags --abbrev=0)
export VERSION

# build all images
docker build -t terrabrasilis/export-pg-data:$VERSION -f Dockerfile ./src

# send to dockerhub
echo "The building was finished! Do you want sending this new image to Docker HUB? Type yes to continue." ; read SEND_TO_HUB
if [[ ! "$SEND_TO_HUB" = "yes" ]]; then
    echo "Ok, not send the image."
else
    echo "Nice, sending the image!"
    docker push terrabrasilis/export-pg-data:$VERSION
fi