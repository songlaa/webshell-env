#!/bin/bash

set -e

ORG="acend"
APP="alpine-sshd"

# start
docker build -t $ORG/$APP .

# push image
docker push $ORG/$APP

# cleanup
docker image prune --force

set +e

# deploy
export $(grep USERS= deliver/users.sh)
NS=""
kubectl apply -f deliver/deployment.yaml
for i in $(seq 1 $USERS); do
    export USER=user$i
    cat deliver/namespace.yaml | envsubst | kubectl apply -f -
    NS+=" user$i"
done

# cleanup
echo "kubectl delete ns$NS"

exit 0
