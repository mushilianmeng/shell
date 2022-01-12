#/bin/bash
source /etc/profile
source ~/.bash_profile
#ssh隧道原理请见
#https://blog.7890.ink/2021/07/02/%e6%90%ad%e5%bb%ba%e7%a8%b3%e5%ae%9a%e7%9a%84ssh%e9%9a%a7%e9%81%93.html
remotesship=anso_x1.ansosz.com #这里填写远端 ssh ip
remoteshport=16122 #这里填写远端 ssh port

ssh_link(){
        while true
        do
                ssh -o ServerAliveInterval=30 -CnNT -R $1:$2:$3 root@$remotesship -p $remoteshport
        done
}
ssh_link_jk(){
                while true
                do
                        ssh -p $remoteshport root@$remotesship "netstat -antp | grep 0.0.0.0:$1"
                        if [ $? -eq 0 ];then
                                        sleep 170
                        elif [ $? -eq 1 ];then
                                        ssh_process_id=`ps -ef | grep CnNT | grep $1 | awk -F" " '{print $2}'`
                                        ssh_link_process_id=`ps -ef | grep CnNT | grep $1 | awk -F" " '{print $3}'`
                                        kill $ssh_link_process_id
                                        kill $ssh_process_id
                                        ssh_process_id=`ps -ef | grep CnNT | grep $1 | awk -F" " '{print $2}'`
                                        ssh_link_process_id=`ps -ef | grep CnNT | grep $1 | awk -F" " '{print $3}'`
                                        if [[ ! -n $ssh_process_id ]] && [[ ! -n $ssh_link_process_id ]];then
                                                sleep 1
                                                ssh_link $1 $2 $3 >/dev/null 2>&1 &
                                        fi
                        else
                                        sleep 2
                        fi
                done
}
ssh_link_jk 1067 127.0.0.1 9091 >/dev/null 2>&1 &
ssh_link_jk 1084 172.28.28.102 7180 >/dev/null 2>&1 &
ssh_link_jk 1068 172.28.28.102 22 >/dev/null 2>&1 &
ssh_link_jk 1069 172.28.28.103 22 >/dev/null 2>&1 &
ssh_link_jk 1070 172.28.28.104 22 >/dev/null 2>&1 &
ssh_link_jk 1071 192.168.2.7 16877 >/dev/null 2>&1 &
ssh_link_jk 1072 172.16.1.201 16877 >/dev/null 2>&1 &
ssh_link_jk 1073 172.16.1.200 16877 >/dev/null 2>&1 &
ssh_link_jk 1074 172.28.28.109 22 >/dev/null 2>&1 &
ssh_link_jk 1075 172.28.28.108 22 >/dev/null 2>&1 &
ssh_link_jk 1076 172.28.28.105 22 >/dev/null 2>&1 &
ssh_link_jk 1078 172.28.28.105 1521 >/dev/null 2>&1 &