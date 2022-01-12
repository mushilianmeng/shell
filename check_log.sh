#/bin/bash
source /etc/profile
source ~/.bash_profile
cd /data/script
xiangmu=`head -n 1 check_log.txt | tail -n 1`
qun=`head -n 2 check_log.txt | tail -n 1`
keywords=`head -n 3 check_log.txt | tail -n 1`
send_url=`head -n 4 check_log.txt | tail -n 1`
warn_check(){
	ls /data/wwwlogs/$1/warn/$1.warn.log
	if [ $? -ne 0 ];then
		echo $1 warn 日志未发现
		return
	fi
	tailhang=`wc -l /data/wwwlogs/$1/warn/$1.warn.log | awk -F" " '{print $1}'`
	ls /data/wwwlogs/$1/warn/$1.num
	if [ $? -ne 0 ];then
		headhang=1
	else
		headhang=`cat /data/wwwlogs/$1/warn/$1.num`
        fi
	if [ $headhang -gt $tailhang ];then
                headhang=1
	elif [ $headhang -eq $tailhang ];then
		echo $1 warn 没有新增日志
		return
        elif [ $tailhang -eq 0 ];then
                echo $1 error 空日志文件
                tailhang=1
	elif [ $headhang -eq 0 ];then
		echo $1 error headhang 参数错误,自动纠正为1
		headhang=1
        fi
        echo "headhang: "$headhang
        echo "tailhang: "$tailhang
        sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/warn/$1.warn.log>>/dev/null
        if [ $? -eq 0 ];then
                echo $tailhang>/data/wwwlogs/$1/warn/$1.num
        fi
        log_error_num=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/warn/$1.warn.log | grep -Eoai -m 1 "$keywords" | wc -l`
        log_error=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/warn/$1.warn.log | grep -Eoai -m 1 "$keywords"`
        log=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/warn/$1.warn.log | grep -Eai "$keywords"`
        echo $log_error_num
        if [ $log_error_num -eq 0 ];then
                echo "not alarm error or warn"
	else
		shijian=`date '+%Y年%m月%d日 %H:%M:%S'`
		ip_dizhi=`ip a | grep global | head -1 | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
		error_list=`echo "$xiangmu
服务名：$1
日志错误类型：$log_error
告警时间：$shijian
主机 IP：$ip_dizhi
详情报错如下：↓↓↓↓↓↓↓↓↓↓"|base64 -w 0`
		log=`echo "$log" | base64 -w 0`
		curl -H "Content-Type: application/json" -X POST -d '{"a":"'$error_list'","b":"'$qun'","log":"'$log'"}' "$send_url">/dev/null 2>&1
	fi
}
error_check(){
	ls /data/wwwlogs/$1/error/$1.error.log
        if [ $? -ne 0 ];then
                echo $1 error 日志未发现
		return
        fi
        tailhang=`wc -l /data/wwwlogs/$1/error/$1.error.log | awk -F" " '{print $1}'`
        ls /data/wwwlogs/$1/error/$1.num
        if [ $? -ne 0 ];then
                headhang=1
        else
                headhang=`cat /data/wwwlogs/$1/error/$1.num`
        fi
        if [ $headhang -gt $tailhang ];then
                headhang=1
	elif [ $headhang -eq $tailhang ];then
                echo $1 error 没有新增日志
                return
        elif [ $tailhang -eq 0 ];then
                echo $1 error 空日志文件
                tailhang=1
        elif [ $headhang -eq 0 ];then
                echo $1 error headhang 参数错误,自动纠正为1
                headhang=1
        fi
        echo "headhang: "$headhang
        echo "tailhang: "$tailhang
        sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/error/$1.error.log>>/dev/null
        if [ $? -eq 0 ];then
                echo $tailhang>/data/wwwlogs/$1/error/$1.num
        fi
	log_error_num=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/error/$1.error.log | grep -Eoai -m 1 "$keywords" | wc -l`
	log_error=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/error/$1.error.log | grep -Eoai -m 1 "$keywords"`
        log=`sed -n "$headhang,"$tailhang"p" /data/wwwlogs/$1/error/$1.error.log | grep -Eai "$keywords"`
        echo $log_error_num
        if [ $log_error_num -eq 0 ];then
                echo "not alarm error or warn"
        else
                shijian=`date '+%Y年%m月%d日 %H:%M:%S'`
                ip_dizhi=`ip a | grep global | head -1 | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`
                error_list=`echo "$xiangmu
服务名：$1
日志错误类型：$log_error
告警时间：$shijian
主机 IP：$ip_dizhi
详情报错如下：↓↓↓↓↓↓↓↓↓↓"|base64 -w 0`
                log=`echo "$log" | base64 -w 0`
                curl -H "Content-Type: application/json" -X POST -d '{"a":"'$error_list'","b":"'$qun'","log":"'$log'"}' "$send_url">/dev/null 2>&1
        fi
}
lognum=`ls -l /data/wwwlogs/ | grep '^d' | grep -Ev "audit|application|point" | grep "-" | wc -l`
for i in $(seq 1 $lognum)
do
	a=`ls -l /data/wwwlogs/ | grep '^d' | grep -Ev "audit|application|point" | grep "-" | awk -F" " '{print $9}' | head -n $i | tail -1 | awk -F"/" '{print $1}'`
	warn_check $a
	error_check $a
done
