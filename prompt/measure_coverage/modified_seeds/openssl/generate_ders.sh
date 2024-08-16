#!/bin/bash

input_dir="./trials"
output_dir="./seeds"
cnt=1
max_files=10

# Find all files matching the pattern 'trial-*', sort them numerically, and process each one
for input_file in $(find "$input_dir" -name 'trial-*' | sort -V); do
    if [ $cnt -le $max_files ]; then
        output_file="${output_dir}/seed-${cnt}.der"
        
        if [ -f "$input_file" ]; then
            echo "File $(basename "$input_file") has changed into seed-${cnt}"
            python3 hex_to_der.py "$input_file" "$output_file"
            ((cnt++))
        else
            echo "File $input_file does not exist."
        fi
    else
        echo "Error: More than $max_files files found. Exiting."
        exit 1
    fi
done

# Check if the number of processed files is less than the maximum allowed
if [ $((cnt-1)) -le $max_files ]; then
    echo "[*] Processed $((cnt-1)) files."
else
    echo "Error: More than $max_files files found. Exiting."
    exit 1
fi
