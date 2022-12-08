#!/bin/bash

# Running command: ./netdata-collect.sh <volume> <cluster> <directory> <start-date> <end-date>
#	    volume: the input data size, GB
#       cluster: the cluster under test, 0 for Hadoop Cluster, 1 for Unicage Cluster
#       directory: the directory to store the .csv files
#       start-date: the date the workload started, in seconds
#       end-date: the date the workload ended, in seconds

a=$1
cluster=$2
start=$4
end=$5
basedir=$(dirname "$(readlink -f "$0")")
directory=$basedir/benchmark-results/$3

[ ! -d $directory ] && {
    exit
}

mkdir -p $directory/raw-data

hostnames="localhost"


# Selecting cluster to be observed
if [[ $cluster -eq 0 ]]
then

    hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode"

elif [[ $cluster -eq 1 ]]
then

    hostnames="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader"

fi


# Extracting resource usage metrics
for i in $hostnames; do

    while true; do
        
        sleep 1
        echo > /dev/tcp/$i/19999 && break || continue

    done

    echo "Downloading metrics from "$i 

    ping -c 1 $i &> /dev/null && {

        curl -Ss 'http://'$i':19999/api/v1/data?chart=system.cpu&before='$(($end + 2))'&after='$(($start - 2))'&format=csv' > $directory/raw-data/$i-cpu.csv
        curl -Ss 'http://'$i':19999/api/v1/data?chart=system.io&before='$(($end + 2))'&after='$(($start - 2))'&format=csv' > $directory/raw-data/$i-io.csv
        curl -Ss 'http://'$i':19999/api/v1/data?chart=system.ram&before='$(($end + 2))'&after='$(($start - 2))'&format=csv' > $directory/raw-data/$i-ram.csv
        curl -Ss 'http://'$i':19999/api/v1/data?chart=system.ip&before='$(($end + 2))'&after='$(($start - 2))'&format=csv' > $directory/raw-data/$i-network.csv

        continue
    } 
    
    echo "Could not reach "$i

done


# Extracting execution time metric
execution_time=$(($end - $start))
echo $execution_time" seconds" > $directory/raw-data/execution_time
echo "Start: "$(date -d @$start) >> $directory/raw-data/execution_time
echo "End: "$(date -d @$end) >> $directory/raw-data/execution_time


# Extracting data processed per second metric
dps=$(bc -l <<< ''$a'/'$execution_time'') 
echo $dps" GB/s" > $directory/raw-data/data_processed_per_second


# Treating metrics data for plotting
$basedir/treat-metrics.sh $3 $cluster
$basedir/simplify-metrics.sh $3 $cluster
