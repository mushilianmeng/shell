#/bin/bash
source /etc/profile
source ~/.bash_profile
xiangmu=`head -n 1 check_log.txt | tail -n 1`
send_url=`head -n 4 check_log.txt | tail -n 1`
qun=`head -n 2 check_log.txt | tail -n 1`
prometheus_url=`head -n 5 check_log.txt | tail -n 1`
xiangmuapi=`head -n 6 check_log.txt | tail -n 1`
prometheus_push_list_num=`cat prometheus_list.txt | wc -l`
ip_dizhi=`ip a | grep global | head -1 | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
shijian=`date '+%Y年%m月%d日 %H:%M:%S'`
for i in $(seq 1 $prometheus_push_list_num)
do
	prometheus_push_list=`cat prometheus_list.txt | head -n $i | tail -1 | awk -F" " '{print $1}'`
	echo $prometheus_push_list
	status=`curl -s --connect-timeout 10 -m 10 $prometheus_push_list |  grep jvm_classes_loaded | tail -1 | grep application | wc -l`
	if [ $status -eq 1 ];then
		application=`curl -s --connect-timeout 10 -m 10 $prometheus_push_list |  grep jvm_classes_loaded | tail -1 | grep application | awk -F"\"" '{print $2}'`
		curl -s $prometheus_push_list | curl --data-binary @- $prometheus_url$xiangmuapi"_"$application
		fail_num=`cat prometheus_list.txt | head -n $i | tail -1 | awk -F" " '{print $2}'`
		fail_num_new=0
		sed -i 's#'''$prometheus_push_list''' '''$fail_num'''#'''$prometheus_push_list''' '''$fail_num_new'''#g' prometheus_list.txt
	else
		application=`cat prometheus_list.txt | head -n $i | tail -1 | awk -F" " '{print $3}'`
		fail_num=`cat prometheus_list.txt | head -n $i | tail -1 | awk -F" " '{print $2}'`
		fail_num_new=`expr ${fail_num} + 1`
		sed -i 's#'''$prometheus_push_list''' '''$fail_num'''#'''$prometheus_push_list''' '''$fail_num_new'''#g' prometheus_list.txt
		if [ $fail_num_new -eq 3 ];then
			error_list=`echo "$xiangmu
告警时间：$shijian
主机 IP：$ip_dizhi
问题: 普罗米修斯接口3分钟无响应
触发服务自愈，已尝试重启服务。"|base64 -w 0`
			log=`echo "$prometheus_push_list
服务名:  $application"| base64 -w 0`
			curl -H "Content-Type: application/json" -X POST -d '{"a":"'$error_list'","b":"'$qun'","log":"'$log'"}' "$send_url">/dev/null 2>&1
			bash /data/script/auto.sh restart $application
		elif [ $fail_num_new -eq 9 ];then
			error_list=`echo "$xiangmu
告警时间：$shijian
主机 IP：$ip_dizhi
问题: 普罗米修斯接口重启后6分钟依然无响应
请尽快人工介入处理。"|base64 -w 0`
			log=`echo "$prometheus_push_list
服务名:  $application"| base64 -w 0`
                        curl -H "Content-Type: application/json" -X POST -d '{"a":"'$error_list'","b":"'$qun'","log":"'$log'"}' "$send_url">/dev/null 2>&1
		elif [ $fail_num_new -eq 1440 ];then
			error_list=`echo "$xiangmu
告警时间：$shijian
主机 IP：$ip_dizhi
问题: 普罗米修斯接口已经24小时无响应，已从监控列表移除，修复后将会24小时内重新接入。"|base64 -w 0`
                        log=`echo "$prometheus_push_list
服务名:  $application"| base64 -w 0`
                        curl -H "Content-Type: application/json" -X POST -d '{"a":"'$error_list'","b":"'$qun'","log":"'$log'"}' "$send_url">/dev/null 2>&1
			sed -i 's#'''$prometheus_push_list''' '''$fail_num_new'''##g' prometheus_list.txt
			sed -i "/^$/d" prometheus_list.txt
		fi
	fi		
done
