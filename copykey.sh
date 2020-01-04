#!/bin/sh -
#
# Copyright (c) 2019 Florian Limberger <flo@purplekraken.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Copy the certificate key from the certs jail to a target jail.

set -eu
umask 0022
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

usage()
{
	echo "usage: copykey.sh domain target" >&2
	exit 1
}

if [ $# -lt 2 ]; then
	usage
fi

domain="$1"
jail="$2"

certs_jail_root=/zroot/iocage/jails/certs/root
certs_dir=/var/db/acme/certs
target_jail_root="/zroot/iocage/jails/$jail/root"
ssl_dir=/usr/local/ssl

if [ ! -d "$target_jail_root/$ssl_dir"]; then
	mkdir -p "$target_jail_root/$ssl_dir"
fi

cp "$certs_jail_root/$certs_dir/*.$domain/*.$domain.key" \
    "$target_jail_root/$ssl_dir/$domain.key"
