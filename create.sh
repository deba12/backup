#!/bin/bash

dirname="$(dirname "$0")";

status=0

trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

. "$dirname/include.sh"

NOW=$(date +"%Y%m%d%H%M%S");

# Run Borg
borg check --repository-only
if [ $? -eq 2 ]; then
    echo "trying to init"
    ${BORG_RSH} "${CONNECTION_STRING}" test -d "${REPO_PATH}"
    if ! ${BORG_RSH} "${CONNECTION_STRING}" test -d "${REPO_PATH}"; then
        ${BORG_RSH} "${CONNECTION_STRING}" mkdir -p "${REPO_PATH}"
    fi
    borg init --encryption repokey
fi

echo "Starting backup"
CMD="borg create --compression ${BORG_COMPRESSION} --exclude-caches"

for pattern in $PATTERNS_TO_EXCLUDE
do
    CMD=${CMD}" --exclude '${pattern}'"
done

CMD=${CMD}" ::'${PROJECT_NAME}-${NOW}'"

for dir in $DIRECTORIES_TO_BACKUP
do
    CMD=${CMD}" ${dir}"
done

echo "$CMD"

if [ -n "${EXEC_BEFORE}" ]; then
    echo "Executing before backup: ${EXEC_BEFORE}"
    eval "$EXEC_BEFORE"
    echo "Done executing before backup"
fi

eval "$CMD"

backup_exit=$?

if [ ${backup_exit} -ne 0 ]; then
    echo "Backup failed"
    if [ -n "${EXEC_ON_ERROR}" ]; then
        echo "Executing on error: ${EXEC_ON_ERROR}"
        eval "$EXEC_ON_ERROR"
        echo "Done executing after error"
    fi
else
    echo "Backup finished successfully"
    if [ -n "${EXEC_AFTER}" ]; then
        echo "Executing after backup:  ${EXEC_AFTER}"
        eval "$EXEC_AFTER"
        echo "Done executing after backup"
    fi
fi

echo "Pruning repository"

CMD="borg prune --glob-archives '${PROJECT_NAME}-*' --keep-daily ${BORG_KEEP_DAILY}"

if [ "$BORG_KEEP_WEEKLY" -gt 0 ]; then
    CMD=${CMD}" --keep-weekly ${BORG_KEEP_WEEKLY}"
fi
if [ "$BORG_KEEP_MONTHLY" -gt 0 ]; then
    CMD=${CMD}" --keep-monthly ${BORG_KEEP_MONTHLY}"
fi

echo "$CMD"
eval "$CMD"
prune_exit=$?

project_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${project_exit} -eq 0 ]; then
    echo "${PROJECT_NAME} - Backup and Prune finished successfully"
elif [ ${project_exit} -eq 1 ]; then
    echo "${PROJECT_NAME} - Backup and/or Prune finished with warnings"
else
    echo "${PROJECT_NAME} - Backup and/or Prune finished with errors"
fi

status=$(( project_exit > status ? project_exit : status ))

echo "Done"

exit ${status}
