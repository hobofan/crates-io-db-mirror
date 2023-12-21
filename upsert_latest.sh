#!/bin/bash
set -eux

# Find the .tar.gz file with the most recent timestamp
tar_file=$(ls -Art *.tar.gz | tail -n 1)

# Ensure the ./data directory exists
mkdir -p ./data
# Extract the contents of the .tar.gz file
tar -xzf "${tar_file}" -C ./data

# Find the directory in the ./data directory with the most recent timestamp
data_dir=$(gfind ./data -mindepth 1 -maxdepth 1 -type d -printf "%T+ %p\n" | sort -n | tail -n 1 | cut -f2- -d" ")

# Save the absolute path of the file ./schema.sql into a variable
schema_file="$(pwd)/schema.sql"
views_schema_file="$(pwd)/views_schema.sql"

# cd into that directory and run the command
cd "${data_dir}"
clickhouse client --queries-file "${schema_file}"
clickhouse client --queries-file "${views_schema_file}"
