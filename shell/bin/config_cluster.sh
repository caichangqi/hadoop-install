#!/bin/bash

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

PASSWORD="redhat"
HOSTNAME=`hostname -f`
NODES_FILE=$PROGDIR/../conf/nodes
NODES="`cat $NODES_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

#设置无密码登陆
echo -e "[INFO]:Config ssh on manager"
[ ! -d ~/.ssh ] && ( mkdir ~/.ssh ) && ( chmod 600 ~/.ssh )
[ ! -f ~/.ssh/id_rsa.pub ] && (yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "") && ( chmod 600 ~/.ssh/id_rsa.pub )

echo "[INFO]:Config ssh nopassword for cluster"
for node in $NODES ;do
	$PROGDIR/ssh_nopassword.expect $node $PASSWORD >/dev/null 2>&1
done

echo "[INFO]:Config yum for cluster"
pscp -H "$NODES" /etc/yum.repos.d/*.repo /etc/yum.repos.d/

pssh -i -H "$NODES"  "`cat $PROGDIR/config_system.sh`"

echo "[INFO]:Config ntp for cluster"
$PROGDIR/config_ntp.sh
