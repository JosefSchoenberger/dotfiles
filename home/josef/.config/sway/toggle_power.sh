#!/bin/bash

. /home/josef/.config/sway/notification_status.sh

show_notification_status powerprofile "Power-Profile: ..."

if [ -d /sys/fs/cgroup/blocker ]; then
	MODE=performance
	sudo /opt/unleash_the_power.sh
else
	MODE="save power"
	sudo /opt/save_power.sh
fi

show_notification_status powerprofile "Power-Profile: $MODE"
