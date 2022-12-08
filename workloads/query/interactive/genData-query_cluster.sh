#!/bin/bash

# Running command: ./genData-query_cluster.sh <volume>
#	volume: the input data size, GB

basedir=$(dirname "$(readlink -f "$0")")
producers="producer1 producer2 producer3 producer4"
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"
number_of_producers=$(wc -w <<< "$producers")
a=$(($1 / $number_of_producers))
directory=query/query-$1"GB"
rows_per_producer=$(($a * 14000000))

BOA=/home/BOA
TUKUBAI=/home/TOOL


# Generate input data
start_generation=$(date +%s)
printf "\n>>> STARTING DATA GENERATION: $(date -u) ($start_generation)\n\n"

row_multiplier=0
for i in $producers; do

    # Generating random 9-digit input seed
    rnd=$(tr -cd "[:digit:]" < /dev/urandom | head -c 10)

    # Calculating first row Id for the tables
    first_id=$(($rows_per_producer * $row_multiplier))
    echo $i" is starting generation from row number "$first_id 

    ping -c 1 $i &> /dev/null && {

        ssh $i 'cd ~/implementation/BigDataGeneratorSuite/Table_datagen/e-com/
        awk -v toedit="\t<seed>'$rnd'</seed>" '"'"'/<seed>/{print toedit; next} 1'"'"' config/demo-schema.xml > config/demo-schema_tmp.xml
        awk -v toedit="\t<gen_IdGenerator><min>'$first_id'</min></gen_IdGenerator>" '"'"'/<gen_IdGenerator/{print toedit; next} 1'"'"' config/demo-schema_tmp.xml > config/demo-schema_cluster.xml
        awk -v toedit="\t\t<outputDir>/root/datav/datasets/'$directory'/</outputDir>" '"'"'/<outputDir>/{print toedit; next} 1'"'"' config/demo-generation.xml > config/demo-generation_cluster.xml
        rm  config/demo-schema_tmp.xml
        rm -r ~/datav/datasets/'$directory'
        java -XX:NewRatio=1 -jar pdgf.jar -l demo-schema_cluster.xml -l demo-generation_cluster.xml -ns -s -sf $(('$a' * 140))
        mv ~/datav/datasets/'$directory'/OS_ORDER.txt ~/datav/datasets/'$directory'/OS_ORDER-${HOSTNAME}.txt
        mv ~/datav/datasets/'$directory'/OS_ORDER_ITEM.txt ~/datav/datasets/'$directory'/OS_ORDER_ITEM-${HOSTNAME}.txt' &
        
        # Incrementing the row multiplier
        row_multiplier=$(($row_multiplier + 1))
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
        /usr/local/hadoop/bin/hadoop fs -mkdir -p /datasets/'$directory'/item
        /usr/local/hadoop/bin/hadoop fs -mkdir -p /datasets/'$directory'/order
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/aggregation/aggregation-'$1'"GB"-results
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/join/join-'$1'"GB"-results
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/select/select-'$1'"GB"-results'

ssh namenode 'export HADOOP_HOME=/usr/local/hadoop/
    /usr/local/hive/bin/hive --hivevar gbsize='$1' -f ~/implementation/workloads/query/interactive/SQLQuery/clean-hive.sql'


# Load input data into HDFS
start_loading_hdfs=$(date +%s)
printf "\n>>> STARTING DATA LOADING (HDFS): $(date -u) ($start_loading_hdfs)\n\n"

for i in $producers; do

    ping -c 1 $i &> /dev/null && {
        ssh $i	'
        /usr/local/hadoop/bin/hadoop fs -put ~/datav/datasets/'$directory'/OS_ORDER_ITEM-*.txt /datasets/'$directory'/item
        /usr/local/hadoop/bin/hadoop fs -put ~/datav/datasets/'$directory'/OS_ORDER-*.txt /datasets/'$directory'/order' &
        continue
    } 

    echo "Could not reach "$i

done

wait


# Load data into Hive
printf "\n>>> CREATING HIVE TABLES\n\n"

ssh namenode 'export HADOOP_HOME=/usr/local/hadoop/
    /usr/local/hive/bin/hive --hivevar gbsize='$1' -f ~/implementation/workloads/query/interactive/SQLQuery/gen-hive.sql'    

end_loading_hdfs=$(date +%s)
printf "\n>>> ENDING DATA LOADING (HDFS): $(date -u) ($end_loading_hdfs)\n\n"


# Print HDFS tree structure for the input data
printf "\n>>> PRINTING HDFS TREE STRUCTURE FOR GENERATED DATA\n\n"

echo "HDFS: /datasets/"$directory
ssh ${producers%% *} '/usr/local/hadoop/bin/hadoop fs -ls -R /datasets/'$directory' | awk '"'"'{print $8}'"'"' | sed -e '"'"'s/[^-][^\/]*\//--/g'"'"' -e '"'"'s/^/ /'"'"' -e '"'"'s/-/|/'"'"''


# Clean inputs/outputs in the Unicage cluster before loading
printf "\n>>> CLEANING PREVIOUS INPUTS/OUTPUTS (UNICAGE)\n\n"

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {
	    ssh $i 'rm -r ~/datav/datasets/'$directory'
        rm -r ~/datav/outputs/query/aggregation/aggregation-'$1'"GB"-results
        rm -r ~/datav/outputs/query/join/join-'$1'"GB"-results
        rm -r ~/datav/outputs/query/select/select-'$1'"GB"-results
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

        for file in $(ls ~/datav/datasets/'$directory'/OS_ORDER*-'$i'.txt); do 
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
benchmark_directory=$basedir/../../../benchmarks/benchmark-results/query/
benchmark_directory_aggregation=$benchmark_directory/aggregation/aggregation-$1"GB"
benchmark_directory_join=$benchmark_directory/join/join-$1"GB"
benchmark_directory_select=$benchmark_directory/select/select-$1"GB"

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

for i in $(ls $benchmark_directory | grep time); do
    cp $benchmark_directory/$i $benchmark_directory_aggregation/$i
    cp $benchmark_directory/$i $benchmark_directory_join/$i
    cp $benchmark_directory/$i $benchmark_directory_select/$i
    rm $benchmark_directory/$i
done