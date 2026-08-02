#!/bin/bash

if ! compgen -G "/tmp/allocation-expiry-notification-id-*" >/dev/null; then
	# if there are no allocations right now, only check every ten minutes.
	[ "$(($(date +'6%M%%10')))" == 0 ] || exit 0
fi

allocations_json="$(ssh coinbase -- 'pos calendar list -j')" || ( echo "Error: Could not receive JSON from coinbase" >&2; exit 1 )

my_allocations_json="$(jq '[.[] | select(.owner == "schoenbj")]' <<<"$allocations_json")" || ( echo "Error: Could not parse JSON from coinbase" >&2; exit 2 )



expiry_infos="$(jq '.[]
		| [
			.id,
			.end_date,
			(.end_date | strptime("%Y-%m-%d %H:%M:%S") | mktime)
				- (now + 3600*2 | (. | localtime)[3] - (. | gmtime)[3] | (.+24)%24*3600),
			(.nodes | join("+")),
			(. | @text)
		] | @tsv' -r <<<"$my_allocations_json")" \
	|| ( echo "Could extract allocation info from JSON" >&2; exit 3)
now="$(date +%s)"

expiring_ids=""

while IFS=$'\t' read -r id endstr end nodes json; do
	[ -z "$id" ] && break

	filename="/tmp/allocation-expiry-notification-id-$id"
	if [[ "$((end - 1800))" -lt "$now" ]] && [ "$end" -gt "$((now - 10))" ]; then

		replace_id=""
		if [ -r "$filename" ]; then
			replace_id="$(jq '.replace_id' "$filename")" || replace_id=""
			[ "$replace_id" != "null" ] || replace_id=""
		fi

		if [ -n "$replace_id" ]; then
			notification_id=$(notify-send -p -i gtk-dialog-warning "Alloc $nodes expiring soon" "Allocation $id expiring at $endstr (in ~$(((end - now)/60)) min)!" -r "$replace_id")
		else
			notification_id=$(notify-send -p -i gtk-dialog-warning "Alloc $nodes expiring soon" "Allocation $id expiring at $endstr (in ~$(((end - now)/60)) min)!")
		fi

		echo "$json" | jq ". + {replace_id: $notification_id}" >"$filename"

		expiring_ids="$expiring_ids,$id"
	else
		echo "$json" | jq "." >"$filename"
	fi

	expiring_ids="$expiring_ids,$id"
done <<<"$expiry_infos"

find /tmp -maxdepth 1 -name 'allocation-expiry-notification-id-*' -printf "%f\0" | while read -r -d $'\0' file; do
	[ -z "$file" ] && break
	id=${file#allocation-expiry-notification-id-}
	[[ "$expiring_ids," == *",$id,"* ]] && continue

	expiry_infos="$(jq '[
							.id,
							.end_date,
							(.end_date | strptime("%Y-%m-%d %H:%M:%S") | mktime) - (now + 3600*2 | (. | localtime)[3] - (. | gmtime)[3] | (.+24)%24*3600),
							(.nodes | join("+")),
							.replace_id
						] | @tsv' -r <"/tmp/$file")"

	IFS=$'\t' read -r jid endstr end nodes replace_id <<<"$expiry_infos"
	[ "$jid" != "$id" ] && continue

	if [ -z "$replace_id" ] || [ "$replace_id" = "null" ]; then
		continue
	fi

	if [ "$end" -lt "$((now + 300))" ]; then
		notification_id=$(notify-send -p -i gtk-dialog-warning "Allocation of $nodes exired" "Allocation $id expired at $endstr." -r "$replace_id")
	else
		notify-send "" -r "$replace_id" -t 1
	fi
	rm "/tmp/$file"
done
