#!/bin/bash
set -x

SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=$(basename $DIR)

VERSION=$(cat version.txt)
echo "Building peecs version $VERSION"

echo  "$REGISTRY_TOKEN" | docker login -u "$REGISTRY_USERNAME" --password-stdin
docker build -f peecs/Dockerfile --no-cache --progress=plain -t ${REGISTRY_USERNAME}/peecs:$VERSION peecs
docker push ${REGISTRY_USERNAME}/peecs:$VERSION
