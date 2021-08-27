source /etc/profile
export PS1='\[\033[01;32m\]\u\[\033[01;96m\]\[\033[01;34m\] \w\[\033[01;33m\]$()\[\033[01;34m\] \$\[\033[00m\] '
export DOCKER_HOST=localhost:2375
source <(kubectl completion bash)
/usr/bin/az.completion.sh
alias ls="ls --color"
alias ll="ls -l"
complete -C /usr/local/bin/terraform terraform
test -f /home/project/projects/.profile && source /home/project/projects/.profile
figlet -w 120 welcome @ acend
