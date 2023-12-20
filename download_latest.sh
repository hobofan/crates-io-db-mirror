#!/bin/bash
set -eux

# Get the current date in the YYYY-MM-DD format
date=$(date +%Y-%m-%d)

# Construct the filename
filename="${date}.tar.gz"

# Construct the ETag file
etag_file="${date}.etag"

# Download the file if it has changed
curl --etag-compare "${etag_file}" --etag-save "${etag_file}" -o "${filename}" --location "https://static.crates.io/db-dump.tar.gz"