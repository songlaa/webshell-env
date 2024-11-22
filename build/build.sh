#!/bin/bash

export ORG="songlaa"
export APP="theia"

cleanup() {
    echo -e "\nCleanup:\n"
    docker stop $APP
    docker container prune --force
    docker image prune --force
}

trap cleanup EXIT
trap cleanup SIGTERM

build() {
    echo -e "\nBuild:\n"
    set -e
    if [ -n "$(which docker)" ]; then
        docker build --progress=plain -t $ORG/$APP .
        test_image
        docker push $ORG/$APP
    elif [ -n "$(which buildah)" ]; then
        sudo buildah bud -t docker.io/$ORG/$APP .
        sudo buildah push docker.io/$ORG/$APP
    fi
}

test_image() {
    echo -e "\nTest:\n"
    set -e
    docker run -d --rm -p 3000:3000 --name $APP $ORG/$APP
    docker images | grep $APP
    sleep 15

    curl -s localhost:3000

    echo -e "\n\nLogs:\n"
    docker logs $APP
}

build

exit 0
