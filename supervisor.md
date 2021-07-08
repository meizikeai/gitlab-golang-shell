### supervisor

#### 安装

```sh
$ apt-get install supervisor
```

安装成功后，会在 /etc/supervisor 目录下，生成 supervisord.conf 配置文件。

在 /etc/supervisor/supervisord.conf 文件添加下面 第三行 内容。

```sh
; supervisor config file

[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                      ; sockef file mode (default 0700)
chown=work:work                 ; socket file uid:gid owner [添加这行，work 为调用 supervisorctl 进行重启等命令的用户]
```

进程配置会读取 /etc/supervisor/conf.d 目录下的 *.conf 配置文件，我们在此目录下创建一个 name.conf 进程配置文件

```sh
[program:go-practice]                                      ; 项目名称
directory = /home/work/go-practice                         ; 程序所在目录
command = /home/work/go-practice/go-practice               ; 程序启动命令
user = work                                                ; 可使用 supervisorctl 命令的用户
autostart = true                                           ; 是否跟随supervisord的启动而启动
autorestart = true                                         ; 程序退出后自动重启, 可选值：[unexpected, true, false]
stopasgroup = true                                         ; 进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup = true                                         ; 向进程组发送kill信号，包括子进程
stdout_logfile = /data/logs/supervisord/go-practice.log    ; 该程序日志输出文件，目录需要手动创建
environment=GIN_MODE=test                                  ; 环境变量用逗号隔开
```

需要注意的是，请在 root 账号下进行配置，并执行以下命令来启动 supervisord 服务。

### 启动

```sh
$ supervisord -c /etc/supervisor/supervisord.conf
```

启动过程中如提示，请在 root 下执行 `chmod -R 777 /data/logs` 给权限

```sh
Error: The directory named as part of the path /data/logs/supervisord/go-practice.log does not exist. in section 'program:go-practice' (file: '/etc/supervisor/conf.d/go-practice.conf')
For help, use /usr/bin/supervisord -h
```

如出现下面的错误

```sh
Error: Another program is already listening on a port that one of our HTTP servers is configured to use. 
Shut this program down first before starting supervisord.
```

请查找一下相关进程，并杀掉

```sh
$ ps -ef | grep supervisord
$ kill -9 116639
```

再次启动，如果提示
Unlinking stale socket /var/run/supervisor.sock
需要执行以下命令

```sh
$ unlink /var/run/supervisor.sock
```

### 帮助

```sh
# program 为 [program:go-practice] 里配置的值
# start、restart、stop、remove、add 都不会载入最新的配置文件

# start      启动程序
# status     查看程序状态
# stop       关闭程序
# tail       查看进程日志
# update     重启配置文件修改过的程序
# reload     停止程序，重新加载所有程序
# reread     读取有更新（增加）的配置文件，不会启动新添加的程序
# restart    重启程序

# 执行某个进程
$ supervisorctl restart program

# 一次性执行全部进程
$ supervisorctl restart all

# 载入最新的配置文件，停止原有进程并按新的配置启动所有进程
$ supervisorctl reload

# 根据最新的配置文件，启动新配置或有改动的进程，配置没有改动的进程不重启
$ supervisorctl update

# 查看运行状态
$ supervisorctl status
```
