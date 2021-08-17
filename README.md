# theia-env
Creates a theia runtime for x students in Kubernetes itself

## setup.sh
This script can be started locally against a configured k8s cluster.

Run it with the options:
- build      (build container and push it to registry)
- deploy     (deploy trainer and students container)
- destroy    (delete student deployments and services only)
- destroyall (delete student namespaces together with the lets encrypt certs)

It creates a theia webconsole for the amount of student given in the setup.sh script.
The entry is protected with basic-auth and https with letsencrypt.

Content:
- extended theia webconsole
- docker in docker

For number of given users in variables it creates an own workspace with the convention:
- student1
- student2
- student3
- ...

## workflow
Edit the amount of student you need and run the setup.sh script against a kubernetes cluster

If everthing is deployed you will have file in your home dir which contains all the different urls with the login informations

The student can use docker und kubectl directly in against their namespace where theia is deployed (e.g. student1)
