#!/bin/sh
SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"

STEAMPATH="$HOME/.steam/steam/steamapps/common/Half-Life"
OUTPK3DIR="pak0_steam.pk3dir"

if ! [ -x "$(command -v rsync)" ]; then
	printf "Error: rsync is not installed.\n" >&2
	exit 1
fi

# take parameter if present
if [ $# -gt 0 ]; then
	STEAMPATH="$1"
else
	if ! [ -f "$STEAMPATH"/valve/halflife.wad ]; then
		printf "Path to Half-Life (STEAM) folder:\n"
		read STEAMPATH
	fi
fi

# check before moving
if ! [ -f "$STEAMPATH"/valve/halflife.wad ]; then
	printf "Error: Can't figure out where Half-Life's data is.\n" >&2
	exit 1
fi

mkdir -p ./$OUTPK3DIR
rsync -av "$STEAMPATH"/valve/ ./$OUTPK3DIR/

# Dangerous rm -rf'ing going on here
printf "All done. FreeHL will be playable, but the menu will have placeholder assets.\n"
