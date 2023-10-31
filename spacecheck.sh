source ./inputParametros.sh

function search_dir(){
    script_dir=$(pwd)
    local result=()
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            result+=( $(find "$dir" -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null) )
        fi
    done

    echo "${result[@]}"
}

function search_files(){
    local directories=($(search_dir "$@"))
    # if no options
    echo "SIZE NAME" $(date +'%Y%m%d') #falta o resto dos argumentos de chamada
    for dir in "${directories[@]}"; do
        cd $dir
            size=$(find . -type f -exec du -s {} \; 2>/dev/null | awk '{s+=$1} END {print s}')
        echo "$size $dir"
    done
    #fi
}

search_files "$@"