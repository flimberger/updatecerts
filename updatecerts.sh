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
# Copy all changed certificates from a source directory into a target directory.

set -eu
umask 0022
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# configuration
certs_dest_dir=/usr/local/etc/ssl
certs_src_dir=/data/ssl
services="dovecot nginx postfix"

_logger="/usr/bin/logger -t updatecerts"

restart_required=false

safecopy()
{
	src="$1"
	dest="$2"
	cp -a "$src" "$dest.new"
	mv "$dest.new" "$dest"
}

$_logger starting

for src in "$certs_src_dir"/*; do
	cert="$(basename "$src")"
	targ="$certs_dest_dir/$cert"
	if [ -f "$targ" ]; then
		diff="$(diff "$src" "$targ")"
		if [ "${diff}x" != x ]; then
			$_logger updating cert "$targ"
			safecopy "$src" "$targ"
			restart_required=true
		fi
	else
		$_logger installing new cert "$targ"
		safecopy "$src" "$targ"
		restart_required=true
	fi
done

if [ "$restart_required" = true ]; then
	for svc in $services; do
		if [ -f "/usr/local/etc/rc.d/$svc" ]; then
			$_logger restarting service "$svc"
			service "$svc" restart
		fi
	done
fi
