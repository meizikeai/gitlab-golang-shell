#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

handleEcho "start go build"
go build -o $project main.go
handleCallback "go build success" "go build failed"

# set flag for build version
git rev-parse --short HEAD >version
