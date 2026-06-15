#!/usr/bin/env bash
# vim:ft=sh

home_dir="$(pwd)"
repo_dir="$home_dir/git/home/dotfiles"

if [ ! -d "$repo_dir" ] ; then
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

while IFS= read -r -d '' source ; do
  relative_path="${source#"$repo_dir"/}"
  target="$home_dir/$relative_path"

  if [ -e "$target" ] || [ -L "$target" ] ; then
    echo "Skipping existing ~/$relative_path"
    continue
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
done < <(
  find "$repo_dir" \
    -not \( -path "$repo_dir/.git" -prune \) \
    -not \( -path "$repo_dir/install.sh" -prune \) \
    -not -name '*.example*' \
    -type f \
    -print0
)

if [ ! -e "$home_dir/.gitconfig.local" ] ; then
  touch "$home_dir/.gitconfig.local"
  chmod 600 "$home_dir/.gitconfig.local"
  echo "Created ~/.gitconfig.local"
fi
