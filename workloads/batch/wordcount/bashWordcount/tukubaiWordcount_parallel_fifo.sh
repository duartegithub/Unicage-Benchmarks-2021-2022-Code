#!/bin/bash

# Running command: ./tukubaiWordcount_parallel_fifo.sh <directory> <unicageworkers>
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

        open_sem(){
            mkfifo pipe-$$
            exec 3<>pipe-$$
            rm pipe-$$
            local i=$1
            for((;i>0;i--)); do
                printf %s 000 >&3
            done
        }

        run_with_lock(){
            local x
            read -u 3 -n 3 x && ((0==x)) || exit $x
            (
            ( "$@"; )
            printf '"'"'%.3d'"'"' $? >&3
            )&
        }

        task(){
            tr " " "\n" < ~/datav/datasets/'$directory'/$1 | awk NF | msort key=1 | count 1 1 >> ~/datav/outputs/'$output_directory'/split-'$i';
        }

        mkdir -p ~/datav/outputs/'$output_directory'/

        open_sem '$worker_threads'
        for file in $(ls ~/datav/datasets/'$directory'); do
            run_with_lock task "$file"
        done

        wait

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