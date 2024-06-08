#!/bin/bash

# Directory containing generated files
generated_dir="../__generated__"

# Check if the directory exists
if [ -d "$generated_dir" ]; then
    echo "Removing generated files..."
    rm -rf "$generated_dir"
    echo "All generated files have been removed."
else
    echo "No generated files found."
fi
