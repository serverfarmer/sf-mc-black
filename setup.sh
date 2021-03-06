#!/bin/bash
. /opt/farm/scripts/init



setup_midnight_commander_for_user() {
	file=$1
	path=$2
	user=$3
	group=`id -gn $user`
	home=`getent passwd $user |cut -d: -f 6`

	if [ "$OSTYPE" = "freebsd" ]; then
		wrapper=/usr/local/libexec/mc/mc-wrapper.sh
	elif [ "$OSTYPE" = "netbsd" ]; then
		wrapper=/usr/pkg/libexec/mc/mc-wrapper.sh
	elif [ "$OSTYPE" = "suse" ]; then
		wrapper=/usr/share/mc/mc-wrapper.sh
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


/opt/farm/ext/packages/utils/install.sh mc

base=/opt/farm/ext/mc-black/templates/$OSVER

if [ -f $base/mc.ini ]; then
	echo "setting up midnight commander profiles"

	if [ -f $base/mc.skin ]; then
		if [ "$OSTYPE" = "freebsd" ]; then
			cp -f $base/mc.skin /usr/local/share/mc/skins/wheezy.ini
		elif [ "$OSTYPE" = "netbsd" ]; then
			cp -f $base/mc.skin /usr/pkg/share/mc/skins/wheezy.ini
		else
			cp -f $base/mc.skin /usr/share/mc/skins/wheezy.ini
		fi
	fi

	if grep -qFx $OSVER /opt/farm/ext/mc-black/config/oldpaths.conf; then
		SUB=".mc/ini"
	else
		SUB=".config/mc/ini"
	fi

	setup_midnight_commander_for_user $base/mc.ini $SUB root

	if [ "`getent passwd ubuntu`" != "" ]; then
		setup_midnight_commander_for_user $base/mc.ini $SUB ubuntu
	fi

	ADMIN=`/opt/farm/config/get-primary-admin-account.sh`
	if [ "`getent passwd $ADMIN`" != "" ]; then
		setup_midnight_commander_for_user $base/mc.ini $SUB $ADMIN
	fi
fi


loc="/usr/share/locale/pl/LC_MESSAGES"

if [ -f $loc/mc.mo ]; then
	echo "disabling midnight commander polish translation"
	mv $loc/mc.mo $loc/midc.mo
fi
