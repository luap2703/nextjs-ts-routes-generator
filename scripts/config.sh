#!/bin/bash

# Create the __generated__ directory if it doesn't exist
mkdir -p ../__generated__

# Configuration file path
config_file="../__generated__/_config.sh"

# Function to display the case conversion type menu
select_case_type() {
    PS3="Enter the number for the case conversion type (1 or 2): "
    options=("camelCase" "snakeCase")
    select opt in "${options[@]}"; do
        case $opt in
        "camelCase")
            echo "You chose camelCase"
            echo "CASE_TYPE='camelcase'" >>"$config_file"
            break
            ;;
        "snakeCase")
            echo "You chose snakeCase"
            echo "CASE_TYPE='snakecase'" >>"$config_file"
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
        esac
    done
}

# Start fresh config file
echo "# Configuration file" >"$config_file"

# Select case conversion type
select_case_type

# Prompt user for the property name
read -p "Enter the name of the property that gets exported (default: paths): " property_name
property_name=${property_name:-paths} # Default to "paths" if no input

# Save property name to the config file
echo "PROPERTY_NAME='$property_name'" >>"$config_file"

# Prompt user for the pages path with a default value of src/pages
read -p "Enter the relative path to the pages folder (default: src/pages): " pages_path
pages_path=${pages_path:-src/pages} # Default to "src/pages" if no input

# Save pages path to the config file
echo "PAGES_PATH='$pages_path'" >>"$config_file"

echo "Configurations have been saved to $config_file."
