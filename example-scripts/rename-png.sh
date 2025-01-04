#!/bin/bash


FOLDER_PATH="./"


CURRENT_DATE=$(date +"%Y-%m-%d")


find "$FOLDER_PATH" -type f -name "*.png" | while read -r FILE; do
    
    DIR=$(dirname "$FILE")
    BASENAME=$(basename "$FILE")
    

    mv "$FILE" "$DIR/${CURRENT_DATE}-${BASENAME}"
    echo "Renamed: $FILE -> $DIR/${CURRENT_DATE}-${BASENAME}"
done
