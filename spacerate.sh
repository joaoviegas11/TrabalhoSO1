declare -A newArray
declare -A oldArray
declare -A diffArray
ordered=0
limit=0
reverse=0
while getopts ":l:ar" opt; do
case $opt in
    a)
        ordered=1
        ;;
    l)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            limit=$OPTARG
        else
            echo "O argumento não é um número."
            exit 1
        fi
        ;;
    r)
        reverse=1
        ;;
    \?)
        echo "Parametro inválido: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "O parametro -$OPTARG requer um argumento." >&2
        exit 1
        ;;
esac
done
shift $((OPTIND - 1))
#arrayNewN=("$(tail +2 $2 | cut -d " " -f1)")
#arrayNewD=("$(tail +2 $2 | cut -d " " -f2-)")
while read -r line; do
    number=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    newArray["$dir"]="$number"
    diffArray["$dir"]="$number"
done < <(tail -n +2 "$2")
while read -r line; do
    number=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    oldArray["$dir"]="$number"
done < <(tail -n +2 "$1")

for i in "${!oldArray[@]}"; do
    if [[ "${oldArray[$i]}" == "NA" || "${newArray[$i]}" == "NA" ]]; then
        diffArray["$i"]="NA"
    elif [[ -n "${newArray[$i]}" ]]; then
        diffArray["$i"]=$((newArray["$i"] - oldArray["$i"]))
    else
        diffArray["$i"]=$((-oldArray["$i"]))
    fi
done
echo "SIZE NAME"
for i in "${!diffArray[@]}"; do
    memory=""
    if [[ -z "${newArray[$i]}" ]]; then
        memory="REMOVED"
    elif [[ -z "${oldArray[$i]}" ]]; then
        memory="NEW"
    fi
    echo "${diffArray[$i]} $i $memory"
done | if [[ "$reverse" -eq 1 ]]; then      #se a opção -r foi usada nos argumentos de chamada, então imprimir os resultados por ordem reversa,ou seja, por ordem crescente
        sort -k 1,1n -k 2
    elif [[ "$ordered" -eq 1 ]]; then       #se a opção -a foi usada nos argumentos de chamada, então imprimir os resultados ordenando-os pelo nome
        sort -k 2
    elif [[ "$limit" -gt 0 ]]; then         #se a opção -l foi usada nos argumentos de chamada, então imprimir apenas o número de linhas pretendido
        sort -k 1,1nr | head -n "$limit"
    else
        sort -k 1,1nr                           #se nenhuma das opções de ordenação foi usada, então imprimir os resultados por ordem decrescente
    fi