#!/bin/sh
export LANG="en_US.UTF-8" 
source /etc/profile

#set deploy parameter
project_name="$1"

sdir="/data/service"
project_tmp="/data/project-tmp/$project_name"
deploy_home="$sdir/$project_name"
backup_dir="/data/backup/project"
dirdate=`date +%Y%m%d%H%M%S`
project_backup_dir="$backup_dir/$project_name/$dirdate"

echo  $dirdate >>/tmp/${project_name}.txt

function backupApp(){
        echo 'backup start....'
        if [ -d "$project_backup_dir" ]; then
                echo "backup folder is exist"
        else
                mkdir -p $project_backup_dir
        fi
        `\cp -R $deploy_home/*.jar $project_backup_dir`
        echo 'backup end'
}

function deployApp(){
        echo 'deploy app start...'
	if [ -e $project_tmp/$project_name-*.jar ];then
		if [ ! -d $deploy_home ];then
			mkdir -p $deploy_home	
		fi
		rm -rf $deploy_home/*.jar
		`\cp -R $project_tmp/*.jar $deploy_home/`
		if [ $? -ne 0 ];then
			echo "ERROR: Copy jar fail ！！！"
			exit 1
		else
			rm -f $project_tmp/*.jar
		fi
	else
		echo "ERROR: jar not exist ！！！"
		exit 1
	fi
	
        echo 'deploy app end...'
}




backupApp
sh /data/script/auto.sh stop $project_name
deployApp
sh /data/script/auto.sh start $project_name
