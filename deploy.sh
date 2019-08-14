#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"


pushd public
git checkout master
popd

hugo -t even

pushd public
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git commit -m "$msg"
git push -f origin master
popd

git add .
msg="update blog `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "${msg}"
git pull
git push origin blog