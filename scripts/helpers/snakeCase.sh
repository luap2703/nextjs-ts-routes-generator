# Function to convert kebab-case to snake_case
to_snake_case() {
    local input="$1"
    # Replace all uppercase letters with underscore followed by the lowercase equivalent
    input=$(echo "$input" | sed -E 's/([A-Z])/_\L\1/g')
    # Replace hyphens with underscores
    input=$(echo "$input" | tr '-' '_')
    # Remove leading underscores if any
    input=$(echo "$input" | sed 's/^_//')
    # Convert to lowercase
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    echo "$input"
}
