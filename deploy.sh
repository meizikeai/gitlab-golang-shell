#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

folderPath=$(dirname "${BASH_SOURCE[0]}")
hostList="$1"

function handleDeploy() {
  for host in $hostList; do
    deployService "$host" &
  done
  wait
  handleCallback "deploy $hostList success" "deploy $hostList failed"
  handleEcho "Notification send successfully"
}

function deployService() {
  local host=$1
  handleEcho "rsync start"
  rsync -acr -e "ssh -o StrictHostKeyChecking=no" --exclude-from="${folderPath}/exclude.list" --delete . $host:$deploys
  handleEcho "rsync to $host:$deploys"
  handleCallback "rsync success" "rsync failed"

  handleEcho "start service"
  handleCommand "$host" "supervisorctl restart $project"
  handleCallback "service started success" "service startup failed"
}

if [ $CI_ENVIRONMENT_NAME = "development" ] || [ $CI_ENVIRONMENT_NAME = "production" ]; then
  handleDeploy
else
  handleEcho "invalidate env: $CI_ENVIRONMENT_NAME"
  exit 1
fi
