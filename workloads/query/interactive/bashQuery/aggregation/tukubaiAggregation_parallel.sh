#!/bin/bash

# Running command: ./tukubaiAggregation_parallel.sh <directory> <output_directory> <unicageworkers>
#   directory: the directory of the input data-set
#   output_directory: the directory where the output will be stored
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$2-results/unicage-result
unicageworkers=$3

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {

        # the number of CPU cores in this unicageworker
        worker_threads=$(ssh $i 'getconf _NPROCESSORS_ONLN')

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        task1(){
	        basename="$(basename -- $1)";
            tr "|" " " < $1 | self 3 4 | sm2 1 1 2 2 > ~/datav/outputs/'$output_directory'/tmp/$basename;
            split -l10000000 ~/datav/outputs/'$output_directory'/tmp/$basename ~/datav/outputs/'$output_directory'/tmp/$basename;
            rm ~/datav/outputs/'$output_directory'/tmp/$basename;
        }

        task2(){
            cat ~/datav/outputs/'$output_directory'/tmp/$1 | msort key=1 | sm2 1 1 2 2 >> ~/datav/outputs/'$output_directory'/split-'$i'
        }

        mkdir -p ~/datav/outputs/'$output_directory'/tmp
        
        for file in $(ls ~/datav/datasets/'$directory'/OS_ORDER_ITEM-*); do
            ((i=i%'$worker_threads')); ((i++==0)) && wait
            task1 "$file" &            
        done

        wait

        for file in $(ls ~/datav/outputs/'$output_directory'/tmp/); do
            ((i=i%'$worker_threads')); ((i++==0)) && wait
            task2 "$file" &
        done

        wait

        cat ~/datav/outputs/'$output_directory'/split-'$i' | LANG=C sort -k1,1 | awk NF | sm2 1 1 2 2 > ~/datav/outputs/'$output_directory'/split.tmp
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

cat ~/datav/outputs/$output_directory/pre-output | msort key=1 | awk NF | sm2 1 1 2 2 > ~/datav/outputs/$output_directory/output
# rm ~/datav/outputs/$output_directory/pre-output