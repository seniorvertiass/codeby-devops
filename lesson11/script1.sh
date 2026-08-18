#!/bin/bash

# Создаёт папку myfolder и пять файлов с заданными параметрами.

set -u


readonly FOLDER_NAME="myfolder"
readonly FILE_GREETING="file1"
readonly FILE_PERMISSIONS="file2"
readonly FILE_RANDOM="file3"
readonly FILE_EMPTY_1="file4"
readonly FILE_EMPTY_2="file5"
readonly RANDOM_LENGTH=20
readonly FILE2_PERMISSIONS="777"

readonly TARGET_DIR="$HOME/$FOLDER_NAME"


create_directory() {
    if ! mkdir -p "$TARGET_DIR"; then
        echo "ERROR: Cannot create directory: $TARGET_DIR" >&2
        return 1
    fi

    return 0
}


create_greeting_file() {
    if ! cat > "$TARGET_DIR/$FILE_GREETING" <<EOF
Приветствие!
$(date '+%Y-%m-%d %H:%M:%S')
EOF
    then
        echo "ERROR: Cannot create $FILE_GREETING" >&2
        return 1
    fi

    return 0
}


create_permissions_file() {
    if ! touch "$TARGET_DIR/$FILE_PERMISSIONS"; then
        echo "ERROR: Cannot create $FILE_PERMISSIONS" >&2
        return 1
    fi

    if ! chmod "$FILE2_PERMISSIONS" "$TARGET_DIR/$FILE_PERMISSIONS"; then
        echo "ERROR: Cannot set permissions for $FILE_PERMISSIONS" >&2
        return 1
    fi

    return 0
}


create_random_file() {
    if ! tr -dc 'A-Za-z0-9' < /dev/urandom |
        head -c "$RANDOM_LENGTH" > "$TARGET_DIR/$FILE_RANDOM"
    then
        echo "ERROR: Cannot create $FILE_RANDOM" >&2
        return 1
    fi

    return 0
}


create_empty_files() {
    if ! touch \
        "$TARGET_DIR/$FILE_EMPTY_1" \
        "$TARGET_DIR/$FILE_EMPTY_2"
    then
        echo "ERROR: Cannot create empty files" >&2
        return 1
    fi

    return 0
}



main() {
    create_directory || return 1
    create_greeting_file || return 1
    create_permissions_file || return 1
    create_random_file || return 1
    create_empty_files || return 1

    echo "script1.sh completed successfully."
    echo "Created files in: $TARGET_DIR"

    return 0
}


main
exit $?
