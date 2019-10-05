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

srcdir=/var/db/acme/certs
destdir=/data/ssl

logger="/usr/bin/logger -t distributecerts"
sudo=/usr/local/bin/sudo

$logger starting

# Copies file only if the source was updated
copymod()
{
	src="$1"
	dest="$2"

	if [ -f "$dest" ]; then
		diff="$(diff "$src" "$dest")"
		if [ "${diff}x" = x ]; then
			exit
		fi
	else
		$logger "copy $src -> $dest"
		$sudo cp -a "$src" "$dest"
	fi
}

for dir in "$srcdir"/*; do
	if [ ! -d "$dir" ]; then
		$logger "fatal $dir missing"
		exit 1
	fi

	# ECC certificates end with "_ecc", which must be removed
	domain="$(basename "$dir" | sed 's/_ecc$//')"
	# Wildcard certificates start with "*.", which I don't want for the
	# distributed certs
	name="$(printf %s\\n "$domain" | sed 's/^\*\.//')"

	# Skip staging certicates
	if grep '^Le_API.*staging' "$dir/${domain}.conf"; then
		$logger "skipping staging cert for $domain"
		continue
	fi

	copymod "$dir/ca.cer" "$destdir/${name}.ca.cer"
	copymod "$dir/${domain}.cer" "$destdir/${name}.cer"
	copymod "$dir/fullchain.cer" "$destdir/${name}.fullchain.cer"
done
