#!/bin/bash
# cat logins.txt for sharing credentials

USERS=12

# prepare kubernetes config
SA="/run/secrets/kubernetes.io/serviceaccount"
kubectl config set-cluster demo-k8s --server=https://kubernetes.default --certificate-authority=$SA/ca.crt
kubectl config set-credentials demo-k8s --token $(cat $SA/token)
kubectl config set-context demo-k8s --cluster=demo-k8s --user=demo-k8s
kubectl config use demo-k8s

# create trainer for lab
USER="trainer"
FILE="/home/trainer/logins.txt"
useradd -s /bin/bash -m -p '$1$9o2f6vci$taWRDMCgtsLWJRzkWYaip1' $USER
mkdir /home/$USER/.kube && cp /root/.kube/config /home/$USER/.kube/config

# create users for lab
echo Connect to URL: https://shell.acend.ch > $FILE
for i in $(seq 1 $USERS); do
    if [ ! -d "/home/user$1" ]; then
	pass=$(openssl rand -base64 6)
	useradd -s /bin/bash -m -p $(openssl passwd -1 $pass) user$i
	echo user$i:$pass >> $FILE
	mkdir /home/user$i/.kube
	cp /root/.kube/config /home/user$i/.kube/config
	chown -R user$i:user$i /home/user$i/
    fi
done

# secure logins.txt
chmod 600 $FILE
chown -R $USER:$USER /home/$USER/

exit 0
