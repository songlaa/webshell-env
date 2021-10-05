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

## Deploy using Helm Chart

Create a `values.yaml` e.g.:

```yaml
student: "mystudent" # This should be the namespace where the student's webshell is deployed to
password: "supersecretbassword" # For the basic-auth Autentication

ingress: # Make sure this fits your enviornemt!
  enabled: true
  className: "nginx"
  annotations: 
    ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
  hosts:
    - host: mystudent.<domain>
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: 
   - secretName: <secretname>
     hosts:
       - mystudent.<domain>
```

`<secretname>`: you have to make sure that this secrets exists in your Namespace. This Helm Chart does not create a Secret for you

```bash
helm upgrade --install --namespace mystudent webhell ./deploy/charts/webshell -f values.yaml
```

## Package a new Chart Version

This is needed e.g. if you wan't to deploy the chart using the Terraform helm_release resource without a Chart repository service (directly from Github)

```bash
cd deploy/charts
helm package ./webshell
`` 

Then commit the created `tgz` package.

## workflow
Edit the amount of student you need and run the setup.sh script against a kubernetes cluster

If everthing is deployed you will have file in your home dir which contains all the different urls with the login informations

The student can use docker und kubectl directly in against their namespace where theia is deployed (e.g. student1)
