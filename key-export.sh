#!/bin/bash

dirname="$(dirname "$0")";

. "$dirname/include.sh"

borg key export
