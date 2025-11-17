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

To build and push the image to the registry, use the `push` argument:

```bash
pushd build
./build.sh push
popd
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
With a working cluster you can deploy the webshell.

For running the last public version on your local env:

```bash
pushd deploy/charts/webshell
helm repo add songlaa-webshell https://songlaa.github.io/webshell-env/
helm repo update songlaa-webshell
helm upgrade --install --namespace mystudent webshell songlaa-webshell/webshell -f values-local-dev.yaml
popd
````

or if you want to use the locally build image and template with `kind` :

```bash
kind load docker-image songlaa/theia
pushd deploy/charts/webshell
helm upgrade --install --namespace mystudent webshell . -f values.yaml -f values-local-dev.yaml --set theia.image.repository=songlaa/theia --set theia.image.tag=latest
popd
```

Now use the hostname or the port-forwarding with localhost:8443

## Release a new Chart Version

When changing `version` in `deploy/charts/webshell/Chart.yaml` a new chart version is automaticly released and available in the chart repositoy `https://songlaa.github.io/webshell-env/`

## workflow

Edit the amount of student you need and run the setup.sh script against a kubernetes cluster

If everthing is deployed you will have file in your home dir which contains all the different urls with the login informations

The student can use docker und kubectl directly in against their namespace where theia is deployed (e.g. student1)
