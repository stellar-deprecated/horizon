#! /usr/bin/env bash

set -e

# ensure no git changes are outstanding
if [ -n "$(git status --porcelain)" ]; then 
  echo "dirty working directory"; 
  exit 1
fi

pushd docs
hugo -t hyde
popd

git checkout gh-pages
cp -R docs/public/* ./
git add -A .
git commit -m "Update docs"
git push
