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
    echo "$regex" #tirar depois de testes
    # if no options
    echo "SIZE NAME $(date +'%Y%m%d') $*"
    for dir in "${directories[@]}"; do
        cd $dir
         size=0
        for file in $(find . -type f -size +"$limitFilter"c | grep -E "$regex"); do
            size=$((size + $(du -s "$file" | awk '{print $1}')))
        done
        relative_dir=$(realpath --relative-to="$script_dir" "$dir")
        echo "$size $relative_dir"
    done | if [[ "$reverse" -eq 1 ]]; then
        sort -n
    else
        sort -nr
    fi
    #fi
}

search_files "$@"
