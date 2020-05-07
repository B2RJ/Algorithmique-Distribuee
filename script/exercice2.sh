#!/bin/bash
let "min = 1000000"
let "max = 0"
let "sum = 0"
#dmd -of=./out/exercice2  ../exercice2.d
for i in {1..1000}
do
    let current=$(./out/exercice2)
    let "sum = sum + current"
    if [ $min -gt $current ]
    then    
        let "min = current" 
    fi
    if [ $max -lt $current ]
    then    
        let "max = current" 
    fi
    echo $current
done
let "sum = sum / 1000"
echo min : $min
echo max : $max
echo average = $sum