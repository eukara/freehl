#!/bin/sh

# builds a pk3 file that's alphabetically sorted
mk_pk3()
{
	tree -fi > ./build_contents.txt
	sed -i '/build_contents/d' ./build_contents.txt
	sed -i '/directories,/d' ./build_contents.txt
	zip -0 "$1".pk3 -@ < ./build_contents.txt
	rm ./build_contents.txt
	mv "$1".pk3 ../"$1".pk3
}

# grabs a patch .zip from archive.org and saves it as a pk3
grab_patch()
{
	wget -nc -O ./pak$2.pk4 http://archive.org/download/hl_shareware_data/valve/$1.zip
}

SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"
OUTPK3DIR="pak1_retail.pk3dir"

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

# Check if we need to do anything
if ! [ -f "$SCRPATH/pak00_cd.pak" ] || ! [ -f "$SCRPATH/pak01_cd.pk3" ]; then
	# Grab the cabinet data off the CD
	mkdir -p ./tmp
	unshield -d ./tmp x "$CDROM_PATH"/data1.cab

	# Let's shove them all into a convenient .pk3dir
	mkdir -p ./$OUTPK3DIR
	mv -v ./tmp/Half-Life_PAK_File/valve/pak0.pak ./pak00_cd.pak
	rsync -av ./tmp/Half-Life_Program_Files/valve/ ./$OUTPK3DIR/
	mv -v ./tmp/Half-Life_Program_Files/media ./$OUTPK3DIR/media
	mv -v ./tmp/Half-Life_Program_Files/logos ./$OUTPK3DIR/logos
	cd ./$OUTPK3DIR
	mk_pk3 pak01_cd
fi

cd "$SCRPATH"

# Get the latest patch, because that'll fix the menu assets and add more fun, free content
grab_patch 10051006 02_1006
grab_patch 10061008 03_1008
grab_patch 10081009 04_1009
grab_patch 10091010 05_1010
grab_patch 10101013 06_1013
grab_patch 10131015 07_1015
grab_patch 10151016 08_1016
grab_patch 10161100 09_1100
grab_patch 11001101 10_1101
grab_patch 11011104 11_1104
grab_patch 11041106 12_1106
grab_patch 11071108 14_1108
grab_patch 11081109 15_1109
grab_patch 11091110 16_1110

# Make sure we're back in here
cd "$SCRPATH"

printf "All done. Would you like to rip the the Compact Disc Digital Audio for music?\ny/n: "
read CHOICE

if [[ "$CHOICE" == [Yy]* ]]; then
	# check if we require rippin tunes
	if ! [ -f "$SCRPATH/music/track02.wav" ] && ! [ -f "$SCRPATH/music/track02.ogg" ]; then
		if [ -x "$(command -v cdparanoia)" ]; then
			mkdir -p "./music"
			cd "./music"
			cdparanoia -B
			rename ".cdda." "." *.wav

			# Maybe the user does not have the physical disc and cdp fails.
			if [ -f "$SCRPATH/music/track02.wav" ]; then
			# I'd offer FLAC, but that also requires the ffmpeg plugin
			if [ -x "$(command -v oggenc)" ]; then
				printf "All done. Would you like to convert them to OGG for playback compatibility\nas well as space preservation (frees up ~330 MB)?\ny/n: "
				read CHOICE
				if [[ "$CHOICE" == [Yy]* ]]; then
					oggenc *.wav
					rm *.wav
				fi
			fi
			fi
		else
			printf "cdparanoia is missing. Cannot rip music.\nPlease run the installer again once you've got it installed.\n"
		fi
	else
		printf "Music is already present.\n"
	fi
fi

cd "$SCRPATH"

rm -rfv ./$OUTPK3DIR
rm -rfv ./tmp
