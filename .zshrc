source ~/.zshrc.secrets
source ~/.zshrc.cmd

export PATH="$PATH:$GOPATH/bin:/usr/local/packer:/Users/alexharvey/git/home/create_specs:/Users/alexharvey/git/cmd/sync_spec:/Users/alexharvey/git/cmd/cmd-internal/cmd-scripts/git"
export TERM='xterm-256color'

alias ls='/bin/ls -F'
alias grep='/usr/local/Cellar/grep/3.1/libexec/gnubin/grep --color=auto'
alias grpe=grep

# Git functions.
#
alias recommit='git reset --soft HEAD~ ; git add . ; git commit -e -F .git/COMMIT_EDITMSG'

rebase() {
  branch=`git branch |awk '/^\*/ {print $2}'`
  git checkout master
  git pull
  git checkout $branch
  git rebase master
}

delete_all_merged_branchs() {
  git branch --merged | egrep -v "(^\*|master$)" | xargs git branch -d
}

# Beaker.
#
vagrant_ssh() {
  if [ -z $1 ]; then
    offset=3
  elif [ "$1" = g ]; then
    vagrant global-status
    return
  else
    offset=$(( $1 + 3 ))
  fi
  id=`vagrant global-status 2>&1 |sed -n "${offset}p;d" |awk '{print $1}'`
  if [ -z $id ]; then
    vagrant global-status
  else
    vagrant ssh $id
  fi
}

vagrant_destroy() {
  if [ -z $1 ]; then
    offset=3
  elif [ "$1" = g ]; then
    vagrant global-status
    return
  else
    offset=$(( $1 + 3 ))
  fi
  id=`vagrant global-status 2>&1 |sed -n "${offset}p;d" |awk '{print $1}'`
  if [ -z $id ]; then
    vagrant global-status
  else
    vagrant destroy $id
  fi
}

set_beaker_package_proxy() {
  ipaddr=$(ifconfig en0 | awk '/inet/ {print $2}')
  export BEAKER_PACKAGE_PROXY=http://${ipaddr}:3128/
  echo "BEAKER_PACKAGE_PROXY is $BEAKER_PACKAGE_PROXY"
}
export BEAKER_destroy=no

# RVM.
#
use_rvm() {
  export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
}
use_rvm
echo "RVM is on"

mv_large_files() {
  for i in ~/Desktop/*-large ~/Downloads/*-large
  do
    j=$(echo $i |sed -e 's/-large$//')
    mv $i $j
  done
}

# Puppet Blacksmith.
#
export BLACKSMITH_FORGE_URL=https://forgeapi.puppetlabs.com
export BLACKSMITH_FORGE_USERNAME=alexharvey

# Go.
#
export GOPATH=$HOME/go
export g10k_cachedir=/var/tmp

# Antigen / Oh my zsh
#
source ~/.antigen/antigen.zsh

antigen use oh-my-zsh
antigen bundle colored-man-pages
antigen bundle docker
antigen bundle gem
antigen bundle git
antigen bundle git-extras
antigen bundle httpie
antigen bundle jsontools
antigen bundle pep8
antigen bundle pip
antigen bundle pylint
antigen bundle ruby
antigen bundle sudo
antigen bundle vagrant
antigen bundle virtualenv

# See other themes from https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
antigen theme avit

antigen apply
