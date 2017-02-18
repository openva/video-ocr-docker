#!/bin/bash

if [ -z "$1" ]; then
	echo "usage: $0 [filename] [chamber], omitting .mp4 extension"
	exit
fi
if [ -z "$2" ]; then
	echo "usage: $0 [filename] [chamber], omitting .mp4 extension"
	exit
fi

SRC="$1"
CHAMBER="$2"

if [ ! -f "$SRC".mp4 ]; then
	echo "Error: $SRC.mp4 does not exist"
	exit 1;
fi

if [ "$CHAMBER" = "house" ]; then
	FRAMESTEP=150
else
	FRAMESTEP=60
fi

# Have mplayer create a folder full of screenshots.
mplayer -vf framestep="$FRAMESTEP" -framedrop -nosound "$SRC".mp4 -speed 100 -vo jpeg:outdir="$SRC"
if [[ "$?" != 0 ]]; then
	exit "$?"
fi

echo "Extracting names and bill numbers from each frame"

cd "$SRC" || exit

# Standardize screenshot dimensions
mogrify -resize 640x480 *.jpg
if [[ "$?" != 0 ]]; then
	echo "Couldn't resize all images"
	exit "$?"
fi

if [ "$CHAMBER" = "house" ]; then
	NAME_CROP="333x60+120+380"
	BILL_CROP="129x27+465+42"
else
	NAME_CROP="345x60+172+340"
	BILL_CROP="172x27+0+40"
fi

for f in *[0-9].jpg; do convert "$f" -crop "$NAME_CROP" +repage -negate -fx '.8*r+.8*g+0*b' -compress none -depth 8 "$f".name.jpg; done
for f in *[0-9].jpg; do convert "$f" -crop "$BILL_CROP" +repage -negate -fx '.8*r+.8*g+0*b' -compress none -depth 8 "$f".bill.jpg; done

echo OCRing names and bill numbers

# We do this in two steps to avoid exceeding the limits of ls.
find . -type f -name '*.name.jpg' -exec tesseract {} {} \;
find . -type f -name '*.bill.jpg' -exec tesseract {} {} \;

# Make sure we have the privileges to delete files, later, during the processing
# stage (after this script is run).
chgrp web ./*
chmod g+w ./*

# Delete all of the images that we just OCRed.
find . -type f -name '*.name.jpg' -exec rm {} \;
find . -type f -name '*.bill.jpg' -exec rm {} \;

# Make the text files world-writable, so that the web server can delete them
# post-import.
chmod 777 ./*.txt

# Duplicate all JPEGs with a -150 suffix.
for F in $(ls -1 ./*.jpg |awk -F. '{print $1}')
do
	cp "$F".jpg "${F}"-150.jpg
done

# Create thumbnails of all *150.jpg screenshots.
echo Creating thumbnails of screenshots
mogrify -resize 150x112 ./*-150.jpg
