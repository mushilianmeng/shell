#/bin/bash
sys_youhua(){
	mkdir -p /data/project-tmp /data/script /data/service /data/soft /data/backup /data/wwwlogs/ /data/file
	yum install epel-release -y
	yum update -y
	yum install tree nmap dos2unix lrzsz nc lsof wget tcpdump htop iftop iotop sysstat nethogs telnet ntp net-tools lvm2 unzip -y
	chkconfig abrt-ccpp.service off
	chkconfig abrt-oops.service off
	chkconfig abrt-vmcore.service off
	chkconfig abrt-xorg.service off
	chkconfig abrtd.service off
	chkconfig dbus-org.freedesktop.NetworkManager.service off
	chkconfig dbus-org.freedesktop.nm-dispatcher.service off
	chkconfig postfix.service off
	
	service ntpd start
	chkconfig ntpd on
	chkconfig sshd on
	echo '* soft nofile 1024000
	* hard nofile 1024000
	* soft nproc 65535
	* hard nproc 65535
	* soft stack 10240
	* hard stack 10240' >> /etc/security/limits.conf
	
	ulimit -SHn 1024000
	ulimit -SHu 65535
	ulimit -SHs 10240
	
	sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
	
	service sshd restart
	
	MEM=`free -m|grep Mem|awk {'print $2'}`
	MEM=`expr $MEM \* 1024 \* 921`
	
	echo "
	kernel.shmmax = $MEM
	kernel.shmall = $MEM
	kernel.sysrq = 1
	vm.swappiness = 1
	fs.inotify.max_user_watches = 10000000
	net.core.wmem_max = 16777216
	net.core.rmem_max = 16777216
	net.ipv4.conf.all.send_redirects = 0
	net.ipv4.conf.default.send_redirects = 0
	net.ipv4.conf.all.secure_redirects = 0
	net.ipv4.conf.default.secure_redirects = 0
	net.ipv4.conf.all.accept_redirects = 0
	net.ipv4.conf.default.accept_redirects = 0
	fs.inotify.max_queued_events = 327679
	net.ipv4.neigh.default.gc_thresh1 = 2048
	net.ipv4.neigh.default.gc_thresh2 = 4096
	net.ipv4.neigh.default.gc_thresh3 = 8192
	net.ipv6.conf.all.disable_ipv6 = 0
	net.ipv6.conf.default.disable_ipv6 = 0
	net.ipv6.conf.lo.disable_ipv6 = 0
	net.ipv4.tcp_keepalive_time = 1200
	net.ipv4.tcp_keepalive_intvl = 15
	net.ipv4.tcp_keepalive_probes = 5
	net.ipv4.tcp_max_syn_backlog = 4096
	net.core.somaxconn = 4096
	net.core.netdev_max_backlog = 3000
	net.ipv4.tcp_tw_reuse = 1
	net.ipv4.tcp_fin_timeout = 30
	net.ipv4.tcp_fack = 1
	net.ipv4.tcp_sack = 1
	net.core.wmem_default = 256960
	net.core.wmem_max = 4088000
	net.core.rmem_default = 256960
	net.core.rmem_max = 4088000
	net.ipv4.tcp_wmem = 8760  256960  4088000
	net.ipv4.tcp_rmem = 8760  256960  4088000
	net.ipv4.tcp_mem = 131072  262144  524288" >/etc/sysctl.conf
	sysctl -p
	
	sed -i 's/HISTSIZE=.*/HISTSIZE=50000/g' /etc/profile
	echo 'readonly HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
	export HISTTIMEFORMAT
	readonly TMOUT=300
	export TMOUT
	export TIME_STYLE="+%Y-%m-%d %H:%M:%S"' >>/etc/profile
	echo 'alias rm="sh /data/script/remove.sh"'>>~/.bashrc
	source /etc/profile
}
firewall_jiagu(){
	ip_firewall="yes"
	if [ `firewall-cmd --state | grep run | wc -l` != 1 ]
	then
		echo "firewalld 没有运行"
		exit 0
	fi
	while [ $ip_firewall = "yes" ]
	do
		read -p "请依次输入安全区IP,一次输入一个，例如 192.168.1.200/32，输入不符合格式的字符将退出脚本 " ip_firewall
		if echo $ip_firewall | grep -Eq "[0-9].[0-9].[0-9].[0-9]"
		  then :;
			firewall-cmd --permanent --zone=trusted --add-source=$ip_firewall
			ip_firewall="yes"
		else
		  echo "输入的ip不正确，脚本退出";
		  exit 1;
		fi;
	done
}
qingkong_firewall(){
	firewall-cmd --permanent --list-all | grep services | head -n 1 | cut -d: -f2 | tr ' ' '\n' | xargs -I {} firewall-cmd --permanent --remove-service={}
	firewall-cmd --permanent --list-all | grep ports | head -n 1 | cut -d: -f2 | tr ' ' '\n' | xargs -I {} firewall-cmd --permanent --remove-port={}
	}
sys_youhua
read -p "是否需要配置 Firewalld 安全区，安全加固? [Y/n] 默认为 NO: " yn
[ -z "${yn}" ] && yn="n"
        if [[ $yn == [Yy] ]]; then
                echo -e "请逐条输入安全区的IP"
                qingkong_firewall
                firewall_jiagu
        fi
