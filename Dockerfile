FROM theiaide/theia

ARG KUBECTL_VERSION=1.20.6
ARG HELM_VERSION=3.5.4

user root
RUN apk --no-cache add coreutils grep bash curl gettext vim tree git docker-cli \
		       bash-completion docker-bash-completion git-bash-completion && \
    # kubectl
    curl -#L -o kubectl https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # helm
    curl -#L https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm && \
    echo '. /etc/profile' >> /home/theia/.profile && chown theia /home/theia/.profile && \
    sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

COPY deliver/motd /etc/motd
COPY deliver/profile.sh /etc/profile.d/

user theia
