#Declaração dos Arrays tipo Array["dir"]=space
declare -A newArray
declare -A oldArray
declare -A diffArray

#Declaração de variáveis
declare ordered=0           #Flag para indicar se a opção -a foi usada
declare limit=0             #Flag para indicar se a opção -l foi usada
declare reverse=0           #Flag para indicar se a opção -r foi usada

#Ciclo que verifica quais os argumentos de chamada usados
while getopts ":l:ar" opt; do 
case $opt in
    a)
        #Se a opção -a for usada, alterar a flag ordered para 1
        ordered=1
        ;;
    l)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            #Se a opção -l for usada e o valor for um número, alterar a variável limit
            limit=$OPTARG
        else
            #Se o valor não for um número, apresentar mensagem de erro e sair
            echo "Argument is not a number"
            exit 1
        fi
        ;;
    r)
        #Se a opção -r for usada, alterar a flag reverse para 1
        reverse=1
        ;;
    \?)
        #Se o parametro introduzido não for válido, apresentar mensagem de erro e sair
        echo "Invalid parameter: -$OPTARG" >&2 
        exit 1
        ;;
    :)
        #Se o parametro introduzido precisar de um argumento que não foi introduzido, apresentar mensagem de erro e sair
        echo "Parameter -$OPTARG needs an argument." >&2
        exit 1
        ;;
esac
done

#Remover os argumentos de chamada usados
shift $((OPTIND - 1))

#Verificação se são passados 2 ficheiros.
if [ "$#" -ne 2 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "Insert 2 spacecheck output files"
    exit 1
fi


function read_files(){

#Leitura do novo ficheiro
while read -r line; do
    #Sepação do espaço do ficheiro do diretorio por linha 
    space=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    #Adicação do espaço do ficheiro em diretorio aos arrays 
    newArray["$dir"]="$space"
done < <(tail -n +2 "$2") #Remoção da primeira linha do ficheiro

#Leitura do antigo ficheiro
while read -r line; do
    space=$(echo "$line" | cut -d " " -f1)
    dir=$(echo "$line" | cut -d " " -f2-)
    oldArray["$dir"]="$space"
done < <(tail -n +2 "$1")
}

function calc_difference(){
for i in "${!oldArray[@]}"; do
    #Verifica se algum do espaços é NA
    if [[ "${oldArray[$i]}" == "NA" || "${newArray[$i]}" == "NA" ]]; then
        diffArray["$i"]="NA"
    #Verifica se existe no newArray o index $i
    elif [[ -n "${newArray[$i]}" ]]; then
        #Calculo da difereça dos espaços 
        diffArray["$i"]=$((newArray["$i"] - oldArray["$i"]))
    else
        #Calculo da difereça dos espaços 
        diffArray["$i"]=$((-oldArray["$i"]))
    fi
done

echo "SIZE NAME"
for i in "${!diffArray[@]}"; do
    local memory=""
    #Se o diretorio não exirtir no novo ficheiro
    if [[ -z "${newArray[$i]}" ]]; then
        memory="REMOVED"
    #Se o diretorio não exirtir no antigo ficheiro
    elif [[ -z "${oldArray[$i]}" ]]; then
        memory="NEW"
    fi
    #echo "${diffArray[$i]} $i $memory"
    #Problema NA
    if [[ "${diffArray[$i]}" != "NA" ]]; then
        echo "${diffArray[$i]} $i $memory"
    fi

    done | if [[ "$ordered" -eq 1 ]] && [[ "$reverse" -eq 1 ]]; then 
        #Se a flag ordered for 1 e a flag reverse for 1, então imprimir os resultados por ordem alfabetica inversa
        sort -k 2r
        elif [[ "$reverse" -eq 1 ]] && [[ "$limit" -gt 0 ]]; then
        #Se a flag reverse for 1 e a variável limit for maior que 0, então imprimir os resultados por ordem crescente e limitar o número de linhas
        sort -k 1,1n -k 2 | head -n "$limit"
        elif [[ "$ordered" -eq 1 ]] && [[ "$limit" -gt 0 ]]; then
        #Se a flag ordered for 1 e a variável limit for maior que 0, então imprimir os resultados por ordem alfabetica e limitar o número de linhas
        sort -k 2 | head -n "$limit"
        elif [[ "$reverse" -eq 1 ]]; then
        #Se a flag reverse for 1, então imprimir os resultados por ordem crescente
        sort -k 1,1n -k 2
        elif [[ "$ordered" -eq 1 ]]; then
        #Se a flag ordered for 1, então imprimir os resultados por ordem alfabetica
        sort -k 2
        elif [[ "$limit" -gt 0 ]]; then
        #Se a variável limit for maior que 0, então imprimir os resultados limitando o número de linhas
        sort -k 1,1nr | head -n "$limit"
        else
        #Se nenhuma das opções de ordenação for usada, então imprimir os resultados por ordem decrescente
        sort -k 1,1nr
    fi
}

read_files "$@"
calc_difference