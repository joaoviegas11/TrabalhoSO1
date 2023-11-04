declare -A newArray
declare -A oldArray
ordered=0
limit=0
reverse=0
while getopts ":l:ar" opt; do
case $opt in
    a)
        echo "Opção a"
        ordered=1
        #sort -n ./testetemp.txt >./temp1
        # Implemente a lógica para a opção -a aqui
        ;;
    l)
        #echo "Opção l, argumento: $OPTARG"
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
shift $((OPTIND - 1))
#arrayNewN=("$(tail +2 $2 | cut -d " " -f1)")
#arrayNewD=("$(tail +2 $2 | cut -d " " -f2-)")
while read -r line; do
    number=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    newArray["$dir"]="$number"
done < <(tail -n +2 "$2")
while read -r line; do
    number=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    oldArray["$dir"]="$number"
done < <(tail -n +2 "$1")

for i in "${!oldArray[@]}"; do
    if [[ -n "${newArray[$i]}" ]]; then
        newArray["$i"]=$((newArray["$i"] - oldArray["$i"]))
    else
        newArray["$i"]=$((-oldArray["$i"]))
    fi
    echo "result= $i: ${newArray[$i]}"
done