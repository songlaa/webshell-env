#!/bin/bash

if ! [[ "$1" =~ ^(build|deploy|destroy)$ ]]; then
    printf "=> No valid target given, possible values: build|deploy|destroy\n\n"
    exit 1
fi

export ORG="acend"
export APP="alpine-sshd"
export USERS=16

build() {
    set -e
    docker build -t $ORG/$APP .
    docker push $ORG/$APP
    docker image prune --force
    set +e
}

deploy() {
    kubectl -n train scale deploy shell-deploy --replicas=0
    kubectl apply -f deliver/deployment.yaml
    for i in $(seq 1 $USERS); do
        export USER=user$i
        kubectl -n $USER scale deploy $USER-shell-deploy --replicas=0
        cat deliver/workspace.yaml | envsubst | kubectl apply -f -
    done
    kubectl -n train rollout status deployment shell-deploy
}

destroy() {
    for i in $(seq 1 $USERS); do
        export USER=user$i
        kubectl delete ns $USER
    done
}

"$@"

exit 0
