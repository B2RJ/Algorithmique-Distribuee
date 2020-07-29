#!/bin/bash
let "min = 1000000"
let "max = 0"
let "sum = 0"
dmd -of=./out/exercice2sleep  ./src/exercice2sleep.d
for i in {1..100}
do
    let current=$(./out/exercice2sleep)
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
let "sum = sum / 100"
echo min : $min
echo max : $max
echo average = $sum