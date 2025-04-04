# theia-env

Creates a theia based webshell runtime in kubernetes itself

## build.sh

This script can be started locally to build and test.

```bash
pushd build
./build.sh
popd
docker run --rm -p 3000:3000 --name theia songlaa/theia
```

## Deploy using Helm Chart

### Deploy in kind

This will create a kind cluster with the necessary prerequisites

```bash
kind create cluster
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
# create cert for ingress  
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out self-signed-tls.crt -keyout self-signed-tls.key \
    -subj "/CN=localhost" \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "[SAN]\nsubjectAltName=DNS:localhost,DNS:*.localhost"))
kubectl create ns mystudent        
kubectl create secret -n mystudent tls self-signed-tls - key self-signed-tls.key - cert self-signed-tls.crt
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8443:443 &

```

This will deploy one webshell. If multiple webshells are needed, create as many instances in seperated Namespaces as you want.
Create a `values.yaml` e.g.:

```yaml
user: "mystudent" # This should be the namespace where the student's webshell is deployed to
password: "supersecretbassword" # For the basic-auth Autentication

ingress: # Make sure this fits your enviornemt!
  enabled: true
  className: "nginx"
  annotations: 
    ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
  hosts:
    - host: localhost
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: 
   - secretName: tls
     hosts:
       - localhost

theia:
  persistence:
    storageclass: standard
dind:
  persistence:
    storageclass: standard
```

```bash
helm repo add songlaa-webshell https://songlaa.github.io/webshell-env/
helm upgrade --install --namespace mystudent webshell songlaa-webshell/webshell -f values.yaml
```

Now use the hostname or the port-forwarding with localhost:8443

## Release a new Chart Version

When changing `version` in `deploy/charts/webshell/Chart.yaml` a new chart version is automaticly released and available in the chart repositoy `https://songlaa.github.io/webshell-env/`

## workflow

Edit the amount of student you need and run the setup.sh script against a kubernetes cluster

If everthing is deployed you will have file in your home dir which contains all the different urls with the login informations

The student can use docker und kubectl directly in against their namespace where theia is deployed (e.g. student1)
