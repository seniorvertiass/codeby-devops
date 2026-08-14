#!/bin/bash

set -u

FOLDER="$HOME/myfolder"

mkdir -p "$FOLDER"

cat > "$FOLDER/file1" <<EOF
Приветствие!
$(date '+%Y-%m-%d %H:%M:%S')
EOF

touch "$FOLDER/file2"
chmod 777 "$FOLDER/file2"

tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20 > "$FOLDER/file3"
echo >> "$FOLDER/file3"

touch "$FOLDER/file4"
touch "$FOLDER/file5"

echo "script1.sh completed."
echo "Files created in: $FOLDER"
