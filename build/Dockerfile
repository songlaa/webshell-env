# Builder stage
FROM node:20-bookworm as build-stage

# install required tools to build the application
RUN apt-get update && \ 
    apt-get install -y git jq libxkbfile-dev libsecret-1-dev

# renovate: datasource=github-tags depName=eclipse-theia/theia-blueprint
ARG THEIA_VERSION=1.49.101

WORKDIR /tmp
RUN git clone --depth 1 --branch ${THEIA_VERSION} https://github.com/eclipse-theia/theia-blueprint.git

WORKDIR /home/theia
RUN cp -r /tmp/theia-blueprint/* .
COPY package.json.acend .
COPY preload.html ./applications/browser/resources/preload.html
# COPY branding-util.tsx ./theia-extensions/product/src/browser/branding-util.tsx

# customize package.json
RUN jq 'del(.theiaPlugins)' package.json > package.json.tmp && \
    jq -s '.[0] * .[1]' package.json.acend package.json.tmp > package.json

# Remove unnecesarry files for the browser application
# Download plugins and build application production mode
# Use yarn autoclean to remove unnecessary files from package dependencies
RUN yarn --pure-lockfile && \
    yarn build:extensions && \
    yarn download:plugins && \
    yarn browser build && \
    yarn && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean && \
    rm -r applications/electron theia-extensions/launcher theia-extensions/updater node_modules

# Production stage uses a small base image
FROM node:20-bookworm-slim as production-stage

# renovate: datasource=github-tags depName=argoproj/argo-cd
ARG ARGOCD_VERSION=v2.12.3
# renovate: datasource=github-tags depName=Azure/azure-cli
ARG AZURECLI_VERSION=2.51.0
# renovate: datasource=github-tags depName=docker/compose
ARG DOCKER_COMPOSE=v2.13.0
# renovate: datasource=github-tags depName=helm/helm
ARG HELM_VERSION=v3.15.4
# renovate: datasource=github-tags depName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.31.0
# renovate: datasource=github-tags depName=hashicorp/terraform
ARG TERRAFORM_VERSION=v1.9.5
# renovate: datasource=github-releases depName=terraform-linters/tflint
ARG TFLINT_VERSION=v0.53.0
ARG KUSTOMIZE_VERSION=v5.3.0
# renovate: datasource=github-tags depName=kubernetes/minikube
ARG MINIKUBE_VERSION=v1.33.1
# renovate: datasource=github-tags depName=aquasecurity/trivy
ARG TRIVY_VERSION=v0.54.1
# renovate: datasource=github-tags depName=tektoncd/cli
ARG TEKTON_VERSION=v0.38.0
# renovate: datasource=github-tags depName=kubevirt/kubevirt
ARG VIRTCTL_VERSION=v1.3.0

# Create theia user and directories
# Application will be copied to /home/theia
# Default workspace is located at /home/project
RUN adduser --system --group --home /home/theia theia
RUN chmod g+rw /home && \
    mkdir -p /home/project && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/project

RUN apt-get update && \
    apt-get install -y git openssh-client bash nano libsecret-1-0 dnsutils \
                       grep vim tree p7zip figlet curl bash-completion unzip ca-certificates gnupg jq mariadb-client lsof watch && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    apt-get clean

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    # kubectl
    curl -#L -o kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # helm
    curl -#L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm && \
    # docker-compose
    curl -L# -o docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE}/docker-compose-Linux-x86_64" && \
    install -t /usr/local/bin docker-compose && rm docker-compose && \
    # Argo CD
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd && \
    # oc
    curl -#L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -xvz oc && \
    install -t /usr/local/bin oc && rm oc && \
    # Kustomize
    curl -#L "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar -xvz && \
    install -t /usr/local/bin kustomize && rm kustomize && \
    # Minikube
    curl -#L -o minikube "https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64" && \
    install -t /usr/local/bin minikube && rm minikube && \
    # Trivy
    curl -#L "https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION#v}_Linux-64bit.tar.gz" | tar -xvz trivy && \
    install -t /usr/local/bin trivy && rm trivy && \
    # Tekton
    curl -#L "https://github.com/tektoncd/cli/releases/download/${TEKTON_VERSION}/tkn_${TEKTON_VERSION#v}_Linux_x86_64.tar.gz" | tar -xvz tkn && \
    install -t /usr/local/bin tkn && rm tkn && \
    # TFLint
    curl -#L -o tflint.zip "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip" && \
    unzip tflint.zip && rm tflint.zip && \
    install -t /usr/local/bin tflint && rm tflint && \
    # terraform
    curl -#L -o terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION#v}/terraform_${TERRAFORM_VERSION#v}_linux_amd64.zip" && \
    unzip terraform.zip && rm terraform.zip && \
    install -t /usr/local/bin terraform && rm terraform && \
    # virtctl
    curl -#L -o virtctl "https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64" && \
    install -t /usr/local/bin virtctl && rm virtctl

ENV HOME /home/theia
WORKDIR /home/theia

RUN for CMD in argocd helm kubectl oc tkn; do ${CMD} completion bash > /usr/share/bash-completion/completions/$CMD; done && \
    terraform -install-autocomplete

# Copy application from builder-stage
COPY --from=build-stage --chown=theia:theia /home/theia /home/theia

EXPOSE 3000

# Specify default shell for Theia and the Built-In plugins directory
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins \
    USE_LOCAL_GIT=true

# Switch to Theia user
USER theia
COPY --chown=theia bashrc /home/theia/.bashrc
COPY --chown=theia profile /home/theia/.profile
COPY --chown=theia create_kubeconfig.sh /home/theia/create_kubeconfig.sh

RUN cd /home/theia && \
    curl -fsSLO https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz && \
    tar zxvf krew-linux_amd64.tar.gz && \
    ./krew-linux_amd64 install krew && \
    rm -f krew-linux_amd64* && \
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" && \
    for PLUGIN in ctx ns cert-manager cilium get-all modify-secret tree view-secret neat; do kubectl krew install $PLUGIN; done

WORKDIR /home/theia/applications/browser

# Launch the backend application via node
ENTRYPOINT [ "node", "/home/theia/applications/browser/lib/backend/main.js" ]

# Arguments passed to the application
CMD [ "/home/project", "--hostname=0.0.0.0" ]
