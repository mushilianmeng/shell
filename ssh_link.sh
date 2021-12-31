/bin/bash
source /etc/profile
source ~/.bash_profile
#ssh隧道原理请见
#https://blog.7890.ink/2021/07/02/%e6%90%ad%e5%bb%ba%e7%a8%b3%e5%ae%9a%e7%9a%84ssh%e9%9a%a7%e9%81%93.html
remotesship=10.0.0.211 #这里填写远端 ssh ip
remoteshport=1102 #这里填写远端 ssh port
ssh_link(){
        while true
        do
                ssh -o ServerAliveInterval=30 -CnNT -R $1:$2:$3 root@$remotesship -p $remoteshport
        done
}
ssh_link 38080 10.0.0.129 8080 >/dev/null 2>&1 &
ssh_link 38088 10.0.150.227 443 >/dev/null 2>&1 &
ssh_link 31023 127.0.0.1 9091 >/dev/null 2>&1 &