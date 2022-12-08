#!/bin/bash

# Running command: ./tukubaiWordcount.sh <directory> <unicageworkers>
#   directory: the directory of the input data-set
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$directory-results/unicage-result
unicageworkers=$2

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        mkdir -p ~/datav/outputs/'$output_directory'/
        
        for file in $(ls ~/datav/datasets/'$directory'); do
            tr " " "\n" < ~/datav/datasets/'$directory'/$file | awk NF | msort key=1 | count 1 1 >> ~/datav/outputs/'$output_directory'/split-'$i'
        done
        
        cat ~/datav/outputs/'$output_directory'/split-'$i' | msort key=1 | sm2 1 1 2 2 > ~/datav/outputs/'$output_directory'/split.tmp
        mv ~/datav/outputs/'$output_directory'/split.tmp ~/datav/outputs/'$output_directory'/split-'$i'
        scp ~/datav/outputs/'$output_directory'/split-'$i' unicageleader:~/datav/outputs/'$output_directory'/' &

	    continue
    }

    echo "Could not reach "$i

done

wait

for file in $(ls ~/datav/outputs/$output_directory); do

    cat ~/datav/outputs/$output_directory/$file >> ~/datav/outputs/$output_directory/pre-output
    rm ~/datav/outputs/$output_directory/$file &

done

cat ~/datav/outputs/$output_directory/pre-output | msort key=1 | sm2 1 1 2 2 > ~/datav/outputs/$output_directory/output
rm ~/datav/outputs/$output_directory/pre-output