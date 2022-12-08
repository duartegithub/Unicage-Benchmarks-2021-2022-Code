#!/bin/bash

# Running command: ./tukubaiSelect_parallel.sh <directory> <output_directory> <unicageworkers>
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

        task(){
            cat $1 | tr "|" " " | self 5 6 | awk '"'"'$2 > 990000'"'"' >> ~/datav/outputs/'$output_directory'/split-'$i'-$(basename -- $1);
        }

        mkdir -p ~/datav/outputs/'$output_directory'/

        for file in $(ls ~/datav/datasets/'$directory'/OS_ORDER_ITEM-*); do
            ((i=i%'$worker_threads')); ((i++==0)) && wait
            task "$file" &            
        done

        wait
        
        scp ~/datav/outputs/'$output_directory'/* unicageleader:~/datav/outputs/'$output_directory'/' &

	    continue
    }

    echo "Could not reach "$i

done

wait

for file in $(ls ~/datav/outputs/$output_directory); do

    cat ~/datav/outputs/$output_directory/$file >> ~/datav/outputs/$output_directory/output
    rm ~/datav/outputs/$output_directory/$file &

done