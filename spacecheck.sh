#!n/bin/bash

vn=0
vr=0
vd=0
for i in $*; do
    if [[ "$i"  == "-n" ]]; then
    vn=1
    fi
    if [[ "$i"  == "-r" ]]; then
    vr=1
    fi
    if [[ "$i"  == "-d" ]]; then
    vd=1
    fi
done

if [[ "$vn"  == "1" ]]; then
    pwd
    fi
echo "$vn $vr  $vd "
echo ("teste")
echo ("teste1")

function arg_check(){
    if [ $# -lt 1 ]; then
        echo "Not enough arguments."
        echo "Usage: spacecheck.sh directory"
        return
    fi
}

function search_dir(){
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            find "$dir" -type d -exec du -s {} \; 2>/dev/null | awk '{print $1, $2}'
        else
            echo "$dir is not a directory"
        fi
    done
}