#!/bin/bash
echo "正在进行系统初始化设置"
echo "注意主机名将成为zabbix监控中的主机名同步，请认真填写"
read -p "请输入主机名: " hostname
echo $hostname>/etc/hostname
hostnamectl set-hostname $hostname
read -p "请输入IP地址: " ip
echo $ip
ip_1=`echo "$ip" | awk -F "." '{print $1}'`
ip_2=`echo "$ip" | awk -F "." '{print $2}'`
ip_3=`echo "$ip" | awk -F "." '{print $3}'`
ip_4=`echo "$ip" | awk -F "." '{print $4}'`
echo $ip_1\.$ip_2\.$ip_3\.$ip_4
sed -i "s/10\.0\.0\.19/$ip_1\.$ip_2\.$ip_3\.$ip_4/" /etc/sysconfig/network-scripts/ifcfg-ens192
sed -i '$d' ~/.bash_profile
cd /data/soft/zabbix_agent
bash install.sh
sed -i "s/Centos7-image/$hostname/" /data/soft/zabbix/etc/zabbix_agentd.conf
echo "将重启网络，请使用您设置的ip地址登录主机"
systemctl restart network
