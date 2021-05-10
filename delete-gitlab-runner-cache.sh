#!/bin/bash

# crontab命令
# crontab -e             // 修改 crontab 文件，如果文件不存在会自动创建。
# crontab -l             // 显示 crontab 文件。
# crontab -r             // 删除 crontab 文件。
# crontab -ir            // 删除 crontab 文件前提醒用户。

# Ubuntu系统 重启、关闭、开启
# service cron status   // 查看crontab服务状态
# service cron start    // 启动服务
# service cron stop     // 关闭服务
# service cron restart  // 重启服务
# service cron reload   // 重新载入配置

# Mac系统 重启、关闭、开启
# sudo /usr/sbin/cron start
# sudo /usr/sbin/cron restart
# sudo /usr/sbin/cron stop

# 1、查看 crontab 是否启动
# ps aux | grep cron

# 2、检查需要的文件
# ls -al /etc/crontab

# 3、如果crontab文件不存在，则创建
# sudo touch /etc/crontab

# 示例
# 编辑定时任务配置文件
# crontab -e
# 在配置文件中写入定时任务, 指定每天6点定时执行脚本，记录操作日志
# 0 6 * * * bash /home/ubuntu/delete-gitlab-runner-cache.sh >> /data/delete-gitlab-runner-cache.sh.log
# */1 * * * * bash /home/ubuntu/delete-gitlab-runner-cache.sh >> /data/delete-gitlab-runner-cache.sh.log
# :wq 保存退出

disk="/dev/vdb"
ratio=70

function handleDeleteFiles() {
  files=$(ls $1)

  cd $1

  for v in $files; do
    if test -d $v; then
      echo $(pwd)/$v
      rm -rf $v
    fi
  done

  cd ../
}

function handleGitlabRunnerCache() {
  time=$(date '+%F %T')
  usage=$(df -h | grep $disk | awk -F '[ %]+' '{print $5}')

  echo "执行时间：${time}; 磁盘使用率：${usage}%;"

  if [ $usage -ge $ratio ]; then
    echo "执行时间：${time}; 磁盘使用率：${usage}%; 执行清理 /data 下 gitlab-runner-builds / gitlab-runner-caches / website 目录"

    # test
    # handleDeleteFiles "/Users/qinxikun/Downloads"

    # release
    handleDeleteFiles "/data/gitlab-runner-builds"
    handleDeleteFiles "/data/gitlab-runner-caches"
    handleDeleteFiles "/data/website"
  fi
}

handleGitlabRunnerCache
