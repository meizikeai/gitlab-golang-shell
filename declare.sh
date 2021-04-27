#!/bin/bash

# include lib
. $(dirname "${BASH_SOURCE[0]}")/tools.sh

handleEcho "I also want to look for a girlfriend..."
handleEcho "The current project is $CI_PROJECT_NAME !"
handleEcho "The current branch is $CI_COMMIT_REF_NAME !"
