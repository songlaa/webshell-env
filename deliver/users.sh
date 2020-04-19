#!/bin/bash
# cat logins.txt for sharing credentials

# prepare kubernetes config
SA="/run/secrets/kubernetes.io/serviceaccount"
kubectl config set-cluster demo-k8s --server=https://kubernetes.default --certificate-authority=$SA/ca.crt
kubectl config set-credentials demo-k8s --token $(cat $SA/token)
kubectl config set-context demo-k8s --cluster=localhost --user=localhost
kubectl config use demo-k8s

# create trainer for lab
USER="trainer"
FILE="/home/trainer/logins.txt"
useradd -s /bin/bash -m -p '$1$9o2f6vci$taWRDMCgtsLWJRzkWYaip1' $USER
mkdir /home/$USER/.kube && cp /root/.kube/config /home/$USER/.kube/config

# create users for lab
for i in {1..24}; do
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

# create standard cli
echo "alias kctx=\"echo $(grep current ~/.kube/config | awk '{print $2}')\"" >> /etc/profile
echo "export GIT_PS1_SHOWDIRTYSTATE=1" >> /etc/profile 
echo "export PS1='\[\033[01;32m\]\u\[\033[01;96m\]($(kctx))\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '" >> /etc/profile
#echo "export PS1='\[\033[01;32m\]\u\[\033[01;96m\]\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '" >> /etc/profile
echo "export DOCKER_HOST=localhost:2375" >> /etc/profile
echo "source <(kubectl completion bash)" >> /etc/profile

exit 0
