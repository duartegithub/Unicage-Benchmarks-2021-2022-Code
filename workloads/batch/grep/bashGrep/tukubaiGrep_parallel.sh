#!/bin/bash

# Running command: ./tukubaiGrep_parallel.sh <directory> <unicageworkers>
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

        # the number of CPU cores in this unicageworker
        worker_threads=$(ssh $i 'getconf _NPROCESSORS_ONLN')

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        task(){
            grep -Fo area < ~/datav/datasets/'$directory'/$1 | lcnt | awk '"'"'{print "area "$1}'"'"' >> ~/datav/outputs/'$output_directory'/split-'$i';
        }

        mkdir -p ~/datav/outputs/'$output_directory'/

        for file in $(ls ~/datav/datasets/'$directory'); do
            ((i=i%'$worker_threads')); ((i++==0)) && wait
            task "$file" &            
        done

        wait

        cat ~/datav/outputs/'$output_directory'/split-'$i' | sm2 1 1 2 2 > ~/datav/outputs/'$output_directory'/split.tmp
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

cat ~/datav/outputs/$output_directory/pre-output | sm2 1 1 2 2 > ~/datav/outputs/$output_directory/output
rm ~/datav/outputs/$output_directory/pre-output