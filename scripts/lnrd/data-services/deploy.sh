#!/bin/bash
# set -e

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

uploadEnvFile() {
  aws s3 cp ./.env s3://lnrd-data-services-env-vars-stg/data-services/
}

start() {
  echo "=== START ==="
  current="$(getCurrentBranch)"
  echo "push current changes ($current)"
  git fetch
  git pull origin
  git add .
  git commit -m "deploy-$(date)"
  git push origin
 
  if [ "$current" != "$deploy_branch" ]
  then
    echo "checkout ($deploy_branch)"
    git checkout $deploy_branch
    git merge origin/$src_barnch
  fi

  current="$(getCurrentBranch)"
   
  if [ "$current" = "$deploy_branch" ]
  then
    set -e
    npm run build
    uploadEnvFile
    git push origin $deploy_branch
    git checkout $current
    echo "=== DONE ==="
  else
    echo "!!! Fail to checkout $deploy_branch"
  fi

  echo "=== END ==="

}

start
