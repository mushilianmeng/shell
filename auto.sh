#!/bin/bash
source /etc/profile
export LANG="en_US.UTF-8"

#设置环境信息
ACTIVE="tmp"
sdir="/data/service"
LS=`ls $sdir`
Jvmportfile="/data/script/Jvm_port.txt"
type=0
port=""
pid=""
IP=`/sbin/ip a|grep ens192|grep inet|awk -F "inet " '{print $2}'|awk -F "/" '{print $1}'`


start(){
        GetType $1
        if [ "$type" = "0" ];then
            echo "$1 服务不存在"
            return 1
        fi

        if [ "$type" = "2" ];then
            pid=$(ps -ef|grep -w "$1"|grep java|awk '{if($0!~/grep|admin/)print $2}')
			if [ -z "$pid" ];then 
				cd $sdir/$1/bin/
				nohup sh startup.sh > /dev/null 2>&1 &
				sleep 3
				pid=$(ps -ef|grep -w "$1"|grep java|awk '{if($0!~/grep|admin/)print $2}')
				if [ -n "$pid" ];then
					pidtime=`ps -p $pid -o lstart`
					echo $1 started ! Pid: $pid Time: $pidtime
					return 0
				else
					echo ERROR：$1 is start fail! 
				fi
			fi
        fi

        if [ "$type" = "1" ];then
			pid=$(ps -ef|grep -w "$1"-0.0.1.jar|grep java|awk '{if($0!~/grep|catalina.sh|cronolog|admin/)print $2}')
			if [ -z "$pid" ];then
				JAVAOP=`cat $Jvmportfile |grep -w ^"$1"|awk -F "|" '{print $3}'`
				JMX_PORT=`cat $Jvmportfile |grep -w ^"$1"|awk -F "|" '{print $2}'`
				cd $sdir/"$1"
				nohup $JAVA_HOME/bin/java -server $JAVAOP -Djava.rmi.server.hostname=$IP -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=$JMX_PORT -jar $sdir/"$1"/"$1"-0.0.1.jar > /dev/null 2>&1 &
				sleep 3
				pid=$(ps -ef|grep -w "$1"-0.0.1.jar|grep java|awk '{if($0!~/grep|catalina.sh|cronolog|admin/)print $2}')
				if [ -n "$pid" ];then
					pidtime=`ps -p $pid -o lstart`
					echo $1 is started ! Pid: $pid Time: $pidtime
					return 0
				else
					echo ERROR：$1 is start fail ! 
				fi
			fi
        fi
}

stop(){
        GetType $1
        if [ "$type" = "0" ];then
            echo "$1 服务不存在"
            return 0
        fi

        if [ "$type" = "2" ];then
			for ((i=1;i<=20;i++))
            do
				pid=$(ps -ef|grep -w "$1"|grep java|awk '{if($0!~/grep|admin/)print $2}')
				if [ -n "$pid" ];then
					if [ $i = 16 ];then
						kill "$pid"
						sleep 1
					else
						if [ $i = 17 ];then
							echo ERROR: $1 is stop fail !
							break 1
						else
							kill  "$pid"
							sleep 2
						fi
					fi

				else
					echo $1 is stoped !
					break 1
				fi
			done
        fi

        if [ "$type" = "1" ];then
			for ((i=1;i<=20;i++))
			do
				pid=$(ps -ef|grep -w "$1"-0.0.1.jar|grep java|awk '{if($0!~/grep|catalina.sh|cronolog|admin/)print $2}')
				if [ -n "$pid" ];then
					if [ $i = 16 ];then
						kill -9 "$pid"
						sleep 1
					else
						if [ $i = 17 ];then
							echo ERROR: $1 is stop fail !
							break 1
						else
							kill "$pid"
							sleep 2
						fi
					fi

				else
					echo $1 is stoped !
					break 1
				fi
			done
		fi
}

status(){
        GetType $1
        if [ "$type" = "0" ];then
            echo "$1 服务不存在"
            return
        fi

        if [ "$type" = "1" ];then
            pid=$(ps -ef|grep -w "$1"-0.0.1.jar|grep java|awk '{if($0!~/grep|admin/)print $2}')
            if [ -n "$pid" ];then
	    	pidtime=`ps -p $pid -o lstart`
                echo $1 'is running! Pid:' "$pid" Time: $pidtime
                return 0
            else
                echo $1 is not running !
                return 1
            fi
        fi

        if [ "$type" = "2" ];then
	    pid=$(ps -ef|grep -w "$1"|grep java|awk '{if($0!~/grep|catalina.sh|cronolog|admin/)print $2}')
            if [ -n "$pid" ];then
	    	pidtime=`ps -p $pid -o lstart`
                echo $1 'is running! Pid:' "$pid" Time: $pidtime Project:`ls $sdir/"$1"/webapps/|grep -v .war`
                return 0
            else
                echo $1 is not running !
                return 1
            fi
        fi
}

GetType(){
       #type 0:other 1:spring 2:tomcat
        if [ -e "$sdir/"$1"/"$1"-0.0.1.jar" ];then
            type=1
        elif [ -e "$sdir/"$1"/webapps" ];then
            type=2
        else
            type=0
        fi
}


case "$1" in


    start)
        if [ "$2" = "all" ];then
                for e in $LS
                do
                        start $e
                done
        else
                start $2
        fi
        ;;
    stop)
        if [ "$2" = "all" ];then
                for e in $LS
                do
                        stop $e
                done
        else
                stop $2
        fi
        ;;
    status)
        if [ "$2" = "all" ];then
                for e in $LS
                do
                        status $e
                done
        else
                status $2
        fi
        ;;
    restart)
        if [ "$2" = "all" ];then
                for e in $LS
                do
                        stop $e
			sleep 3
			start $e
                done
        else
                stop $2
		sleep 3
		start $2
        fi
        ;;
    *)
        echo $"Usage: $0 {start|stop|status} {servicename|all}"
esac
