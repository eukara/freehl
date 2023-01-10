#!/bin/sh

# grabs a patch .zip from archive.org and saves it as a pk3
grab_patch()
{
	wget -nc -O ./pak$2.pk4 http://archive.org/download/hl_shareware_data/valve/$1.zip
}

# grabs a song on YouTube and stores it in OGG vorbis format
yt_grab()
{
	echo "Grabbing the official music track for Track $2..."
	yt-dlp -o track$2.ogg --extract-audio --audio-format vorbis https://www.youtube.com/watch?v=$1 &> /dev/null
}

SCRPATH="$( cd "$( dirname $(readlink -nf $0) )" && pwd )"

if ! [ -x "$(command -v wget)" ]; then
	printf "Error: wget is not installed.\n" >&2
	exit 0
fi

cd "$SCRPATH"

# Get the latest patch, because that'll fix the menu assets and add more fun, free content
echo "============================================================="
echo "Downloading data for Half-Life: Day One"
echo "This was a free demo that let you experience the first 'day'"
echo "at Black Mesa. It contains earlier data than the CD release."
echo "============================================================="
grab_patch dayone 00_dayone

echo "============================================================="
echo "Downloading data for Half-Life: Uplink"
echo "A demo containing a whole new chapter that was not present"
echo "in the CD release. It is newer than the CD disc pressing."
echo "============================================================="
grab_patch uplink 01_uplink

echo "============================================================="
echo "Downloading data for Half-Life from the RealMedia TFC demo"
echo "The freeware version of Team Fortress Classic put out by"
echo "RealMedia contained some Half-Life data we can make use of."
echo "============================================================="
grab_patch realmedia 02_realmedia

echo "============================================================="
echo "Downloading data for Half-Life from the Opposing Force demo"
echo "The demo of Half-Life: Opposing Force contains additional"
echo "data we can make use of to complete our data collection."
echo "============================================================="
grab_patch opfordemo 03_opfordemo

echo "============================================================="
echo "Downloading data for Half-Life Patch 1.1.1.0"
echo "This patch data contained updates to menu graphics, maps"
echo "and more for an enhanced multiplayer experience."
echo "============================================================="
grab_patch patch1110 04_patch1110

echo "============================================================="
echo "Downloading data for Half-Life's Dedicated Server"
echo "While this dataset contains no client-side game data, it"
echo "makes up for it in server-side content."
echo "============================================================="
grab_patch hlds 05_hlds

# Valve once had music tracks available on YouTube, however due to rights
# issues this is no more. As I'm not comfortable with unofficial uploads
# due to the nature of this project, this ends here.
exit 1

if ! [ -x "$(command -v yt-dlp)" ]; then
	printf "Error: yt-dlp is not installed.\nUnable to download music\n" >&2
	exit 0
fi

cd "$SCRPATH"
mkdir music
cd music
yt_grab lx1qQOeMk10 02
yt_grab 8KxNBtMjSlk 03
yt_grab 4c-R_KBuZ2A 04
yt_grab iUaNjxlBMNs 05
yt_grab YlLg-UAgZBY 06
yt_grab LJ3XN8yiE3A 07
yt_grab aBYdo8aeico 08
yt_grab EkX_4HsrYXQ 09
yt_grab GXc-Qk6YlGI 10
yt_grab DdcdeS9kzFo 11
yt_grab Zy0mdIS04sw 12
yt_grab qwP2QPzBI4Q 13
yt_grab 3BkG2pi8OAU 14
yt_grab VAJzipo22L8 15
yt_grab dvxX42uczNU 16
yt_grab 8xmJmGYbHd0 17
yt_grab itvxpfCep_4 18
yt_grab -iYoXSw7aek 19
yt_grab jp6tXuGnE10 20
yt_grab DQcvP-2L9KQ 21
yt_grab w3ctKDiYHpE 22
yt_grab Op__51Bngjg 23
yt_grab l2EKVHKiVfk 24
yt_grab 7bywJmv8tvQ 25
yt_grab fEFW2ha-ZYE 26
yt_grab FupijP4YUw8 27
yt_grab 9XuTPUi4-A4 28
