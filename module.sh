#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

folder=$(pwd)

function handleModule() {
	cd $1 && go mod tidy
}

handleEcho $folder
handleModule $folder
handleCallback "go mod tidy success" "go mod tidy failed"
