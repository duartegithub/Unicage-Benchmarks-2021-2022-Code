#!/bin/bash

# Running command: ./tukubaiSortV3_parallel_fifo.sh <directory> <unicageworkers>
#   directory: the directory of the input data-set
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$directory-results/unicage-result
unicageworkers=$2

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/tmp/
mkdir -p ~/datav/outputs/$output_directory/tmp_sort/

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
            msort key=1 < ~/datav/datasets/'$directory'/$file > ~/datav/outputs/'$output_directory'/tmp/$1-'$i';
        }

        mkdir -p ~/datav/outputs/'$output_directory'/tmp/

        open_sem '$worker_threads'
        for file in $(ls ~/datav/datasets/'$directory'); do
            run_with_lock task "$file"            
        done

        wait
     
        scp ~/datav/outputs/'$output_directory'/tmp/* unicageleader:~/datav/outputs/'$output_directory'/tmp/' &

        continue
    
    }
    
    echo "Could not reach "$i

done

wait

export TMPDIR=~/datav/outputs/$output_directory/tmp_sort/
LANG=C sort --merge --batch-size=1000 ~/datav/outputs/$output_directory/tmp/* > ~/datav/outputs/$output_directory/output
# rm -r ~/datav/outputs/$output_directory/tmp/
