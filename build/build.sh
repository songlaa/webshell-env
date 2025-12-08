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
        # delete cache to ensure latest packages are installed
        docker build --no-cache --progress=plain -t $ORG/$APP .
        test_image
        if [ "$1" = "push" ]; then
            echo -e "\nPushing image to registry:\n"
            docker push $ORG/$APP
        fi
    elif [ -n "$(which buildah)" ]; then
        sudo buildah bud -t docker.io/$ORG/$APP .
        if [ "$1" = "push" ]; then
            echo -e "\nPushing image to registry:\n"
            sudo buildah push docker.io/$ORG/$APP
        fi
    fi
}

test_image() {
    echo -e "\nTest:\n"
    set -e
    docker run -d --rm -p 3000:3000 --name $APP $ORG/$APP
    docker images | grep $APP

}

build "$1"

exit 0
