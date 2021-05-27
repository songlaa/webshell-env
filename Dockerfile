FROM theiaide/theia

ARG KUBECTL_VERSION=1.21.1
ARG HELM_VERSION=3.5.4
ARG DOCKER_COMPOSE=1.29.2
ARG TERRAFORM_VERSION=0.15.4
ARG AZURECLI_VERSION=2.23.0

user root
RUN apk --no-cache add coreutils grep bash curl gettext vim tree git \
                       docker-cli mysql-client lynx py3-pip \
                       bash-completion docker-bash-completion git-bash-completion && \
    # Azure CLI
    apk --no-cache add --virtual=build gcc libressl-dev libffi-dev musl-dev openssl-dev python3-dev make && \
    pip3 install azure-cli==${AZURECLI_VERSION} --no-cache-dir && \
    apk del build && \
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
    install -t /usr/local/bin terraform && rm terraform

COPY bashrc /home/theia/.bashrc

user theia
