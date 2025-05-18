#!/bin/bash

if [ -z "$1" ]; then
    echo "Please provide the directory containing .mmd files as the first argument."
    exit 1
fi

# Set the correct directory
DIR="$1"
SCALE_FACTOR=10

# Change to the correct directory
cd "$(pwd)/$DIR" || { echo "Directory $DIR not found!"; exit 1; }

# Loop through all the .mmd files in the directory and process in parallel
mkdir -p outputs
pids=()
for file in *.mmd; do
    if [[ -f "$file" ]]; then
        output_file="${file%.mmd}.png"

        # Generate the diagram using mmdc in the background
        mmdc -i "$file" -o "outputs/$output_file" --scale "$SCALE_FACTOR" &
        pids+=("$!") # Store the process ID of the backgrounded command
        echo "Started generating diagram: $output_file (PID: $!)"
    fi
done

# Wait for all background processes to finish
if [ ${#pids[@]} -gt 0 ]; then
    echo "Waiting for all diagram generation processes to complete..."
    wait "${pids[@]}"
    echo "All diagram generation processes completed."
else
    echo "No .mmd files found in the directory."
fi