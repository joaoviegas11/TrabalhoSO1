source ./inputParametros.sh


function search_dir(){
    for dir in "${!#}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type d -exec du -s {} \; 2>/dev/null | awk '{print $1, $2}'
        else
            echo "$dir is not a directory"
        fi
    done
}
search_dir "$@"