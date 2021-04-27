#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

ssr="$1"

# check git version for rebuild
# because gitlab-ci retry just trigger `deploy` stage, without `build` stage.

currentVersion=$(
  git rev-parse --short HEAD
)

tagVersion=$(
  touch version
  cat version
)

if [ "$currentVersion" = "$tagVersion" ]; then
  handleEcho "git version match"
else
  handleEcho "git version not match, rebuild build"
  bash $scripts/module.sh
  bash $scripts/build.sh
fi
