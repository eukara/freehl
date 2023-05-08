#!/bin/sh

# all new script that dumps the Half-Life: Game of the Year edition
# data onto your hard disk. make sure you have the CD-ROM inserted!

# pass HLDIR to tell it where to put the Half-Life files to.
# e.g. HLDIR=/tmp/Half-Life
# otherwise, it'll put it into the parent dir, of the working directory.

# pass TMPDIR to tell it where to put temporary install files to.
# e.g. TMPDIR=/tmp/gotycd
# otherwise, it'll put it into the current working directory.

set -e

SETUP_SHA256="3b2b35e27aa7c54bedd39dd0074193dfcba9a3054623e93fc29f8f71779b082b"
TMPDIR="$(pwd)/tmp"

# allow user override
if [ -z "$CDROM_PATH" ]
then
	CDROM_PATH="/mnt/cdrom"
	SETUP_FILE="$CDROM_PATH/setup.exe"
fi
if [ -z "$HLDIR" ]
then
	HLDIR="$(pwd)/.."
fi
if [ -z "$TMPDIR" ]
then
	TMPDIR="$(pwd)/tmp"
fi

if [ "$1" = "-h" ]
then
	printf "%s help\n\n" "$(basename $0)"
	printf "pass HLDIR to tell it where to put the Half-Life files to.\n"
	printf "e.g. HLDIR=/tmp/Half-Life.\n"
	printf "otherwise, it'll put it into the parent dir, of the working directory\n\n"

	printf "pass TMPDIR to tell it where to put temporary install files to.\n"
	printf "e.g. TMPDIR=/tmp/gotycd.\n"
	printf "otherwise, it'll put it into the current working directory.\n\n"

	printf "HLDIR will require at least 356M disk space.\n"
	printf "TMPDIR will require at least 462M disk space.\n"
	exit 0
fi

if [ ! -x "$(command -v rewise)" ]
then
	printf "rewise is not present. please build it and place it in PATH.\n"
	printf "src: https://notabug.org/CYBERDEViL/REWise\n"
	exit 2
fi

if [ ! -f "$SETUP_FILE" ]
then
	printf "Please mount the Game of the Year edition CD-ROM.\n"
	exit 2
fi

if [ -x "$(command -v sha256sum)" ]
then
	CHECK=$(sha256sum "$SETUP_FILE" | awk '{ print $1 }')
elif [ -x "$(command -v sha256)" ]
then
	CHECK=$(sha256 -q "$SETUP_FILE")
else
	printf "No tool to validate sha256 sums with!\n"
	exit 2
fi

if [ ! "$CHECK" = "$SETUP_SHA256" ]
then
	printf "%s checksum mismatch.\n" "$SETUP_FILE"
	exit 2
fi

if [ -d "$TMPDIR" ]
then
	rm -rf "$TMPDIR"
fi

mkdir -p "$TMPDIR"
rewise -x "$TMPDIR" "$SETUP_FILE" &> /dev/null

# traverse the tmpdir, move files into the output location
while read LINE
do
	FILE=$(printf "$LINE" | awk '{ print $2 }')
	TMPFILE="$TMPDIR/MAINDIR/$FILE"
	mkdir -p "$HLDIR/$(dirname $FILE)"
	cp "$TMPFILE" "$HLDIR/$FILE"
done < "install_from_cd_goty.sha256"