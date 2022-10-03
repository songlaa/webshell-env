FROM node:18-alpine3.16

RUN apk add --no-cache make pkgconfig gcc g++ python3 libx11-dev libxkbfile-dev libsecret-dev

WORKDIR /home/theia
ADD package.json ./package.json

ARG GITHUB_TOKEN
RUN yarn --pure-lockfile --ignore-engines && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins

RUN yarn --production --ignore-engines && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:18-alpine3.16

ARG ARGOCD_VERSION=2.4.12
ARG AZURECLI_VERSION=2.40.0
ARG DOCKER_COMPOSE=2.10.2
ARG HELM_VERSION=3.10.0
ARG KUBECTL_VERSION=1.24.6
ARG TERRAFORM_VERSION=1.3.1
ARG TFENV_VERSION=v3.0.0
ARG KUSTOMIZE_VERSION=4.5.7
ARG MINIKUBE_VERSION=1.27.0
ARG TRIVY_VERSION=0.32.1

RUN apk --no-cache update && \
    apk --no-cache -U upgrade -a && \
    apk add --no-cache git openssh-client-default bash libsecret \
                       zsh zsh-autosuggestions podman buildah nano \
                       coreutils grep curl gettext vim tree git p7zip gcompat \
                       docker-cli mysql-client lynx bind-tools figlet jq libffi \
                       bash-completion docker-bash-completion git-bash-completion \
                       py3-pip py3-yaml py3-pynacl py3-bcrypt py3-cryptography \
                       py3-wheel py3-cffi py3-openssl py3-psutil>=5.9

RUN pip3 install azure-cli==${AZURECLI_VERSION} --no-cache-dir && \
    # azure cli cleanup
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/network/v201*" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/network/v2020*" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/cosmosdb" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/iothub" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/sql" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/web" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/databoxedge" && \
    bash -c "rm -rf /usr/lib/python3.10/site-packages/azure/mgmt/synapse"

RUN curl -#L -o kubectl "https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl" && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # krew 
    curl -fsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz && \
    tar zxvf krew-linux_amd64.tar.gz && \
    ./krew-linux_amd64 install krew && \
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" && \
    # krew plugins
    kubectl krew install ctx && \
    kubectl krew install ns && \
    kubectl krew install cert-manager && \
    kubectl krew install cilium && \
    kubectl krew install get-all && \
    kubectl krew install modify-secret && \
    # helm
    curl -#L "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz" | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm && \
    # docker-compose
    curl -L# -o docker-compose "https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE/docker-compose-Linux-x86_64" && \
    install -t /usr/local/bin docker-compose && rm docker-compose && \
    # Argo CD
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd && \
    # oc
    curl -#L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xvz oc && \
    install -t /usr/local/bin oc && rm oc && \
    # Kustomize
    curl -#L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar -xvz && \
    install -t /usr/local/bin kustomize && rm kustomize && \
    # Minikube
    curl -#L -o minikube "https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_VERSION}/minikube-linux-amd64" && \
    install -t /usr/local/bin minikube && rm minikube && \
    # Trivy
    curl -#L https://github.com/aquasecurity/trivy/releases/download/v0.27.1/trivy_0.27.1_Linux-64bit.tar.gz | tar -xvz trivy && \
    install -t /usr/local/bin trivy && rm trivy

RUN addgroup theia && \
    adduser -G theia -s /bin/sh -D theia && \
    chmod g+rw /home && \
    mkdir -p /home/project && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project

RUN git config --global advice.detachedHead false && \
    # tfenv & terraform
    cd /opt/ && git clone --depth 1 --branch ${TFENV_VERSION} https://github.com/tfutils/tfenv.git 2>/dev/null && \
    ln -s /opt/tfenv/bin/* /usr/local/bin && \
    tfenv install ${TERRAFORM_VERSION} && \
    tfenv use ${TERRAFORM_VERSION} && \
    sed -i 's/#mount_program/mount_program/' /etc/containers/storage.conf

ENV HOME /home/theia
WORKDIR /home/theia

COPY --from=0 --chown=theia:theia /home/theia /home/theia
EXPOSE 3000

ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENV USE_LOCAL_GIT true

USER theia
COPY bashrc /home/theia/.bashrc
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
