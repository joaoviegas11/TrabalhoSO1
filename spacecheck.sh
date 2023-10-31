source ./inputParametros.sh

script_dir=$(pwd)

function search_dir(){
    local result=()
    
    for dir in "${!#}"; do
        if [ -d "$dir" ]; then
            result+=( $(find "$dir" -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null) )
        fi
    done

    echo "${result[@]}"
}

function search_files(){
    local directories=($(search_dir "$@"))
    # if no options
    echo "SIZE NAME $(date +'%Y%m%d') $*"
    for dir in "${directories[@]}"; do
        cd $dir
            size=$(find . -type f -exec du -s {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
        if [ -z "$size" ]; then #se size for vazio atribui 0
            size=0;
        fi
        relative_dir=$(realpath --relative-to="$script_dir" "$dir")
        echo "$size $relative_dir"
    done
    #fi
}

search_files "$@"