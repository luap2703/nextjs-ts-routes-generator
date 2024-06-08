#!/bin/bash

# Source the configuration file
# Source the configuration file
if [ -f "../__generated__/_config.sh" ]; then
    source "../__generated__/_config.sh"
else
    echo "Configuration file not found. Please run init.sh first."
    exit 1
fi

# Source helper functions
source ./scripts/helpers/camelCase.sh
source ./scripts/helpers/snakeCase.sh

# Convert relative path to absolute path
project_root=$(pwd)
pages_path="$project_root/$PAGES_PATH"

# Get the pages folder path
PAGES_PATH=$(pwd)/src/pages

# Wipe the existing paths.ts file
>"$PAGES_PATH/paths.ts"

# Function to construct folder path
constructFolderPath() {
    local NAME=$1
    local ORIGINAL_NAME=$2
    local PREFIX=$3
    local INDENT=$4
    local OUTPUT=$5
    local PARAM=$6

    if [ -z "$PARAM" ]; then
        echo "$INDENT$NAME: ((prevPath: string) => {" >>$OUTPUT
        echo "$INDENT  const prefix = \`\${prevPath}/${PREFIX}${ORIGINAL_NAME}\`;" >>$OUTPUT
        echo "$INDENT  return {" >>$OUTPUT
    else
        echo "$INDENT$NAME: ($PARAM: string) => ((prevPath: string) => {" >>$OUTPUT
        echo "$INDENT  const prefix = \`\${prevPath}/${PREFIX}\${$PARAM}\`;" >>$OUTPUT
        echo "$INDENT  return {" >>$OUTPUT
    fi
}

# Function to construct file path
constructFilePath() {
    local NAME=$1
    local ORIGINAL_NAME=$2
    local PREFIX=$3
    local INDENT=$4
    local OUTPUT=$5
    local PARAM=$6

    if [ -z "$PARAM" ]; then
        echo "$INDENT  $NAME: ((prevPath: string) => \`\${prevPath}/${PREFIX}${ORIGINAL_NAME}\`)(prefix)," >>$OUTPUT
    else
        echo "$INDENT  $NAME: ($PARAM: string) => ((prevPath: string) => \`\${prevPath}/${PREFIX}\${$PARAM}\`)(prefix)," >>$OUTPUT
    fi
}

# Function to process the pages directory and generate the paths object
generate_paths_object() {
    local DIR=$1
    local PREFIX=$2
    local OUTPUT=$3
    local INDENT=$4
    local CASE_FUNC=$5

    for ITEM in "$DIR"/*; do
        BASENAME=$(basename "$ITEM")

        # Exclude technical files and directories
        if [[ "$BASENAME" == "paths.ts" || "$BASENAME" == _* || "$BASENAME" == "api" ]]; then
            continue
        fi

        # Exclude non-TSX/JSX files
        if [[ ! -d "$ITEM" && ! "$BASENAME" =~ \.tsx$ && ! "$BASENAME" =~ \.jsx$ ]]; then
            continue
        fi

        if [ -d "$ITEM" ]; then
            if [[ "$BASENAME" == \[*\] ]]; then
                DYNAMIC_PARAM=$(echo "$BASENAME" | tr -d '[]')
                CONVERTED_PARAM=$($CASE_FUNC "$DYNAMIC_PARAM")
                CONVERTED_NAME=$CONVERTED_PARAM
                constructFolderPath "$CONVERTED_NAME" "$BASENAME" "$PREFIX" "$INDENT" "$OUTPUT" "$CONVERTED_PARAM"
                generate_paths_object "$ITEM" "" $OUTPUT "$INDENT    " $CASE_FUNC
                echo "$INDENT  }})(prefix)," >>$OUTPUT
            else
                CONVERTED_NAME=$($CASE_FUNC "$BASENAME")
                constructFolderPath "$CONVERTED_NAME" "$BASENAME" "$PREFIX" "$INDENT" "$OUTPUT"
                generate_paths_object "$ITEM" "" $OUTPUT "$INDENT    " $CASE_FUNC
                echo "$INDENT  }})(prefix)," >>$OUTPUT
            fi
        else
            FILENAME="${BASENAME%.*}"
            if [[ "$FILENAME" == \[*\] ]]; then
                DYNAMIC_PARAM=$(echo "$FILENAME" | tr -d '[]')
                CONVERTED_PARAM=$($CASE_FUNC "$DYNAMIC_PARAM")
                CONVERTED_NAME=$CONVERTED_PARAM
                constructFilePath "$CONVERTED_NAME" "$FILENAME" "$PREFIX" "$INDENT" "$OUTPUT" "$CONVERTED_PARAM"
            elif [ "$FILENAME" == "index" ]; then
                echo "$INDENT  index: ((prevPath: string) => \`\${prevPath}${PREFIX%/}\`)(prefix)," >>$OUTPUT
            else
                CONVERTED_NAME=$($CASE_FUNC "$FILENAME")
                constructFilePath "$CONVERTED_NAME" "$FILENAME" "$PREFIX" "$INDENT" "$OUTPUT"
            fi
        fi
    done
}

# Parse command line arguments for case style
CASE_STYLE="camelCase"
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --camelCase) CASE_STYLE="camelCase" ;;
    --snakeCase) CASE_STYLE="snakeCase" ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

# Select the case conversion function based on the case style
case $CASE_STYLE in
camelCase) CASE_FUNC="to_camel_case" ;;
snakeCase) CASE_FUNC="to_snake_case" ;;
esac

# Create the paths.ts file and write the initial part
OUTPUT_FILE="$PAGES_PATH/paths.ts"
echo "export const paths = (() => ((prefix: string) => ({" >>$OUTPUT_FILE

# Generate the paths object
generate_paths_object $PAGES_PATH "" $OUTPUT_FILE "    " $CASE_FUNC

# Close the object
echo "  }))(''))();" >>$OUTPUT_FILE

# Format the generated file for better readability
sed -i 's/},/}/g' $OUTPUT_FILE
