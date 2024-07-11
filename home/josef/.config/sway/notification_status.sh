# $1 -> ID (e.g. "brightness", so that multiple notification status notifications can coexist)
# $2 -> Text
show_notification_status() {
	if [ "$#" != "2" ]; then
		echo "Must have two args, having $@"
		return 2
	fi

	P="/run/user/${UID}/${1}-notification-replacement-id"

	REPLACE_ID=""
	if [ -s "$P" ]; then
		REPLACE_ID="-r $(cat "$P")"
	fi

	NEW_ID="$(notify-send -p $REPLACE_ID -t 1500 "$2")" || return

	[ -n "$NEW_ID" ] &&	echo "$NEW_ID" >"$P"
}
