# vim:ft=sh

if [ ! -d git/home/dotfiles ] ; then
  cat <<EOF
  In the wrong directory?
Usage:
cd $HOME
mkdir -p git/home
git clone https://github.com/alexharv074/dotfiles.git git/home/dotfiles
bash git/home/dotfiles/install.sh
EOF
  exit 1
fi

files=$(find git/home/dotfiles \
  -not \( -path git/home/dotfiles/.git -prune \) \
  -not \( -path git/home/dotfiles/install.sh -prune \) \
  -type f)

for i in $files ; do
  path="$(
    dirname "$(echo $i | sed -e 's!git/home/dotfiles/!!')"
  )"

  if [ ! "$path" == "." ] ; then
    oldpwd=$(pwd)
    cd $path && ln -s $oldpwd/$i
    cd $oldpwd
    continue
  fi

  ln -s $i
done
