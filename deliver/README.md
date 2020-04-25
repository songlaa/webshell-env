# usage

see how does it work

## users.sh
This script creates the users in the workspaces.  

It differs between the main deployment with webshell integrated (deployment.yaml) and the workspace.yaml which creates the different student ssh containers.

Every user gets a kubeconfig file for his serviceaccount defined in the workspace.yaml with cluster-admin rights and the correct context. So the student can start right now with the lab.

## profile.sh
Setting global values like kubectl completion for the students

## entrypoint.sh
Preprate the ssh daemon and runs the users.sh
