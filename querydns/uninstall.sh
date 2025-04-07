#!/bin/sh
eval $(dbus export querydns_)
source /koolshare/scripts/base.sh

find /koolshare/init.d/ -name "*querydns*" | xargs rm -rf
rm -rf /koolshare/bin/querydns 2>/dev/null
rm -rf /tmp/querydns 2>/dev/null
rm -rf /koolshare/res/icon-querydns.png 2>/dev/null
rm -rf /koolshare/scripts/querydns*.sh 2>/dev/null
rm -rf /koolshare/webs/Module_querydns.asp 2>/dev/null
rm -rf /koolshare/scripts/querydns_install.sh 2>/dev/null
rm -rf /koolshare/scripts/uninstall_querydns.sh 2>/dev/null
rm -rf /koolshare/configs/querydns 2>/dev/null
rm -rf /tmp/upload/querydns* 2>/dev/null

dbus remove querydns_version
dbus remove querydns_binary
dbus remove querydns_check_basic
dbus remove querydns_check_user
dbus remove querydns_parameter_time
dbus remove querydns_parameter_messages
dbus remove querydns_parameter_typea
dbus remove querydns_parameter_type4a
dbus remove querydns_check_domain
dbus remove softcenter_module_querydns_name
dbus remove softcenter_module_querydns_install
dbus remove softcenter_module_querydns_version
dbus remove softcenter_module_querydns_title
dbus remove softcenter_module_querydns_description