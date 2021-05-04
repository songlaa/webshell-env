export PS1='\[\033[01;32m\]\u\[\033[01;96m\]\[\033[01;34m\] \w\[\033[01;33m\]$()\[\033[01;34m\] \$\[\033[00m\] '
export DOCKER_HOST=localhost:2375
source <(kubectl completion bash)
