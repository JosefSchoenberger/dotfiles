#!/bin/bash

if [ -e /etc/wsl.conf ] && command -v wslpath >/dev/null ; then
	if [[ "$1" =~ ^/ ]] || ! [ -e "$1" ]; then
		set -- "$(wslpath -w "$1")" "${@:2}"
	fi

	exec "/mnt/c/Program Files/Mozilla Firefox/firefox.exe" "$@"
else
	exec firefox.exe "$@"
fi
