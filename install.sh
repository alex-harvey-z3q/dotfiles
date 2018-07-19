# vim:ft=sh

if [ ! -d git/dotfiles ] ; then
  cat <<EOF
Usage:
cd $HOME
mkdir -p git
git clone https://github.com/alexharv074/dotfiles.git git/dotfiles
bash git/dotfiles/install.sh
EOF
fi

for i in $(
  find git/dotfiles \
    -not \( -path git/dotfiles/.git -prune \) \
    -not \( -path git/dotfiles/install.sh -prune \) \
    -type f
  ) ; do

  path=$(dirname $(echo $i | sed -e 's|git/dotfiles/||'))

  if [ -z "$path" ] ; then
    ln -s $i
  else
    mkdir -p $path
    cd $path && ln -s $OLDPWD/$i && cd $OLDPWD
  fi

done
