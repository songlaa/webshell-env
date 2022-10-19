# theia-env

Creates a theia based webshell runtime in kubernetes itself

## build.sh

This script can be started locally to build and test.

```bash
./build.sh
docker run --rm -p 3000:3000 --name theia acend/theia
```

## Deploy using Helm Chart

This will deploy one webshell. If multiple webshells are needed, create as many instances in seperated Namespaces as you want.
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

`<secretname>`: you have to make sure that this secrets exists in your Namespace. This Helm Chart does not create a TLS Secret/Certificate for you.

```bash
helm repo add acend-webshell https://acend.github.io/webshell-env/
helm upgrade --install --namespace mystudent webhell acend-webshell/webshell -f values.yaml
```

## Release a new Chart Version

When changing `version` in `deploy/charts/webshell/Chart.yaml` a new chart version is automaticly released and available in the chart repositoy `https://acend.github.io/webshell-env/`

## workflow

Edit the amount of student you need and run the setup.sh script against a kubernetes cluster

If everthing is deployed you will have file in your home dir which contains all the different urls with the login informations

The student can use docker und kubectl directly in against their namespace where theia is deployed (e.g. student1)
