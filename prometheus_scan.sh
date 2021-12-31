#/bin/bash
source /etc/profile
source ~/.bash_profile
ip_dizhi=`ip a | grep global | head -1 | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
open_port_list=`netstat -antp | grep java | grep LISTEN | awk -F" " '{print $4}' | awk -F":" '{print $4}'`
old_open_port_num=`cat prometheus_list.txt | awk -F":" '{print $3}' | awk -F"/" '{print $1}' | wc -l`
for b in $(seq 1 $old_open_port_num)
do
	old_open_port=`cat prometheus_list.txt | awk -F":" '{print $3}' | awk -F"/" '{print $1}' | head -n $b | tail -1`
	open_port_list=`echo $open_port_list | awk '{for(i=1;i<=NF;i++){print $i}}' | grep -v $old_open_port`
done
open_port_num=`echo $open_port_list | awk '{for(i=1;i<=NF;i++){print $i}}' | wc -l`
for i in $(seq 1 $open_port_num)
do
	open_port=`echo $open_port_list | awk '{for(i=1;i<=NF;i++){print $i}}' | head -n $i | tail -1`
	#echo $open_port
	status=`curl -s --connect-timeout 10 -m 10 http://$ip_dizhi:$open_port/actuator/prometheus |  grep jvm_classes_loaded | tail -1 | grep application | wc -l`
	echo "状态为:" $status
	if [ $status -eq 1 ];then
		pid=`netstat -antp | grep java | grep LISTEN | grep $open_port | awk -F" " '{print $7}' | awk -F"/" '{print $1}'`
		application=`ps -ef | grep $pid | grep -v grep | awk -F" " '{print $(NF-0)}' | awk -F"/" '{print $4}'`
                if  [ ! -n "$application" ] ;then
                        application=`curl -s --connect-timeout 1 http://$ip_dizhi:$open_port/actuator/prometheus |  grep jvm_classes_loaded | tail -1 | grep application | awk -F"\"" '{print $2}'`
                fi
		echo "http://$ip_dizhi:$open_port/actuator/prometheus 0 $application">>prometheus_list.txt
	fi 
done

