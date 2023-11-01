
script_dir=$(pwd)
dataDate="now"
limitFilter=0
ordered=0
limit=0
reverse=0
while getopts ":n:d:s:l:ar" opt; do
case $opt in
    n)
        echo "Opção n, argumento: $OPTARG"
        regex=$OPTARG
        ;;
    d)
        echo "Opção d, argumento: $OPTARG"
        dataDate=$OPTARG
        # Implemente a lógica para a opção -d aqui
        ;;
    s)
        #echo "Opção s, argumento: $OPTARG"
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            #echo "A variável é um número."
            limitFilter=$OPTARG
        else
            echo "A variável não é um número."
            exit 1
        fi
        ;;
    a)
        echo "Opção a"
        ordered=1
        #sort -n ./testetemp.txt >./temp1
        # Implemente a lógica para a opção -a aqui
        ;;
    l)
        echo "Opção l, argumento: $OPTARG"
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            limit=$OPTARG
        else
            echo "A variável não é um número."
            exit 1
        fi
        #tail -"$OPTARG" ./temp1 >./temp
        # Implemente a lógica para a opção -l aqui
        ;;
    r)
        echo "Opção r"
        reverse=1
        ;;
    \?)
        echo "Opção inválida: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "A opção -$OPTARG requer um argumento." >&2
        exit 1
        ;;
esac
done
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
         for file in $(find . -type f -size +"$limitFilter"c -newermt "$(date --date="$dataDate" '+%Y-%m-%d %H:%M:%S')" | grep -E "$regex"); do
            size=$((size + $(du -s "$file" | awk '{print $1}')))
        done
        relative_dir=$(realpath --relative-to="$script_dir" "$dir")
        echo "$size $relative_dir"
    done | if [[ "$reverse" -eq 1 ]]; then
        sort -n
        elif [[ "$ordered" -eq 1 ]]; then
        sort -k 2
        elif [[ "$limit" -gt 0 ]]; then
        sort -nr | head -n "$limit"
    else
        sort -nr
    fi
    #fi
}

search_files "$@"
