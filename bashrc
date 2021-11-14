source /etc/profile
if [ -f "/run/secrets/kubernetes.io/serviceaccount/namespace" ]; then
  NS=$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)
fi
export PS1='\[\033[01;32m\]\u\[\033[01;96m\]($NS)\[\033[01;34m\] \w\[\033[01;33m\]$()\[\033[01;34m\] \$\[\033[00m\] '

alias ls="ls --color"
alias ll="ls -l"
find /home/project -name .profile -exec source {} \; 2>/dev/null

export DOCKER_HOST=tcp://localhost:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/home/project/.tls/client

for cmd in argocd helm kubectl oc; do
  source <(${cmd} completion bash)
done

/usr/bin/az.completion.sh
complete -C /usr/local/bin/terraform terraform

figlet -w 120 welcome @ acend
