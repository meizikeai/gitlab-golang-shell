#!/bin/bash
# tools for gitlab ci output

function handleEcho() {
  echo -e "→ $1"
}

function handleCommand() {
  local host="$1"
  local command="$2"

  ssh -o StrictHostKeyChecking=no $host "$command"
}

function handleCallback() {
  if [ $? -eq 0 ]; then
    handleEcho "$1"
    sendNotice "Successful operation\nProject: $CI_PROJECT_NAME\nEnv: $CI_ENVIRONMENT_NAME\nStage: $CI_JOB_STAGE\nCreated By: $GITLAB_USER_NAME\nStatus: deploy success\nLink: $CI_PIPELINE_URL\nMessage: $CI_COMMIT_MESSAGE" "success"
  else
    handleEcho "$2"
    sendNotice "Errors and Warnings\nProject: $CI_PROJECT_NAME\nEnv: $CI_ENVIRONMENT_NAME\nStage: $CI_JOB_STAGE\nCreated By: $GITLAB_USER_NAME\nStatus: catching error\nLink: $CI_PIPELINE_URL\nMessage: $CI_COMMIT_MESSAGE" "failed"
    exit 1
  fi
}

function sendNotice() {
  # 钉钉
  local dingtalkText="$1"

  if [ $dingtalk ]; then
    curl -X POST "$dingtalk" \
      -H 'Content-Type: application/json' \
      -d '{
      "msgtype": "text",
      "text": {
          "content": "'"$dingtalkText"'"
      }
    }'
  fi

  # 飞书
  local feishuText=$(echo $1)

  if [ $feishu ]; then
    curl -X POST "$feishu" \
      -H 'Content-Type: application/json' \
      -d '{
      "title": "GitLab CI/CD notice",
      "text": "'"$feishuText"'"
    }'
  fi

  # 飞书 - v2
  local color=$([ "$2" == success ] && echo "green" || echo "red")
  local status=$([ "$2" == success ] && echo "deploy success" || echo "catching error")
  local message=$(echo $CI_COMMIT_MESSAGE)

  if [ $feishuv2 ]; then
    curl -X POST "$feishuv2" \
      -H 'Content-Type: application/json' \
      -d '{"msg_type":"interactive","card":{"config":{"wide_screen_mode":true},"header":{"title":{"tag":"plain_text","content":"GitLab CI/CD notice"},"template":"'"$color"'"},"elements":[{"tag":"markdown","content":"**Project** '"$CI_PROJECT_NAME"'"},{"tag":"markdown","content":"**Env** '"$CI_ENVIRONMENT_NAME"'"},{"tag":"markdown","content":"**Stage** '"$CI_JOB_STAGE"'"},{"tag":"markdown","content":"**Created By** '"$GITLAB_USER_NAME"'"},{"tag":"markdown","content":"**Status** '"$status"'"},{"tag":"markdown","content":"**Message** '"$message"'"},{"tag":"action","actions":[{"tag":"button","text":{"tag":"lark_md","content":"LINK"},"url":"'"$CI_PIPELINE_URL"'","type":"default"}]}]}}'
  fi
}
