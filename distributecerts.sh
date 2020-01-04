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
		if diff "$src" "$dest" >/dev/null; then
			$logger "skip $src -> $dest"
			return
		fi
	fi
	$logger "copy $src -> $dest"
	$sudo cp -a "$src" "$dest"
}

certs=$(ls "$srcdir")
$logger "available certs: $certs"
for cert in $certs; do
	dir="$srcdir/$cert"
	$logger "processing $dir"

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
	if grep '^Le_API.*staging' "$dir/${domain}.conf" >/dev/null; then
		$logger "skipping staging cert for $domain"
		continue
	fi

	$logger "copying certs for $domain"
	copymod "$dir/ca.cer" "$destdir/${name}.ca.cer"
	copymod "$dir/${domain}.cer" "$destdir/${name}.cer"
	copymod "$dir/fullchain.cer" "$destdir/${name}.fullchain.cer"
done
