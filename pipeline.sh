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
kubectl apply -f deliver/deployment.yaml

exit 0
