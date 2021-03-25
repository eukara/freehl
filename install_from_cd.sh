#!/bin/sh
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
OUTPK3DIR="pak0_retail.pk3dir"

if ! [ -x "$(command -v unshield)" ]; then
	printf "Error: unshield is not installed.\n" >&2
	exit 1
fi

if ! [ -x "$(command -v rsync)" ]; then
	printf "Error: rsync is not installed.\n" >&2
	exit 1
fi

if ! [ $# -gt 0 ]; then
	printf "Path to MOUNTED CD-ROM folder, e.g. /mnt/cdrom:\n"
	read CDROM_PATH
else
	CDROM_PATH="$1"
fi

if ! [ -f "$CDROM_PATH"/data1.cab ]; then
	printf "Error: data1.cab not found in $CDROM_PATH.\n" >&2
	exit 1
fi

# Grab the cabinet data off the CD
mkdir -p ./tmp
unshield -d ./tmp x "$CDROM_PATH"/data1.cab

# Let's shove them all into a convenient .pk3dir
mkdir -p ./$OUTPK3DIR
mv -v ./tmp/Half-Life_PAK_File/valve/pak0.pak ./$OUTPK3DIR/pak0.pak
rsync -av ./tmp/Half-Life_Program_Files/valve/ ./$OUTPK3DIR/
mv -v ./tmp/Half-Life_Program_Files/media ./$OUTPK3DIR/media
mv -v ./tmp/Half-Life_Program_Files/logos ./$OUTPK3DIR/logos

# Get the latest patch, because that'll fix the menu assets and add more fun, free content
wget -nc -O ./tmp/patch1110.zip http://archive.org/download/hl_shareware_data/valve/patch1110.zip
unzip -o ./tmp/patch1110.zip -d ./$OUTPK3DIR

# Dangerous rm -rf'ing going on here
printf "All done. Would you like to clean up temporary files? (./tmp dir)\ny/n: "
read CHOICE

if [[ "$CHOICE" == [Yy]* ]]; then
	rm -rfv ./tmp
fi
