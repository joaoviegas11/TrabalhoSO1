#!/bin/bash

#Trabalho realizado por:
#Diogo Domingues    114192
#João Viegas        113144

script_dir=$(pwd)   #diretorio em que o script se encontra quando executado
regex=".*"          #regex para os ficheiros será ".*" se a opção -n não for usada, ou seja, incluirá todos os ficheiros
dataDate="now"      #data de modificação dos ficheiros será a atual se a opção -d não for usada
limitFilter=0       #tamanho mínimo dos ficheiros será 0 se a opção -s não for usada, ou seja, incluirá todos os ficheiros
ordered=0           #variavél para indicar se a opção -a foi usada
limit=0             #variavél para indicar se a opção -l foi usada
reverse=0           #variavél para indicar se a opção -r foi usada

echo "SIZE NAME $(date +'%Y%m%d') $@"   #imprimir o cabeçalho da tabela com a data atual e os argumentos de chamada, o cabeçalho precisa de ser chamado antes do shift $((OPTIND - 1)) para que os argumentos de chamada não sejam removidos

while getopts ":n:d:s:l:ar" opt; do     #ciclo while irá verificar quais os argumentos de chamada que foram usados
case $opt in                            
    n)
        regex=$OPTARG                   #se a opção -n for usada, alterar o valor da variável regex para o introduzido pelo utilizador
        ;;
    d)
        dataDate=$OPTARG                #se a opção -d for usada, alterar o valor da variável dataDate para o introduzido pelo utilizador
        ;;
    s)
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            limitFilter=$OPTARG         #se a opção -s for usada e o valor introduzido for um número, alterar o valor da variável limitFilter para o introduzido pelo utilizador
        else
            echo "Argument is not a number"  #se a opção -s for usada e o valor introduzido não for um número, apresentar mensagem de erro e sair
            exit 1
        fi
        ;;
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
        echo "Invalid option: -$OPTARG" >&2     #se a opção introduzida não for válida, apresentar mensagem de erro e sair
        exit 1
        ;;
    :)
        echo "Option -$OPTARG needs an argument." >&2   #se a opção introduzida necessitar de um argumento que não foi introduzido, apresentar mensagem de erro e sair
        exit 1
        ;;
esac 
done
shift $((OPTIND - 1))  #shift que irá remover os argumentos de chamada que já foram usados para que sobrem apenas os diretórios a serem procurados


function search_dir(){  #a função search_dir irá receber os diretórios a serem procurados e procurará os subdiretórios de cada um deles
    local directories=()    #criação de um array para guardar os diretórios e subdiretórios
    
    for dir in "$@"; do     #ciclo for para percorrer todos os diretórios introduzidos
        if [ -d "$dir" ]; then 
            directories+=("$(find "$dir" -type d -exec printf "%s\n" "$script_dir/{}" \; 2>/dev/null)") #se o diretório introduzido no argumento existir, procurar os subdiretórios e adicionar tanto o diretório como os subdiretórios ao array com o caminho a partir da raiz com uma nova linha como separador, ignorando os erros
        else
            echo "Directory $dir does not exist" >&2   #se o diretório introduzido no argumento não existir, apresentar mensagem de erro
        fi
    done

    echo "${directories[*]}"    #retornar o array com os diretórios e subdiretórios
}

function search_files(){    #a função search_files irá receber os diretórios e subdiretórios devolvidos pela função search_dir e irá procurar os ficheiros que correspondam aos argumentos de chamada introduzidos
    local IFS=$'\n'     #a variável IFS(Internal Field Separator) irá separar os diretórios e subdiretórios recebidos no array por uma nova linha
    local directories=($(search_dir "$@"))  #a variável directories irá receber os diretórios e subdiretórios devolvidos pela função search_dir
    for dir in "${directories[@]}"; do      #ciclo for que irá percorrer os diretórios e subdiretórios recebidos
        if cd $dir 2>/dev/null && [ -z "$(find . -type f ! -readable)" ]; then  #se for possivel aceder aos diretórios e subdiretórios e todos os ficheiros dentro destes forem legiveis iremos calcular o tamanho dos ficheiros nos diretórios e subdiretórios
        size=0      #atribuir o valor 0 à variável size para esta náo ser nula
        for file in $(find . -type f -size +"$limitFilter"c -not -newermt "$(date --date="$dataDate" '+%Y-%m-%d %H:%M:%S')" | grep -E "$regex"); do     #ciclo for que irá procurar os ficheiros que cumpram as condições introduzidas nos argumentos
            size=$((size + $(du -s "$file" | awk '{print $1}')))    #calcular o tamanho dos ficheiros que cumpram as condições introduzidas nos argumentos e acumular na variável size
        done
        echo "$size $(realpath --relative-to="$script_dir" "$dir")"     #imprimir o tamanho total dos ficheiros no diretório que acabou de ser calculado e usando o realpath imprimir apenas o caminho que difere do diretório onde o script se encontra
        else
            echo "NA $(realpath --relative-to="$script_dir" "$dir")"    #se não for possivel aceder aos diretórios e subdiretórios ou algum dos ficheiros dentro destes não forem legiveis, imprimir NA no tamanho dos ficheiros no diretório e usando o realpath imprimir apenas o caminho que difere do diretório onde o script se encontra
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

search_files "$@"