#!/bin/bash

# Running command: ./cleanData-sort_cluster.sh <volume>
#	volume: the input data size, GB
  
producers="producer1 producer2 producer3 producer4"
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"
number_of_producers=$(wc -w <<< "$producers")
a=$(($1 / $number_of_producers))
directory=batch/sort/sort-$1"GB"


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
        /usr/local/hadoop/bin/hadoop fs -rm -r /outputs/'$directory'-results'


# Clean inout data from Unicage cluster
printf "\n>>> CLEANING THE UNICAGE CLUSTER\n\n"

ssh unicageleader 'rm -r ~/datav/outputs/'$directory'-results'

for i in $unicageworkers; do

    ping -c 1 $i &> /dev/null && {
	    ssh $i '
            rm -r ~/datav/datasets/'$directory'
            rm -r ~/datav/outputs/'$directory'-results'
	    continue
    }

    echo "Could not reach "$i

done