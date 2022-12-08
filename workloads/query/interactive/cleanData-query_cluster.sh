#!/bin/bash

# Running command: ./cleanData-query_cluster.sh <volume>
#	volume: the input data size, GB
  
producers="producer1 producer2 producer3 producer4"
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"
number_of_producers=$(wc -w <<< "$producers")
a=$(($1 / $number_of_producers))
directory=query/query-$1"GB"


# Clean input data from producers
printf "\n>>> CLEANING PRODUCERS LOCALLY\n\n"

for i in $producers; do

    ping -c 1 $i &> /dev/null && {
        ssh $i	'rm -r ~/datav/datasets/'$directory''
        continue
    } 
    
    echo "Could not reach "$i

done


# Clean input data from HDFS
printf "\n>>> CLEANING HDFS\n\n"

ssh ${producers%% *} '
        /usr/local/hadoop/bin/hadoop fs -rm -r /datasets/'$directory'
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/aggregation/aggregation-'$1'"GB"-results
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/join/join-'$1'"GB"-results
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/query/select/select-'$1'"GB"-results'


# Cleaning Hive tables
printf "\n>>> CLEANING HIVE\n\n"

ssh namenode 'export HADOOP_HOME=/usr/local/hadoop/
/usr/local/hive/bin/hive --hivevar gbsize='$1' -f ~/implementation/workloads/query/interactive/SQLQuery/clean-hive.sql'


# Clean inout data from Unicage cluster
printf "\n>>> CLEANING THE UNICAGE CLUSTER\n\n"

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {
	    ssh $i 'rm -r ~/datav/datasets/'$directory''
	    continue
    }

    echo "Could not reach "$i

done

