#!/bin/env bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

# shellcheck disable=SC2043
for config in output-configs; do
	# Only update if the file has changed
	sha256sum --status -c "${config}.sum" && continue

	echo "Updating ${config}"

	(
	set -e
	# Create new key
	openssl rand -base64 32 >"${config}.key"
	# Encrypt config file with new key
	openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -pass "file:./${config}.key" -in "${config}" -out "${config}.enc"
	# Encrypt the symmetrical encrytion key with the public key
	openssl pkeyutl -encrypt -pubin -inkey public.pem -in "${config}.key" -out "${config}.key.enc"
	) || continue
	# Remove the sym. encryption key
	shred -u "${config}.key" || rm -f "${config}.key"

	# Upate the checksum for detecting modifications
	sha256sum "${config}" >"${config}.sum"
done
