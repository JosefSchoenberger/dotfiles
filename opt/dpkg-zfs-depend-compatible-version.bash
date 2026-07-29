#!/usr/bin/bash

LOGFILE="/var/log/dpkg-depend-compatible-version.log"
log() {
	echo "$(date +'[%Y-%m-%d %H:%M:%S]') $1" >>"$LOGFILE"
}

while read -r deb_path; do
    [[ "$deb_path" == */zfs-dkms_* ]] || continue

    t=/tmp/$(basename "$deb_path" .deb)
	if ! dpkg-deb -R "$deb_path" "$t"; then
		log "Could not extract $deb_path"
		continue
	fi

	maxLinux="$(awk '/^Linux-Maximum:/{split($2,v,".");print v[1]"."v[2]+1}' "$t"/usr/src/*/META)"

	if ! [[ "$maxLinux" =~ ^[0-9]+\.[0-9]+$ ]]; then
		log "Linux-Maximum in $deb_path's /usr/src/*/META is malformed? maxLinux=$maxLinux, which does not match [0-9]+\.[0-9]+"
		exit 1
	fi
	log "Adding dependency of $deb_path to linux-image-amd64 (<< $maxLinux)"

    sed -i '/^Depends:/{/linux-image-amd64/!s/$/, linux-image-amd64 (<< '"$maxLinux"'~)/};/^Version:/s/$/+/' "$t/DEBIAN/control"
    dpkg-deb -b "$t" "$deb_path"
    rm -r "$t"
done
