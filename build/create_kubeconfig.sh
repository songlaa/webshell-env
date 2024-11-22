#!/bin/bash

TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
NAMESPACE=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
CA=$(cat /run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w0)

cat << EOF > kubeconfig.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: https://${CLUSTER_K8S_API_HOST}:6443
  name: songlaa-training-cluster
contexts:
- context:
    cluster: songlaa-training-cluster
    namespace: ${NAMESPACE}
    user: songlaa-user
  name: songlaa-training
current-context: songlaa-training
kind: Config
preferences: {}
users:
- name: songlaa-user
  user:
    token: ${TOKEN}
EOF