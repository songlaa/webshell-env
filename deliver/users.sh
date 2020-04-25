#!/bin/bash

SA="/run/secrets/kubernetes.io/serviceaccount"

# create user for lab
if [ -n "$STUDENT" ]; then
    if [ ! -d "/home/$STUDENT" ]; then
	useradd -s /bin/bash -m -p '$1$GyA7dHxv$YofsmqYCpThAVRM9Gg2kO0' $STUDENT
	mkdir /home/user$i/.kube
        kubectl config set-cluster demo-k8s --server=https://kubernetes.default --certificate-authority=$SA/ca.crt
        kubectl config set-credentials demo-k8s --token $(cat $SA/token)
        kubectl config set-context demo-k8s --cluster=demo-k8s --user=demo-k8s --namespace=$STUDENT
        kubectl config use demo-k8s
        mkdir /home/$STUDENT/.kube && cp /root/.kube/config /home/$STUDENT/.kube/config
        chown -R $STUDENT:$STUDENT /home/$STUDENT
    fi
else
    # create kubernetes config
    kubectl config set-cluster demo-k8s --server=https://kubernetes.default --certificate-authority=$SA/ca.crt
    kubectl config set-credentials demo-k8s --token $(cat $SA/token)
    kubectl config set-context demo-k8s --cluster=demo-k8s --user=demo-k8s --namespace=train
    kubectl config use demo-k8s

    USER="trainer"
    if [ ! -d "/home/$USER" ]; then
        # create trainer for lab
        FILE="/home/trainer/login.txt"
        useradd -s /bin/bash -m -p '$1$9o2f6vci$taWRDMCgtsLWJRzkWYaip1' $USER
        mkdir /home/$USER/.kube && cp /root/.kube/config /home/$USER/.kube/config
        mkdir /home/$USER/.ssh && echo "StrictHostKeyChecking=no" > /home/$USER/.ssh/config
        chown -R $USER:$USER /home/$USER
    fi

    USER="students"
    # create student for lab
    if [ ! -d "/home/$USER" ]; then
        PASS=$(openssl rand -base64 6)
        echo "https://shell.acend.ch/ssh/$USER?sshpass=$PASS" >> $FILE
        useradd -s /bin/bash -m -p $(openssl passwd -1 $PASS) students
        mkdir /home/$USER/.ssh && echo "StrictHostKeyChecking=no" > /home/$USER/.ssh/config
        chown -R $USER:$USER /home/$USER
    fi

    # security
    chown trainer:trainer $FILE
    chmod 600 $FILE
fi

exit 0
