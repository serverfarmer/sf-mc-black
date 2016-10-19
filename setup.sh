#!/bin/bash
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.custom



setup_midnight_commander_for_user() {
	file=$1
	path=$2
	user=$3
	group=`id -gn $user`
	home=`getent passwd $user |cut -d: -f 6`

	if [ "$OSTYPE" = "netbsd" ]; then
		wrapper=/usr/pkg/libexec/mc/mc-wrapper.sh
	else
		wrapper=/usr/share/mc/bin/mc-wrapper.sh
	fi

	if [ -d $home ]; then
		mkdir -p `dirname $home/$path`
		cp -f $file $home/$path
		chown $user:$group $home/$path

		rc=$home/.bashrc

		if [ ! -f $rc ]; then
			touch $rc
		fi

		if [ "`grep 'alias mc' $rc`" = "" ] && [ -f $wrapper ]; then
			echo >>$rc
			echo "alias mc='. $wrapper'" >>$rc
		fi

		if [ "`grep mcedit $rc`" = "" ]; then
			echo >>$rc
			echo "export EDITOR=mcedit" >>$rc
		fi
	fi
}


base=/opt/farm/ext/mc-black/templates/$OSVER

if [ -f $base/mc.ini ]; then
	echo "setting up midnight commander profiles"

	if [ -f $base/mc.skin ]; then
		if [ "$OSTYPE" = "netbsd" ]; then
			cp -f $base/mc.skin /usr/pkg/share/mc/skins/wheezy.ini
		else
			cp -f $base/mc.skin /usr/share/mc/skins/wheezy.ini
		fi
	fi

	if [ "`grep -Fx $OSVER /opt/farm/ext/mc-black/newpaths.conf`" != "" ]; then
		SUB=".config/mc/ini"
	else
		SUB=".mc/ini"
	fi

	setup_midnight_commander_for_user $base/mc.ini $SUB root

	if [ "`getent passwd ubuntu`" != "" ]; then
		setup_midnight_commander_for_user $base/mc.ini $SUB ubuntu
	fi

	ADMIN=`primary_admin_account`
	if [ "`getent passwd $ADMIN`" != "" ]; then
		setup_midnight_commander_for_user $base/mc.ini $SUB $ADMIN
	fi
fi


loc="/usr/share/locale/pl/LC_MESSAGES"

if [ -f $loc/mc.mo ]; then
	echo "disabling midnight commander polish translation"
	mv $loc/mc.mo $loc/midc.mo
fi
