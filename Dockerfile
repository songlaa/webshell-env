FROM theiaide/theia

ARG KUBECTL_VERSION=1.22.1
ARG HELM_VERSION=3.6.3
ARG DOCKER_COMPOSE=1.29.2
ARG TERRAFORM_VERSION=1.0.6
ARG AZURECLI_VERSION=2.28.0
ARG TFENV_VERSION=v2.2.2
ARG ARGOCD_VERSION=2.1.2

USER root
RUN sed -i "s/3.11/3.14/" /etc/apk/repositories && \
    apk --no-cache update && \
    apk --no-cache -U upgrade -a && \
    apk --no-cache add coreutils grep bash curl gettext vim tree git p7zip \
                       docker-cli mysql-client lynx bind-tools figlet jq \
                       bash-completion docker-bash-completion git-bash-completion \
		       py3-pip py3-yaml py3-pynacl py3-bcrypt py3-cryptography py3-psutil py3-wheel

RUN pip3 install azure-cli==${AZURECLI_VERSION} --no-cache-dir && \
    # azure cli cleanup
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/network/v201*" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/network/v2020*" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/cosmosdb" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/iothub" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/sql" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/web" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/databoxedge" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/synapse" && \
    # kubectl
    curl -#L -o kubectl https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # helm
    curl -#L https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm && \
    # docker-compose
    curl -L# -o docker-compose https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE/docker-compose-Linux-x86_64 && \
    install -t /usr/local/bin docker-compose && rm docker-compose && \
    # Argo CD
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

RUN git config --global advice.detachedHead false && \
    # tfenv & terraform
    cd /opt/ && git clone --depth 1 --branch ${TFENV_VERSION} https://github.com/tfutils/tfenv.git 2>/dev/null && \
    ln -s /opt/tfenv/bin/* /usr/local/bin && \
    tfenv install ${TERRAFORM_VERSION} && \
    tfenv use ${TERRAFORM_VERSION}

USER theia
COPY bashrc /home/theia/.bashrc
