#!/bin/bash

# Running command: ./tukubaiSort.sh <directory> <unicageworkers>
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
        touch ~/datav/outputs/'$output_directory'/split-'$i'

        for file in $(ls ~/datav/datasets/'$directory'); do
            msort key=1 < ~/datav/datasets/'$directory'/$file > ~/datav/outputs/'$output_directory'/split_file
            up3 key=1 ~/datav/outputs/'$output_directory'/split-'$i' ~/datav/outputs/'$output_directory'/split_file > ~/datav/outputs/'$output_directory'/split-'$i'_tmp
            mv ~/datav/outputs/'$output_directory'/split-'$i'_tmp ~/datav/outputs/'$output_directory'/split-'$i'
        done' &

	    continue
    }

    echo "Could not reach "$i

done

wait

touch ~/datav/outputs/$output_directory/output

for i in $unicageworkers; do

    scp $i:~/datav/outputs/$output_directory/split-$i ~/datav/outputs/$output_directory/pre-output
    up3 key=1 ~/datav/outputs/$output_directory/output ~/datav/outputs/$output_directory/pre-output > ~/datav/outputs/$output_directory/output_tmp
    mv ~/datav/outputs/$output_directory/output_tmp ~/datav/outputs/$output_directory/output

done

rm ~/datav/outputs/$output_directory/pre-output
