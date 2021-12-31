##/bin/bash
source /etc/profile
source ~/.bash_profile
cd /data/script
i=`cat update_shell.txt | grep http: | wc -l`
if [ $i -eq 1 ];then
	update_shell_1=`cat update_shell.txt | awk -F":" '{print $1}'`
	update_shell_2=`cat update_shell.txt | awk -F":" '{print $2}'`
	sed -i 's#'''$update_shell_1''':'''$update_shell_2'''#'''$update_shell_1'''s:'''$update_shell_2'''#g' update_shell.txt
fi
update_dizhi=`cat update_shell.txt | head -n 1 | tail -n 1`
wget --user=anso --password=J8ka5kgtRmnDVuwm --no-check-certificate "$update_dizhi""update.txt" -O update.txt
md5sum *.sh>local.txt
update_sl=`diff  local.txt update.txt  | grep ">" | awk -F" " '{print $3}' | wc -l`
for((i=1;i<=$update_sl;i++));
do
        #echo $i;
        update_bash=`diff  local.txt update.txt  | grep ">" | awk -F" " '{print $3}' | head -n $i | tail -n 1`
        wget --user=anso --password=J8ka5kgtRmnDVuwm --no-check-certificate "$update_dizhi""$update_bash" -O $update_bash
done
