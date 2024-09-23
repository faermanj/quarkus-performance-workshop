#!/bin/bash
set -x
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=$(basename $DIR)

VERSION=$(cat version.txt)
echo "Building peecs version $VERSION"

echo  "$CONTAINER_TOKEN" | docker login -u "$CONTAINER_USERNAME" --password-stdin
docker build -f peecs/Dockerfile --no-cache --progress=plain -t ${CONTAINER_USERNAME}/peecs:$VERSION peecs
docker push ${CONTAINER_USERNAME}/peecs:$VERSION
