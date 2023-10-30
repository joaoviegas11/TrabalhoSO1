#!n/bin/bash


index=1
# Loop para percorrer todos os parâmetros
while [ "$index" -le "$#" ]; do
    #parametro="${!index}"
    #echo "Parâmetro $index: $parametro"
    #Caso ultimo elemento
    case ${!index} in
    "-n")
        echo n;
        index=$((index + 1));
        #echo "${!index}"
        #if [[ "\"${!index}\"" =~ ^\".*\"$ ]]; then
        #    echo "A palavra está entre aspas duplas."
        #else
        #    echo "A palavra não está entre aspas duplas."
        #fi
    ;;
    
    "-d")
        echo d;
        index=$((index + 1));
        #echo "${!index}"
        #if [[ "\"${!index}\"" =~ ^\".*\"$ ]]; then
        #    echo "A palavra está entre aspas duplas."
        #else
        #    echo "A palavra não está entre aspas duplas."
        #fi
    ;;
    
    "-s")
        #echo s;
        index=$((index + 1));
        #echo "${!index}"
        if [[ "${!index}" =~ ^[0-9]+$ ]]; then
            echo "A variável é um número."
        else
            echo "A variável não é um número."
            exit 1
        fi
    ;;

    "-a")
        echo a;
        sort -n ./testetemp.txt >./temp1
    ;;
    "-l")
        index=$((index + 1));
        if [[ "${!index}" =~ ^[0-9]+$ ]]; then
            echo "A variável é um número."
        else
            echo "A variável não é um número."
        fi
        tail -"${!index}" ./temp1 >./temp
    ;;
    "-r")
        echo r;
    ;;
    ${!#})
        echo ultimo;
        if [ ! -d ${!#} ]; then
            echo "$(pwd)/${!#} é um diretório válido."
            exit 1
        fi
    ;;
     * )
    echo "Parametro invalido"
    exit 1
    
    
 ;;
esac
    index=$((index + 1))
done





function search_dir(){
    for dir in "${!#}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type d -exec du -s {} \; 2>/dev/null | awk '{print $1, $2}'>testetemp.txt
        else
            echo "$dir is not a directory"
        fi
    done
    

}

    

    cat ./temp
    rm ./temp ./temp1