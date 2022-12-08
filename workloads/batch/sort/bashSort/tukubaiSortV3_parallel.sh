#!/bin/bash

# Running command: ./tukubaiSortV3_parallel.sh <directory> <unicageworkers>
#   directory: the directory of the input data-set
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$directory-results/unicage-result
unicageworkers=$2

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/tmp/

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {

        # the number of CPU cores in this unicageworker
        worker_threads=$(ssh $i 'getconf _NPROCESSORS_ONLN')

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        task(){
            msort key=1 < ~/datav/datasets/'$directory'/$file > ~/datav/outputs/'$output_directory'/tmp/$1;
        }

        mkdir -p ~/datav/outputs/'$output_directory'/tmp/

        for file in $(ls ~/datav/datasets/'$directory'); do
            ((i=i%'$worker_threads')); ((i++==0)) && wait
            task "$file" &             
        done

        wait
        
        sort --merge ~/datav/outputs/'$output_directory'/tmp/* > ~/datav/outputs/'$output_directory'/split-'$i'
        scp ~/datav/outputs/'$output_directory'/split-'$i' unicageleader:~/datav/outputs/'$output_directory'/tmp/' &

	    continue
    }

    echo "Could not reach "$i

done

wait

sort --merge ~/datav/outputs/$output_directory/tmp/* > ~/datav/outputs/$output_directory/output
rm -r ~/datav/outputs/$output_directory/tmp/
