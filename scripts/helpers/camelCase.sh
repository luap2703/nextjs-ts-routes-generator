# Function to convert kebab-case to camelCase
to_camel_case() {
    local input="$1"
    # Convert input to lowercase
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    # Replace hyphens and underscores with spaces
    input=$(echo "$input" | tr '-' ' ' | tr '_' ' ')
    # Read words into an array
    read -ra words <<<"$input"
    local result="${words[0]}"
    for word in "${words[@]:1}"; do
        result+=$(tr '[:lower:]' '[:upper:]' <<<${word:0:1})${word:1}
    done
    echo "$result"
}
