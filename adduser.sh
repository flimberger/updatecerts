#!/bin/sh
set -eu
uid=443

pw useradd \
	-n certmgr \
	-u "$uid" \
	-d / \
	-s /bin/sh
