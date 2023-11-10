#Declaração dos Arrays tipo Array["dir"]=space
declare -A newArray
declare -A oldArray
declare -A diffArray

#declaração de variáveis
declare ordered=0           #flag para indicar se a opção -a foi usada
declare limit=0             #flag para indicar se a opção -l foi usada
declare reverse=0           #flag para indicar se a opção -r foi usada

while getopts ":l:ar" opt; do  #ciclo while irá verificar quais os argumentos de chamada que foram usados
case $opt in
    a)
        ordered=1                    #se a opção -a for usada, alterar o valor da variável ordered para 1 para usar mais tarde no sort
        ;;
    l)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            limit=$OPTARG           #se a opção -l for usada e o valor introduzido for um número, alterar o valor da variável limit para o introduzido pelo utilizador para usar mais tarde no sort
        else
            echo "Argument is not a number"  #se a opção -l for usada e o valor introduzido não for um número, apresentar mensagem de erro e sair
            exit 1
        fi
        ;;
    r)
        reverse=1                   #se a opção -r for usada, alterar o valor da variável reverse para 1 para usar mais tarde no sort
        ;;
    \?)
        echo "Invalid parameter: -$OPTARG"     #se a opção introduzida não for válida, apresentar mensagem de erro e sair
        exit 1
        ;;
    :)
        echo "Parameter -$OPTARG needs an argument."   #se a opção introduzida necessitar de um argumento que não foi introduzido, apresentar mensagem de erro e sair
        exit 1
        ;;
esac
done
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

done | if [[ "$reverse" -eq 1 ]]; then      #se a opção -r foi usada nos argumentos de chamada, então imprimir os resultados por ordem reversa,ou seja, por ordem crescente
        sort -k 1,1n -k 2
    elif [[ "$ordered" -eq 1 ]]; then       #se a opção -a foi usada nos argumentos de chamada, então imprimir os resultados ordenando-os pelo nome
        sort -k 2
    elif [[ "$limit" -gt 0 ]]; then         #se a opção -l foi usada nos argumentos de chamada, então imprimir apenas o número de linhas pretendido
        sort -k 1,1nr | head -n "$limit"
    else
        sort -k 1,1nr                           #se nenhuma das opções de ordenação foi usada, então imprimir os resultados por ordem decrescente
    fi
  
}
read_files "$@"
calc_difference