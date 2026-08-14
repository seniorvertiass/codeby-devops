#!/bin/bash

set -u

FOLDER="$HOME/myfolder"

echo "Checking folder: $FOLDER"

if [ ! -d "$FOLDER" ]; then
    mkdir -p "$FOLDER"
    echo "Folder did not exist. Created: $FOLDER"
fi

FILE_COUNT=$(find "$FOLDER" -maxdepth 1 -type f | wc -l)

echo "Files in myfolder: $FILE_COUNT"

if [ -f "$FOLDER/file2" ]; then
    chmod 664 "$FOLDER/file2"
    echo "Permissions of file2 changed to 664."
fi

find "$FOLDER" -maxdepth 1 -type f -empty -delete

for FILE in "$FOLDER"/*; do

    if [ -f "$FILE" ]; then
        sed -i '1!d' "$FILE"
    fi

done

echo "script2.sh completed."
