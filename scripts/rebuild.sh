#!/bin/bash
set -x
SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=$(basename $DIR)

VERSION=$(cat version.txt)
echo "Building peecs version $VERSION"

echo  "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker build -f peecs/Dockerfile --no-cache --progress=plain -t ${DOCKER_USERNAME}/peecs:$VERSION peecs
docker push ${DOCKER_USERNAME}/peecs:$VERSION
