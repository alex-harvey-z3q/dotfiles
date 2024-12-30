# vim:ft=sh

source ~/.zshrc.secrets

for file_name in ~/.zshrc.* ; do
  [[ $file_name =~ .zshrc.secrets ]] && continue
  [[ $file_name =~ .zshrc.zw?     ]] && continue
  [[ $file_name =~ .zshrc.*.zw?   ]] && continue
  source "$file_name"
done

export TERM='xterm-256color'

setopt INTERACTIVE_COMMENTS  # Make zsh behave the same as bash if a comment is added in the CLI.

remove_trailing_newlines() {
  perl -pli -e 's/\s+$//' "$1"
}

commit_todo() {
  cd ~/Documents/todo
  bash commit.sh
  cd -
}

replace_all() {
  local search replace file_name

  if [[ -z "$2" ]] ; then
    echo "Usage: replace_all SEARCH REPLACE"
    echo "Replace all occurences of SEARCH with REPLACE\nin a directory"
    return 1
  fi

  search="$1" ; replace="$2"

  grep -wlr "$search" . | while read -r file_name ; do
    gsed -i 's/'"$search"'/'"$replace"'/g' "$file_name"
  done
}

to_xls() {
  if [[ -t 0 ]] ; then
    echo "Usage: cat MYINPUT.csv | $0"  # $0 different in zsh. Use ${FUNCNAME[0]} in Bash.
    return
  fi

  sed 's/,/	/g' | pbcopy
}

hash_diff() {
  if [[ "$#" -ne 2 ]] ; then
    echo "Usage: hash_diff YAML_FILE1 YAML_FILE2"
    return
  fi

  ruby -rhashdiff -rawesome_print -ryaml \
    -e "ap Hashdiff.diff(*ARGV.map{|f| YAML.load_file(f)})" "$1" "$2"
}

# Git functions.
#
alias recommit='git reset --soft HEAD~ ; git add . ; git commit -e -F .git/COMMIT_EDITMSG'

rebase() {
  local branch="$(git branch | awk '/^\*/ {print $2}')"
  git checkout master
  git pull
  git checkout "$branch"
  git rebase master
}

delete_all_merged_branchs() {
  git branch --merged | egrep -v "(^\*|master$)" | xargs git branch -d
}

git_grep() {
  git grep "$1" "$(git rev-list --all)"
}

list_branches() {
  local OLDIFS input file remote

  setopt shwordsplit
  OLDIFS="$IFS"
  IFS=/

  if [ -z "$1" ] ; then
    input=alex
  else
    input="$1"
  fi

  for file in */.git/refs/*/"$input"/* ; do
    words=($file)
    remote="$(awk '/url =/ {print $3; exit}' "${words[1]}"/.git/config)"
    printf "%-30s: %-30s : %s\n" "${words[1]}" "$remote" "${words[5]}"/"${words[6]}"
  done
  echo

  IFS="$OLDIFS"
  setopt noshwordsplit
}

git_log_tags() {
  git log --tags --simplify-by-decoration --pretty="format:%ai %d"
}

# Terraform.
#
select_terraform() {
  local ans version

  command ls -1 /usr/local/bin/terraform_* | awk -F"_" '
    BEGIN { count = 1 }
    {
      print count ". " $2
      count += 1
    }'

  read ans

  version="$(
    command ls -1 /usr/local/bin/terraform_* | \
    awk -v input="$ans" -F"_" '
    BEGIN { count = 1 }
    {
      if (input == count) print $2
      count += 1
    }'
  )"

  rm -f /usr/local/bin/terraform

  cp /usr/local/bin/terraform_"$version" \
    /usr/local/bin/terraform
}

install_terraform() {
  local version url basename bin os arch

  if [[ -z "$1" ]] || [[ "$1" = "-h" ]] ; then
      echo "Usage: install_terraform VERSION"
      echo "E.g. install_terraform 1.4.5"
      return
  fi

  os="$(uname | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"

  case "$arch" in
    x86_64)  arch="amd64" ;;
    i*86)    arch="386"   ;;
    *)
      echo "Unknown architecture $arch"
      return
      ;;
  esac

  version="${1#v}"
  url=https://releases.hashicorp.com/terraform/"$version"/terraform_"$version"_"$os"_"$arch".zip
  basename="$(basename "$url")"
  bin=/usr/local/bin/terraform_"$version"

  wget "$url"
  unzip "$basename"

  mv terraform "$bin" && \
    echo "Terraform $version successfully installed in $bin"
}

# Beaker.
#
vagrant_ssh() {
  local offset id
  if [ -z $1 ]; then
    offset=3
  elif [ "$1" = g ]; then
    vagrant global-status
    return
  else
    offset=$(( $1 + 3 ))
  fi
  id="$(vagrant global-status 2>&1 | sed -n "${offset}p;d" | awk '{print $1}')"
  if [ -z "$id" ] ; then
    vagrant global-status
  else
    vagrant ssh "$id"
  fi
}

vagrant_destroy() {
  local offset id
  if [ -z "$1" ]; then
    offset=3
  elif [ "$1" = g ]; then
    vagrant global-status
    return
  else
    offset=$(( $1 + 3 ))
  fi
  id="$(vagrant global-status 2>&1 | sed -n "${offset}p;d" | awk '{print $1}')"
  if [ -z "$id" ]; then
    vagrant global-status
  else
    vagrant destroy "$id"
  fi
}

set_beaker_package_proxy() {
  ipaddr="$(ifconfig en0 | awk '$1 == "inet" {print $2}')"
  export BEAKER_PACKAGE_PROXY=http://"$ipaddr":3128/
  echo "BEAKER_PACKAGE_PROXY is $BEAKER_PACKAGE_PROXY"
}
export BEAKER_destroy=no

# Rbenv
#
use_rbenv() {
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
}

# Pyenv.
#
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Poetry.
#
export PATH="$HOME/.local/bin:$PATH"

# Puppet Blacksmith.
#
export BLACKSMITH_FORGE_URL=https://forgeapi.puppetlabs.com
export BLACKSMITH_FORGE_USERNAME=alexharvey

## Puppet.
#
export PATH=/opt/puppetlabs/puppet/bin:/opt/puppetlabs/pdk/bin:"$PATH"

# Aliases.
#
alias grep='/usr/local/Cellar/grep/3.7/libexec/gnubin/grep --color=auto'
alias grpe='grep'
alias diff='/usr/local/bin/diff --color=always'
alias ls='/bin/ls -F'
alias sed='/usr/local/bin/gsed'
alias vim='/usr/local/bin/vim'

# Docker
#
if [[ ! -d ~/.zsh/completion/ ]] ; then
  mkdir -p ~/.zsh/completion/
  ln -s /Applications/Docker.app/Contents/Resources/etc/docker.zsh-completion ~/.zsh/completion/_docker
  ln -s /Applications/Docker.app/Contents/Resources/etc/docker-compose.zsh-completion ~/.zsh/completion/_docker-compose
fi
fpath=($fpath ~/.zsh/completion)

export PS1='%n %1~ %# '

autoload -U select-word-style
select-word-style bash
