FROM alpine

ARG KUBECTL_VERSION=1.18.1
ARG HELM_VERSION=3.1.2

RUN apk --no-cache add shadow openssh coreutils grep bash bash-completion \
                       openssl curl openssh gettext vim tree tmux git docker-cli && \
    # kubectl
    curl -#L -o kubectl https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    install -t /usr/local/bin kubectl && rm kubectl && \
    # helm
    curl -#L https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz | tar -xvz --strip-components=1 linux-amd64/helm && \
    install -t /usr/local/bin helm && rm helm

EXPOSE 22
VOLUME /home
COPY deliver/*.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D"]
