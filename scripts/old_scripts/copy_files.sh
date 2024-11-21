#!/bin/bash

# Source directory containing the directories with files
src_dir="/Users/arman/Desktop/DARSI/new_run_plots/model"

# Destination directory to copy files
dest_dir="/Users/arman/Desktop/DARSI/new_run_plots/saliency_maps"

# Loop through each subdirectory in the source directory
for dir in "$src_dir"/*; do
    if [ -d "$dir" ]; then
        # Get the name of the current subdirectory
        dirname=$(basename "$dir")

        # Loop through each file containing "Map" in its name within the subdirectory
        for file in "$dir"/*Map*; do
            if [ -f "$file" ]; then
                # Get the base name of the file
                filename=$(basename "$file")

                # Copy the file to the destination directory with the modified name
                cp "$file" "$dest_dir/${dirname}_$filename"
            fi
        done
    fi
done

