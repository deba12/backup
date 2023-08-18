# Borg backup automation

## Installation
```shell
apt-get update
apt-get --no-install-recommends install borgbackup
```

## Configuration
* If you don't have ssh key, go generate one
```shell
ssh-keygen -t ed25519 -C "my-backup-key"
```
* Copy public key to remote server
```shell
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@hostname
```
* Example config
```shell
#### REQUIRED
export PROJECT_NAME=project
export CONNECTION_STRING=user@host.com
export REPO_PATH=backup/project
export BORG_REPO=${CONNECTION_STRING}:${REPO_PATH}
# Its important to remember this passphrase or you are risking to lose all your backups
export BORG_PASSPHRASE=test123
export BORG_RSH="ssh -i ~/.ssh/id_ed25519"
export BORG_KEEP_DAILY=7

# Execute following before running backup //e.g. dump sql, stop service
# As example: export EXEC_BEFORE="mysqldump -all-databases > /tmp/dump.sql"
export EXEC_BEFORE=""

# Execute following after running backup //e.g. start service
# As example: export EXEC_AFTER="echo backup done | mail user@mail -s 'backup done'"
export EXEC_AFTER=""

# Execute following on error //e.g. send email
# As example: export EXEC_ON_ERROR="echo backup error | mail user@mail -s 'backup error'"
export EXEC_ON_ERROR=""

# space delimited list of directories with absolute path or relative to create_backup.sh
export DIRECTORIES_TO_BACKUP=""
# space delimited list of patterns to exclude from backup
export PATTERNS_TO_EXCLUDE=""

# how many weekly backups to keep. Set to 0 to skip weekly backups.
export BORG_KEEP_WEEKLY=4
# how many monthly backups to keep. Set to 0 to skip monthly backups.
export BORG_KEEP_MONTHLY=6

# This have to be removed when copied in project folder
echo "Remove me"
exit 2
#### END REQUIRED

#### OPTIONAL
#export PROJECT_NAME=example
#### END OPTIONAL
```
