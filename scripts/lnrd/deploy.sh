#!/bin/bash
set -e

dist=$1
src_barnch=$2
deploy_branch=$3

echo "dist: $dist"
echo "src branch: $src_barnch"
echo "deploy branch: $deploy_branch"

cd $dist

getCurrentBranch() {
    branch_name="$(git symbolic-ref HEAD)"
    IFS='/'     # space is set as delimiter
    read -ra splitname <<< "$branch_name" 
    local result=${splitname[${#splitname[@]} - 1]}
    echo "$result"
}

gitPull () {
  git fetch
  git pull origin $src_barnch
}

gitPush () {
  git add .
  git commit -m "deploy-$(date)"
  git push origin $deploy_branch
}

uploadEnvFile() {
  aws s3 cp ./.env s3://lnrd-data-services-env-vars-stg/data-services/
}

start() {
  echo "pull from $src_barnch"
  gitPull
  echo "pull done."
  echo "upload .env file"
  uploadEnvFile
  echo "upload done."
  echo "push git repo"
  gitPush
  echo "push done."
}

prepareBranch() {
  current="$(getCurrentBranch)"
  echo "push current changes ($current)"
  git fetch
  git pull origin
  git add .
  git commit -m "deploy-$(date)"
  git push origin
  echo "done."
  if [ "$current" != "$deploy_branch" ]
  then
    # git checkout $deploy_branch
    echo "checkout > $deploy_branch"
  fi
}

prepareBranch
