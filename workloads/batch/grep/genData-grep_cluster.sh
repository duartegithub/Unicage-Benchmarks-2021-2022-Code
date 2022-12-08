#!/bin/bash

# Running command: ./genData-grep_cluster.sh <volume>
#	volume: the input data size, GB

basedir=$(dirname "$(readlink -f "$0")")
producers="producer1 producer2 producer3 producer4"
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"
number_of_producers=$(wc -w <<< "$producers")
a=$(($1 / $number_of_producers))
directory=batch/grep/grep-$1"GB"
let number_of_files_per_producer=a*2

BOA=/home/BOA
TUKUBAI=/home/TOOL


# Generate input data
start_generation=$(date +%s)
printf "\n>>> STARTING DATA GENERATION: $(date -u) ($start_generation)\n\n"

for i in $producers; do

    echo $i" is starting generation" 

    ping -c 1 $i &> /dev/null && {

        ssh $i	'cd ~/implementation/BigDataGeneratorSuite/Text_datagen/
		rm -fr ~/datav/datasets/'$directory'
		./gen_text_data.sh lda_wiki1w '$number_of_files_per_producer' 8000 10000 ~/datav/datasets/'$directory'' &
        sleep 2
        continue
    } 
    
    echo "Could not reach "$i

done

wait

end_generation=$(date +%s)
printf "\n>>> ENDING DATA GENERATION: $(date -u) ($end_generation)\n\n"


# Clean inputs/outputs in HDFS before loading
printf "\n>>> CLEANING PREVIOUS INPUTS/OUTPUTS (HDFS)\n\n"

ssh ${producers%% *} '
        /usr/local/hadoop/bin/hadoop fs -rm -r /datasets/'$directory'
        /usr/local/hadoop/bin/hadoop fs -mkdir -p /datasets/'$directory' 
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/'$directory'-results'


# Load input data into HDFS
start_loading_hdfs=$(date +%s)
printf "\n>>> STARTING DATA LOADING (HDFS): $(date -u) ($start_loading_hdfs)\n\n"

for i in $producers; do

    ping -c 1 $i &> /dev/null && {
        ssh $i	'/usr/local/hadoop/bin/hadoop fs -put ~/datav/datasets/'$directory'/* /datasets/'$directory'' &
        continue
    } 
    
    echo "Could not reach "$i

done

wait

end_loading_hdfs=$(date +%s)
printf "\n>>> ENDING DATA LOADING (HDFS): $(date -u) ($end_loading_hdfs)\n\n"


# Print HDFS tree structure for the input data
printf "\n>>> PRINTING HDFS TREE STRUCTURE FOR GENERATED DATA\n\n"

echo "HDFS: /datasets/"$directory
ssh ${producers%% *} '/usr/local/hadoop/bin/hadoop fs -ls -R /datasets/'$directory' | awk '"'"'{print $8}'"'"' | sed -e '"'"'s/[^-][^\/]*\//--/g'"'"' -e '"'"'s/^/ /'"'"' -e '"'"'s/-/|/'"'"''


# Clean inputs/outputs in the Unicage cluster before loading
printf "\n>>> CLEANING PREVIOUS INPUTS/OUTPUTS (UNICAGE)\n\n"

ssh unicageleader 'rm -r ~/datav/outputs/'$directory'-results'

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {
        ssh $i '
            rm -r ~/datav/datasets/'$directory'
            rm -r ~/datav/outputs/'$directory'-results
            mkdir -p ~/datav/datasets/'$directory''
        continue
    }

    echo "Could not reach "$i

done


# Load input data into the Unicage cluster
start_loading_unicage=$(date +%s)
printf "\n>>> STARTING DATA LOADING (UNICAGE): $(date -u) ($start_loading_unicage)\n\n"

for i in $producers; do

    ping -c 1 $i &> /dev/null && {

        ssh $i 'export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT

        rm ~/unicageworkers

        for worker in '$unicageworkers'; do
            echo $worker >> ~/unicageworkers
        done

        for file in $(ls ~/datav/datasets/'$directory'/lda_wiki1w_*_'$i'); do 
            distr-distr ~/unicageworkers $file $file
            rm $file 
        done' &

    continue
    }

    echo "Could not reach "$i

done

wait

end_loading_unicage=$(date +%s)
printf "\n>>> ENDING DATA LOADING (UNICAGE): $(date -u) ($end_loading_unicage)\n\n"


# Print Unicage cluster tree structure for the input data
printf "\n>>> PRINTING UNICAGE TREE STRUCTURE FOR GENERATED DATA\n\n"

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {
        echo $i": ~/datav/datasets/"$directory
        ssh $i 'ls ~/datav/datasets/'$directory' | awk '"'"'{print " |-------"$1}'"'"''
        continue
    }

    echo "Could not reach "$i

done


# Clean input data from producers
printf "\n>>> CLEANING PRODUCERS LOCALLY\n\n"

for i in $producers; do

    ping -c 1 $i &> /dev/null && {
        ssh $i	'rm -r ~/datav/datasets/'$directory''
        continue
    } 
    
    echo "Could not reach "$i

done


# Collect data generation/loading metrics
printf "\n>>> COLLECTING METRICS\n\n"
benchmark_directory=$basedir/../../../benchmarks/benchmark-results/$directory

generation_time=$(($end_generation - $start_generation))
echo $generation_time" seconds" > $benchmark_directory/generation_time
echo "Start: "$(date -d @$start_generation) >> $benchmark_directory/generation_time
echo "End: "$(date -d @$end_generation) >> $benchmark_directory/generation_time

loading_hdfs_time=$(($end_loading_hdfs - $start_loading_hdfs))
echo $loading_hdfs_time" seconds" > $benchmark_directory/loading_hdfs_time
echo "Start: "$(date -d @$start_loading_hdfs) >> $benchmark_directory/loading_hdfs_time
echo "End: "$(date -d @$end_loading_hdfs) >> $benchmark_directory/loading_hdfs_time

loading_unicage_time=$(($end_loading_unicage - $start_loading_unicage))
echo $loading_unicage_time" seconds" > $benchmark_directory/loading_unicage_time
echo "Start: "$(date -d @$start_loading_unicage) >> $benchmark_directory/loading_unicage_time
echo "End: "$(date -d @$end_loading_unicage) >> $benchmark_directory/loading_unicage_time