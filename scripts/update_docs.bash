#! /usr/bin/env bash

set -e

# ensure no git changes are outstanding
if [ -n "$(git status --porcelain -uno)" ]; then 
  echo "dirty working directory"; 
  exit 1
fi


git checkout gh-pages
cp -R tmp/docs/* ./
git add -A .
git commit -m "Update docs"
git push
