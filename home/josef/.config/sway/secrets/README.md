> Maybe, just maybe, let's not add all monitors including the location and serial numbers to a public repository...

But I still want to backup my config without much work.
So: My Sway config automatically encrypts the config file so that I only need to add the encrypted file in Git.
This uses public key cryptography: Sway will not need my password.
But once I move to a new machine, I can decrypt my private key with a password and thereby decrypt my configuration.

-- 
### Add new secret file
Add the filename to .gitignore in this secrets directory and the for loop in unpack.sh and update-secrets.sh.

### Setup on a new machine
See ./unpack.sh.

### Create new version of config file
See ./update-secrets.sh.

