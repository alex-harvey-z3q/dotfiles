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

for i in git/dotfiles/.* ; do
  [ "$i" == 'git/dotfiles/.' ] && continue
  [ "$i" == 'git/dotfiles/..' ] && continue
  [ "$i" == 'git/dotfiles/.git' ] && continue
  ln -s $i
done
