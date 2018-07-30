# vim:ft=sh

if [ ! -d git/home/dotfiles ] ; then
  cat <<EOF
Usage:
cd $HOME
mkdir -p git/home
git clone https://github.com/alexharv074/dotfiles.git git/home/dotfiles
bash git/home/dotfiles/install.sh
EOF
fi

for i in $(
  find git/home/dotfiles \
    -not \( -path git/home/dotfiles/.git -prune \) \
    -not \( -path git/home/dotfiles/install.sh -prune \) \
    -type f
  ) ; do

  path=$(dirname $(echo $i | sed -e 's|git/home/dotfiles/||'))

  if [ "$path" == "." ] ; then
    echo ln -s $i in $(pwd)
    ln -s $i
  else
    oldpwd=$(pwd)
    cd $path && ln -s $OLDPWD/$i
    cd $oldpwd
  fi

done
