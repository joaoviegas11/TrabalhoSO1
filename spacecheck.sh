#!/bin/bash

#Trabalho realizado por:
#Diogo Domingues    114192
#João Viegas        113144

#Declaração de variáveis
declare script_dir=$(pwd)   #Diretório em que o script se encontra quando executado
declare regex=".*"          #Variável para filtrar os ficheiros por nome, por defeito será qualquer nome
declare dataDate="now"      #Variável para filtrar os ficheiros por data, por defeito será a data atual
declare limitFilter=0       #Variável para filtrar os ficheiros por tamanho, por defeito será 0
declare limit=0             #Variável para indicar se a opção -l foi usada que guarda o número de linhas a imprimir
declare sort_options="-k 1,1nr"     #Variável para guardar as opções de ordenação, por defeito será ordenar por tamanho decrescente

#É necessário imprimir o cabeçalho antes de se fazer shift para que os argumentos de chamada não sejam alterados
echo "SIZE NAME $(date +'%Y%m%d') $@"   

#Ciclo que verifica quais os argumentos de chamada usados
while getopts ":n:d:s:l:ar" opt; do
case $opt in                            
    n)
        #Se a opção -n for usada, alterar o valor da variável regex
        regex=$OPTARG
        ;;
    d)  
        if date -d "$OPTARG" &>/dev/null; then
            #Se a opção -d for usada e o valor for válido, alterar o valor da variável dataDate
            dataDate=$OPTARG  
        else
            #Se o valor não for válido, apresentar mensagem de erro e sair
            echo "Argument is not valid date."
            exit 1
        fi
        ;;
    s)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            #Se a opção -s for usada e o valor for um número, alterar o valor da variável limitFilter
            limitFilter=$OPTARG
        else
            #Se o valor não for um número, apresentar mensagem de erro e sair
            echo "Argument is not a number" 
            exit 1
        fi
        ;;
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
        #Se o parâmetro introduzido não for válido, apresentar mensagem de erro e sair
        echo "Invalid parameter: -$OPTARG"
        exit 1
        ;;
    :)
        #Se o parâmetro introduzido precisar de um argumento que não foi introduzido, apresentar mensagem de erro e sair
        echo "Parameter -$OPTARG needs an argument."
        exit 1
        ;;
esac 
done

#Remover os argumentos de chamada usados
shift $((OPTIND - 1))

function search_dir(){ 
    #Função que recebe diretórios como argumentos e procura os seus subdiretórios

    local directories=()    #Criação de uma lista para guardar os diretórios e subdiretórios
    
    if [ "$#" -eq 0 ]; then     
        #Se não for passado nenhum diretório como argumento, apresentar mensagem de erro e usar o diretório atual
        echo "Directory not specified, using current directory instead" >&2
        directories+=("$(find . -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null)")
    fi

    for dir in "$@"; do     #Ciclo for para percorrer todos os diretórios introduzidos
        if [ -d "$dir" ]; then      #Verificar se o diretório existe
            #Se existir, procurar os subdiretórios e adiciona-los à lista
            directories+=("$(find "$dir" -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null)")
        else
            #Se não existir, apresentar mensagem de erro e usar o diretório atual
            echo "Directory $dir does not exist" >&2
            echo "Using current directory instead" >&2
            #Procurar os subdiretórios do diretório atual e adiciona-los à lista
            directories+=("$(find . -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null)")
        fi
    done

    directories=($(printf "%s\n" "${directories[@]}" | sort -u)) #Remover diretórios duplicados

    echo "${directories[*]}"   #Devolver a lista de diretórios e subdiretórios
}

function search_files(){
    #Função que receberá a lista devolvida pela função search_dir e irá calcular o tamanho dos ficheiros presentes nesses diretórios

    local IFS=$'\n'     #Variável que irá separar os elementos da lista por linha

    local directories=($(search_dir "$@"))  #Chamar a função search_dir e guardar a lista devolvida na variável directories

    for dir in "${directories[@]}"; do   #Ciclo for para percorrer a lista recebida

        #Se o diretório existir e todos os ficheiros deste forem legíveis
        if cd $dir 2>/dev/null && [ -z "$(find . -type f ! -readable)" ]; then

        size=0      #Variável para guardar o tamanho total dos ficheiros no diretório

        #Ciclo for para percorrer todos os ficheiros no diretório atual que cumpram as condições especificadas
        for file in $(find . -type f -size +"$limitFilter"c -not -newermt "$(date --date="$dataDate" '+%Y-%m-%d %H:%M:%S')" | grep -E "$regex"); do
            #Adicionar o tamanho de cada ficheiro, em bytes, à variável size
            size=$((size + $(du -sb "$file" | awk '{print $1}')))
        done

        #Imprimir o tamanho total dos ficheiros no diretório e o caminho relativo deste
        echo "$size $(realpath --relative-to="$script_dir" "$dir")"

        else
            #Se o diretório não existir ou algum dos ficheiros não for legível, imprimir NA e o caminho relativo do diretório
            echo "NA $(realpath --relative-to="$script_dir" "$dir")"
        fi

    done | if [[ "$limit" -gt 0 ]]; then
    #Limitar o número de linhas e ordenar
        sort "$sort_options" | head -n "$limit"
    else
        sort "$sort_options"
    fi
    echo
}

search_files "$@"
