#!/bin/bash

# Running command: ./tukubaiJoin.sh <directory> <output_directory> <unicageworkers>
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

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        mkdir -p ~/datav/outputs/'$output_directory'/tmp/master
        mkdir -p ~/datav/outputs/'$output_directory'/tmp/tran

        for file in $(ls ~/datav/datasets/'$directory'/OS_ORDER-producer*); do 

            basename="$(basename -- $file)"
            tr "|" " " < $file | self 1 2 >> ~/datav/outputs/'$output_directory'/tmp/master/$basename            
            split -l420000000 ~/datav/outputs/'$output_directory'/tmp/master/$basename ~/datav/outputs/'$output_directory'/tmp/master/$basename;
            rm ~/datav/outputs/'$output_directory'/tmp/master/$basename

        done

        for master_split in $(ls ~/datav/outputs/'$output_directory'/tmp/master/); do 

            LANG=C sort -c ~/datav/outputs/'$output_directory'/tmp/master/$master_split &> /dev/null || {
                LANG=C sort -k1,1 < ~/datav/outputs/'$output_directory'/tmp/master/$master_split > ~/datav/outputs/'$output_directory'/tmp/master/${master_split}-tmp
                mv ~/datav/outputs/'$output_directory'/tmp/master/${master_split}-tmp ~/datav/outputs/'$output_directory'/tmp/master/$master_split
            }
            
        done

        for worker in '$unicageworkers'; do

            for tran_file in $(ssh $worker '"'"'ls ~/datav/datasets/'$directory'/OS_ORDER_ITEM-producer*'"'"'); do
                
                basename_tran="$(basename -- $tran_file)"
                scp $worker:$tran_file ~/datav/outputs/'$output_directory'/tmp/tran/$basename_tran
                tr "|" " " < ~/datav/outputs/'$output_directory'/tmp/tran/$basename_tran | self 2 6 > ~/datav/outputs/'$output_directory'/tmp/tran/${basename_tran}-tmp
                mv ~/datav/outputs/'$output_directory'/tmp/tran/${basename_tran}-tmp ~/datav/outputs/'$output_directory'/tmp/tran/$basename_tran

                for master_split in $(ls ~/datav/outputs/'$output_directory'/tmp/master/); do 
                    cjoin1 key=1 ~/datav/outputs/'$output_directory'/tmp/master/$master_split ~/datav/outputs/'$output_directory'/tmp/tran/$basename_tran >> ~/datav/outputs/'$output_directory'/split-'$i'
                done

                rm ~/datav/outputs/'$output_directory'/tmp/tran/$basename_tran

            done

        done
        
        scp ~/datav/outputs/'$output_directory'/split-'$i' unicageleader:~/datav/outputs/'$output_directory'/' &

	    continue
    }

    echo "Could not reach "$i

done

wait

for file in $(ls ~/datav/outputs/$output_directory); do

    self 2 3 < ~/datav/outputs/$output_directory/$file >> ~/datav/outputs/$output_directory/output
    rm ~/datav/outputs/$output_directory/$file &

done