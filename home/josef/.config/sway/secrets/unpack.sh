#!/bin/sh

# Decrypt the private key with my password
openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in private.pem.enc -out private.pem

# shellcheck disable=SC2043
for config in output-configs; do
    # Decrypt the sym. encryption key of the file
    openssl pkeyutl -decrypt -inkey private.pem -in "${config}.key.enc" -out "${config}.key"
    # Decrypt the config file with the key
    openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -pass "file:./${config}.key" -in "${config}.enc" -out "${config}"
    # Remove the sym. encryption key
    shred -u "${config}.key" || rm -f "${config}.key"

	sha256sum "${config}" >"${config}.sum"
done
shred -u private.pem || rm -f private.pem
