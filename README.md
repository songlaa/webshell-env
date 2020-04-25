# webshell-env
Creates a webshell runtime in Kubernetes

## webshell.sh
This script can be started locally against a configured k8s cluster.

Run it with the options:
- build    (build container and push it to registry)
- deploy   (deploy trainer and students container)
- destroy  (delete student namespaces only, run after finished the training)

It creates one static webshell trainer container with
- wetty webshell
- alpine sshd
- docker in docker

For number of given users in variables it creates an own workspace with the convention:
- user1
- user2
- user3
- ...

## workflow
For the first login, the trainer have to login to get the credentials for the student to use the bastion entrypoint.
Login with the known password (may change in repo, check the password tool)

The "trainer" can read the file "login.txt" in his home directory. This link represents the URL where the students can use to login. They should change now the user by:
   export STUDENT=userX && enterlab

They are now in their own environment and have access to the docker in docker daemon and kubectl which is preconfigured to the same cluster and namespace called by the user name itself.
