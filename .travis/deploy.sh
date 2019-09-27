#!/bin/bash

echo "Deploy $TRAVIS_BRANCH !"

set -o errexit -o nounset

if [[ "$TRAVIS_BRANCH" != "master" ]] && [[ "$TRAVIS_BRANCH" != "review-*" ]] && [[ "$TRAVIS_BRANCH" != "test" ]] && [[ "$TRAVIS_BRANCH" != "styleguide" ]] 
then
  echo "This commit was made against the $TRAVIS_BRANCH and not the 'master', 'test' or 'review-*' branch! No deploy!"
  exit 0
fi

rev=$(git rev-parse --short HEAD)

REPONAME=`basename $PWD`
PARENTDIR=`dirname $PWD`
USERNAME=`basename $PARENTDIR`

cd out

git init
git config user.name "oXygen XML Deployer"
git config user.email "support@oxygenxml.com"

git remote add upstream "https://$GH_TOKEN@github.com/$USERNAME/$REPONAME.git"
git fetch upstream
git reset upstream/gh-pages

#touch .

UPDATE=./$TRAVIS_BRANCH

ls
git status

git add -A $UPDATE
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages