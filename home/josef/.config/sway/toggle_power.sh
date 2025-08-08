#!/bin/bash

. /home/josef/.config/sway/notification_status.sh

show_notification_status powerprofile "Power-Profile: ..."

if [ -d /sys/fs/cgroup/blocker ]; then
	MODE=normal
	#sudo /opt/unleash_the_power.sh
	sudo /opt/set_power_profile.sh normal
else
	MODE="save power"
	#sudo /opt/save_power.sh
	sudo /opt/set_power_profile.sh save
fi

show_notification_status powerprofile "Power-Profile: $MODE"
