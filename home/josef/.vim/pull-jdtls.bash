#!/usr/bin/env bash

MILESTONE="1.60.0"

fail() {
	echo $'\e[31mError:\e[39m' "$1" >&2
	exit 1
}


[ -d /opt/jdtls ] || mkdir -p /opt/jdtls || fail "Could not create /opt/jdtls. Exiting."

cd /opt/jdtls || fail "Could not cd into /opt/jdtls. Exiting."

latest_version=$(curl -sSLf "https://download.eclipse.org/jdtls/milestones/$MILESTONE/latest.txt") || fail "Could not pull latest version: $latest_version. Exiting."
sha256="$(curl -sSLf "https://download.eclipse.org/jdtls/milestones/$MILESTONE/$latest_version.sha256")" || fail "Could not pull sha256 sum: $sha256. Exiting."

if ! sha256sum --status --quiet --strict --check <(echo "$(tr -d '\n' <<<"sha256")  $latest_version") >/dev/null 2>&1; then
	echo "Pulling $latest_version..."
	curl -SLf "https://download.eclipse.org/jdtls/milestones/$MILESTONE/$latest_version" -O || fail "Could not pull $latest_version. Exiting."
else
	echo "jdtls is already at the latest version (${latest_version%.tar.gz})."
fi

rm -rf "./jdtls-$MILESTONE"
mkdir -p "./jdtls-$MILESTONE"
tar -xzf "$latest_version" -C "./jdtls-$MILESTONE"

rm -rf "./jdtls-current"
ln -s "./jdtls-$MILESTONE" "./jdtls-current"
