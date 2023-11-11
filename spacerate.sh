#Declaração dos Arrays tipo Array["dir"]=space
declare -A newArray
declare -A oldArray
declare -A diffArray

#Declaração de variáveis
declare ordered=0           #Flag para indicar se a opção -a foi usada
declare limit=0             #Variável para indicar se a opção -l foi usada que guarda o número de linhas a imprimir
declare limit=0             #Variável para indicar se a opção -l foi usada que guarda o número de linhas a imprimir
declare sort_options="-k 1,1nr"     #Váriavel para guardar as opções de ordenação, por defeito será ordenar por tamanho decrescente

#Ciclo que verifica quais os argumentos de chamada usados
while getopts ":l:ar" opt; do 
case $opt in
    a)
        if [[ "$sort_options" != "-k 1,1nr" ]]; then
            #Ordenar por ordem alfabética inversa
            sort_options="-k 2r"
        else 
            #Ordenar por ordem alfabética
            sort_options=$"-k 2"
        fi
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
        if [[ "$sort_options" != "-k 1,1nr" ]]; then
            #Ordenar por ordem alfabética inversa
            sort_options+="r"
        else 
            #Ordenar por ordem crescente
            sort_options=$"-k 1,1n"
        fi
        ;;
    \?)
        #Se o parametro introduzido não for válido, apresentar mensagem de erro e sair
        echo "Invalid parameter: -$OPTARG"
        ;;
    :)
        #Se o parametro introduzido precisar de um argumento que não foi introduzido, apresentar mensagem de erro e sair
        echo "Parameter -$OPTARG needs an argument."
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

    done  | if [[ "$limit" -gt 0 ]]; then
        #Limitar o número de linhas
        sort "$sort_options" | head -n "$limit"
        else
            sort "$sort_options"
    fi
}

read_files "$@"
calc_difference