FROM theiaide/theia

ARG KUBECTL_VERSION=1.22.1
ARG HELM_VERSION=3.6.3
ARG DOCKER_COMPOSE=1.29.2
ARG TERRAFORM_VERSION=1.0.5
ARG AZURECLI_VERSION=2.27.2

user root
RUN sed -i "s/3.11/3.14/" /etc/apk/repositories && \
    apk --no-cache update && apk --no-cache -U upgrade -a && \
    apk --no-cache add coreutils grep bash curl gettext vim tree git p7zip \
                       docker-cli mysql-client lynx py3-pip figlet grep \
                       bash-completion docker-bash-completion jq bind-tools \
		       py3-yaml py3-pynacl py3-bcrypt py3-cryptography py3-psutil py3-wheel

RUN pip3 install azure-cli==${AZURECLI_VERSION} --no-cache-dir && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/network/v201*" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/network/v2020*" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/cosmosdb" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/iothub" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/sql" && \
    bash -c "rm -rf /usr/lib/python3.9/site-packages/azure/mgmt/web" && \
    # kubectl
    curl -#L -o kubectl https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # helm
    curl -#L https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm && \
    # docker-compose
    curl -L# -o docker-compose https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE/docker-compose-Linux-x86_64 && \
    install -t /usr/local/bin docker-compose && rm docker-compose && \
    # Terraform
    curl -#L -o tf.zip https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip tf.zip && rm tf.zip && \
    install -t /usr/local/bin terraform && rm terraform && \
    # tfenv
    curl -#L -o tfenv https://raw.githubusercontent.com/tfutils/tfenv/master/bin/tfenv && \
    install -t /usr/local/bin tfenv && rm tfenv

COPY bashrc /home/theia/.bashrc

user theia
