#!/bin/bash

if ! [[ "$1" =~ ^(build|deploy|destroy|destroyall)$ ]]; then
    printf "=> No valid target given, possible values: build|deploy|destroy|destroyall\n\n"
    exit 1
fi

export ORG="acend"
export APP="theia"
export STUDENTS=8
export AUTHFILE="/home/$USER/acend-training-authfile"

build() {
    if [ -n "$(which docker)" ]; then
        docker build -t $ORG/$APP .
        docker push $ORG/$APP
        docker image prune --force
    elif [ -n "$(which buildah)" ]; then
        sudo buildah bud -t docker.io/$ORG/$APP .
        sudo buildah push docker.io/$ORG/$APP
    fi
}

deploy() {
    touch $AUTHFILE
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=student$i
        cat workspace.yaml | envsubst | kubectl apply -f -

	if [[ ! "$(kubectl -n $STUDENT get secrets -o name)" =~ "basic-auth" ]]; then
	    PW=$(date | md5sum | awk '{print $1}')
            echo $PW | htpasswd -i -c auth student$i
	    kubectl -n $STUDENT create secret generic basic-auth --from-file=auth
	    echo "https://student$i:$PW@student$i.theia.acend.ch" >> $AUTHFILE
	    rm auth
	    sleep 5
	fi
    done
}

destroy() {
    # keeps ingresses and certs as there are expensive
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=student$i
        kubectl -n $STUDENT delete deploy $STUDENT-theia-deploy
        kubectl -n $STUDENT delete svc    $STUDENT-theia-svc
    done
}

destroyall() {
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=student$i
        kubectl delete ns $STUDENT
    done
    rm $AUTHFILE
}

"$@"

exit 0
