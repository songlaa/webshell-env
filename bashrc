source /etc/profile
export PS1='\[\033[01;32m\]\u\[\033[01;96m\]\[\033[01;34m\] \w\[\033[01;33m\]$()\[\033[01;34m\] \$\[\033[00m\] '
export DOCKER_HOST=localhost:2375
alias ls="ls --color"
alias ll="ls -l"
find /home/project -name .profile -exec source {} \; 2>/dev/null

for cmd in argocd helm kubectl oc; do
  source <(${cmd} completion bash)
done

/usr/bin/az.completion.sh
complete -C /usr/local/bin/terraform terraform

figlet -w 120 welcome @ acend
