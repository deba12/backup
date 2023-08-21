
# cleanup first
unset PROJECT_NAME
unset CONNECTION_STRING
unset REPO_PATH
unset DIRECTORIES_TO_BACKUP
unset PATTERNS_TO_EXCLUDE
unset BORG_REPO
unset BORG_PASSPHRASE
unset BORG_RSH
unset BORG_KEEP_DAILY
unset BORG_KEEP_WEEKLY
unset BORG_KEEP_MONTHLY
unset BORG_COMPRESSION

if [ ! "$1" ]; then
    echo "Missing first argument - project conf"
    exit 2
fi

# test can we read file in current directory
if [ -r "./$1" ]; then
    # shellcheck disable=SC1090
    . "./$1"
else
    # test can we read file in specified path
    if [ -r "${dirname}"/"$1" ]; then
        # shellcheck disable=SC1090
        . "${dirname}"/"$1"
    else
        echo "File $1 does not exist"
        exit 2
    fi
fi

borg=$(which borg)
if [ -z "$borg" ]; then
    echo "borg is not installed"
    exit 2
fi

# check config variables

if [ ! "$PROJECT_NAME" ]; then
    filename="$(basename "$1")"
    export PROJECT_NAME="${filename%.*}"
fi

if [ ! "$CONNECTION_STRING" ]; then
    echo "CONNECTION_STRING is not set"
    exit 2
fi

if [ ! "$REPO_PATH" ]; then
    echo "REPO_PATH is not set"
    exit 2
fi

if [ ! "$BORG_REPO" ]; then
    echo "BORG_REPO is not set"
    exit 2
fi

if [ ! "$BORG_PASSPHRASE" ]; then
    echo "BORG_PASSPHRASE is not set"
    exit 2
fi

if [ ! "$DIRECTORIES_TO_BACKUP" ]; then
    echo "DIRECTORIES_TO_BACKUP is not set"
    exit 2
fi

if [ ! "$PATTERNS_TO_EXCLUDE" ]; then
    export PATTERNS_TO_EXCLUDE=""
fi

if [ ! "$BORG_RSH" ]; then
    export BORG_RSH="ssh -i ~/.ssh/id_rsa"
fi

if [ ! "$BORG_KEEP_DAILY" ]; then
    export BORG_KEEP_DAILY=7
fi

if [ ! "$BORG_KEEP_WEEKLY" ]; then
    export BORG_KEEP_WEEKLY=4
fi

if [ ! "$BORG_KEEP_MONTHLY" ]; then
    export BORG_KEEP_MONTHLY=6
fi

if [ ! "$BORG_COMPRESSION" ]; then
    export BORG_COMPRESSION="zstd"
fi
