source ./inputParametros.sh

function search_dir(){
    script_dir=$(pwd)
    local result=()
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            mapfile -t result < <(find "$dir" -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null)
        fi
    done

    echo "${result[@]}"
}

function search_files(){
    local directories=($(search_dir "$@"))

    # Loop through the directories and process files
    for dir in "${directories[@]}"; do
        echo "Processing files in directory: $dir"
        # Add your file processing logic here
    done
}

search_files "$@"