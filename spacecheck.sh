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
echo "$vn $vr $vd "

