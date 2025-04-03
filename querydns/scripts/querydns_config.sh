#!/bin/sh

source /koolshare/scripts/base.sh
eval $(dbus export querydns_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/querydns_log.txt
LOCK_FILE=/var/lock/querydns.lock

set_lock(){
	exec 999>${LOCK_FILE}
	flock -n 999 || {
		# bring back to original log
		http_response "$ACTION"
		exit 1
	}
}

unset_lock(){
	flock -u 999
	rm -rf ${LOCK_FILE}
}

close_querydns_process(){
	querydns_process=$(pidof querydns)
	if [ -n "${querydns_process}" ]; then
		echo_date "⛔关闭querydns进程..."
		killall querydns >/dev/null 2>&1
		kill -9 "${querydns_process}" >/dev/null 2>&1
	fi
}
save_user_dns(){
	if [ -n "$count" ];then
	i=0
	while [ "$i" -lt "$count" ]
	do
		txt=${querydns_uesr_domain_content_$i}
		#开始拼接文件值，然后进行base64解码，写回文件
		content=${content}${txt}
		let i=i+1
	done
	echo $content| base64_decode > /tmp/querydns_user.txt
	if [ -f /tmp/querydns_user.txt ]; then
		cat /tmp/querydns_user.txt | urldecode > /koolshare/configs/querydns/user_dns.txt 2>&1
		rm -rf /tmp/querydns_user.txt
	fi
	#dbus remove jdqd_jd_script_content_custom
	customs=`dbus list querydns_uesr_domain_content_ | cut -d "=" -f 1`
	for custom in $customs
	do
		dbus remove $custom
	done
fi

}

check_dns() {
	domain="${querydns_check_domain}"
	# 根据 dbus 参数值拼接命令选项
	command=""
	if [ "${querydns_parameter_time}" -eq 1 ]; then
		command=" -S"
		echo_date "🔸显示时间统计"
	fi

	if [ "${querydns_parameter_messages}" -eq 1 ]; then
		command="$command -v"
		echo_date "🔸显示详细日志消息"
	fi

	if [ "${querydns_parameter_typea}" -eq 1 ]; then
		command="$command -t A"
		echo_date "🔸返回IPv4结果"
	fi

	if [ "${querydns_parameter_type4a}" -eq 1 ]; then
		command="$command -t AAAA"
		echo_date "🔸返回IPv6结果"
	fi
	if [ "${querydns_check_basic}" == "1" ]; then
		echo_date "🔍开始查询插件内置常用DNS"
		lines=$(cat /koolshare/configs/querydns/basic_dns.txt | awk '{print $0}')
		for line in $lines
		do
			echo_date "▶️开始查询${line}"
			echo "--------------------------------------------------------------------------------------------"
			querydns @$line $domain $command 2>&1
			echo "--------------------------------------------------------------------------------------------"
		done
	else
		echo_date "🤷‍♂️插件内置常用DNS查询未开启，跳过"
	fi
	userdns_PATH="/koolshare/configs/querydns/user_dns.txt" 
	userdns_size=$(ls -l "$userdns_PATH" 2>/dev/null | awk '{print $5}')
	if [ -f "$userdns_PATH" ] && [ "$userdns_size" -gt 0 ]; then
		echo_date "🔍开始查询用户自定义DNS"
		lines="$(cat /koolshare/configs/querydns/user_dns.txt | awk '{print $0}')"
		for line in $lines
		do
			echo_date "▶️开始查询${line}"
			echo "--------------------------------------------------------------------------------------------"
			querydns @$line $domain $command 2>&1
			echo "--------------------------------------------------------------------------------------------"
		done
	else
		echo_date "🤷‍♂️未检测到用户自定义DNS，跳过"
	fi
	close_querydns_process
}

case $2 in
check)
	set_lock
	rm -rf ${LOG_FILE}
	save_user_dns
    check_dns | tee -a ${LOG_FILE}
    echo DD01N05S | tee -a ${LOG_FILE}
	unset_lock
	;;
esac
