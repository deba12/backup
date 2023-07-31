#!/bin/bash

dirname="$(dirname "$0")";

cd "$dirname" || exit 255;

. "$dirname/include.sh"

if [ ! "$2" ]; then
    echo "Missing second argument extract path"
    exit 2
fi

if [ ! "$3" ]; then
    echo "Missing third argument archive"
    exit 2
fi

cd "$2" || exit 2;

borg extract ::"${3}"
