#!n/bin/bash

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
        # Implemente a lógica para a opção -d aqui
        ;;
    s)
        echo "Opção s, argumento: $OPTARG"
        if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
            echo "A variável é um número."
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

if [[ $reverse -eq 1 ]]; then 
    sort -r ./testetemp.txt >./temp
    cat ./temp > ./testetemp.txt
    rm temp
    fi
if [[ $ordered -eq 1 ]]; then 
    sort -n ./testetemp.txt >./temp
    cat ./temp > ./testetemp.txt
    rm temp
    fi
if [[ $limit -gt 0 ]]; then 
    tail -"$limit" ./testetemp.txt >./temp
    cat ./temp > ./testetemp.txt
    rm temp
fi
dataDate='Sep 10 10:00'
timeFilter=$(date --date=$data +%s) 
timeNow=$(date +%s)
echo $timeFilter
echo $timeNow
if [[ $timeFilter -gt $timeNow ]]; then 
    echo maior
    else
    echo menor
fi
echo "$(date  --date='Dec 10 10:00' +%s)"