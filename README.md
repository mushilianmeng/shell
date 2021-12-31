# shell
##常用的运维功能shell脚本<br>
<b>auto.sh</b><br>
#启动jar包脚本，jar包需要放置在 /data/service 目录，需要在Jvm_port中配置相关信息。<br>

<b>Jvm_port.txt</b><br>
#auto.sh配置脚本<br><br>

<b>boot-deploy.sht</b><br>
#发布脚本<br><br>

<b>check_log.sh</b><br>
#日志监控脚本，会将日志通过告警机器人接口上传数据<br>
<b>check_log.txt</b><br>
#日志监控脚本的配置文件<br><br>

<b>init.sh</b><br>
#系统初始化脚本<br><br>

<b>install.sh</b><br>
#系统初始化安装脚本<br><br>

<b>prometheus_push.sh</b><br>
#将从prometheus_list.txt配置文件中逐条取数据并上传到pushgateway上。<br>
<b>prometheus_push.txt</b><br>
#prometheus_push配置文件<br><br>

<b>prometheus_scan.sh</b><br>
#将扫描本机的所有prometheus接口，符合规范将写入prometheus_list.txt配置文件<br><br>

<b>remove.sh</b><br>
#linux 回收站<br><br>

<b>update.sh</b><br>
#自动更新脚本将自动比对线上和线下的脚本md5，不一致将从线上更新脚本。<br>
<b>update_shell.txt</b><br>
#update.sh配置文件<br><br>

<b>ssh_link.sh</b><br>
#用于建立ssh隧道的脚本，实践发现service监听方式有时候莫名其妙断了不能重连，所以用脚本死循环连接。<br><br>
