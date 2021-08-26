#!/bin/bash

if ! [[ "$1" =~ ^(build|deploy|destroy|destroyall)$ ]]; then
    printf "=> No valid target given, possible values: build|deploy|destroy|destroyall\n\n"
    exit 1
fi

export ORG="acend"
export APP="theia"
export STUDENTS=4
export PREFIX="student"
export DOMAIN="labapp.acend.ch"
export AUTHFILE="/home/$USER/acend-training-authfile"

build() {
    set -e
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
    read -p "Enter Ingress (default: nginx): " INGRESS
    if [ -z "$INGRESS" ]; then
        export INGRESS="nginx"
    fi

    read -p "Creating with prefix '$PREFIX' and domain '$DOMAIN' on ingress '$INGRESS'. Type yes: " yn
    case $yn in
        [Yy]* ) echo;;
        * ) echo "=> answer yes to go on the next time"; exit;;
    esac 

    echo "$(date): latest credentials links" >> $AUTHFILE
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=$PREFIX$i
        cat workspace.yaml | envsubst | kubectl apply -f -

	if [[ ! "$(kubectl -n $STUDENT get secrets -o name)" =~ "basic-auth" ]]; then
	    PW=$(date | md5sum | awk '{print $1}')
            echo $PW | htpasswd -i -c auth $PREFIX$i
	    kubectl -n $STUDENT create secret generic basic-auth --from-file=auth
	    echo "https://$PREFIX$i:$PW@$PREFIX$i.$DOMAIN" >> $AUTHFILE
	    rm auth
	    sleep 5
	fi
	echo
    done
    echo -e "=> check the credentials file at: $AUTHFILE \n"
}

destroy() {
    # keeps ingresses and certs as there are expensive
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=$PREFIX$i
        kubectl -n $STUDENT delete deploy $STUDENT-theia-deploy
        kubectl -n $STUDENT delete svc    $STUDENT-theia-svc
    done
}

destroyall() {
    for i in $(seq 1 $STUDENTS); do
        export STUDENT=$PREFIX$i
        kubectl delete ns $STUDENT
    done
    rm $AUTHFILE
}

"$@"

exit 0
