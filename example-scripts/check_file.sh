#!/bin/bash

FILE_PATH="/var/lib/messages"

if [ -f "$FILE_PATH" ]; then
    echo "File exists: $FILE_PATH"
    echo "Are disabled"
    
    if [ -w "$FILE_PATH" ]; then
        echo "You have permissions to edit the file: $FILE_PATH"
    else
        echo "You do not have permissions to edit the file: $FILE_PATH"
    fi
else
    echo "File does not exist: /var/lib/messages"
fi
