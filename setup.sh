#!/bin/bash

if ! [[ "$1" =~ ^(build|deploy|destroy)$ ]]; then
    printf "=> No valid target given, possible values: build|deploy|destroy\n\n"
    exit 1
fi

export ORG="acend"
export APP="theia"
export STUDENTS=2

build() {
    if [ -n "$(which docker)" ]; then
        docker build -t $ORG/$APP .
        docker push $ORG/$APP
        docker image prune --force
    elif [ -n "$(which buildah)" ]; then
        sudo buildah build -t $ORG/$APP .
        sudo buildah push $ORG/$APP
        sudo buildah image prune --force
    fi
}

deploy() {
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=student$i
        cat deliver/workspace.yaml | envsubst | kubectl apply -f -
    done
}

destroy() {
    for i in $(seq 1 $USERS); do
        export STUDENT=student$i
        kubectl delete ns $STUDENT
    done
}

"$@"

exit 0
