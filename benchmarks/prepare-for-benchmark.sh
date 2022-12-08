#!/bin/bash

# Running command: ./prepare-for-benchmark.sh <cluster> 
#       cluster: the cluster under test, 0 for Hadoop Cluster, 1 for Unicage Cluster

cluster=$1

hostnames="localhost"


# Selecting cluster to be benchmarked
if [[ $cluster -eq 0 ]]
then

    hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode"

elif [[ $cluster -eq 1 ]]
then

    hostnames="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader"

fi


# Preparing cluster for benchmark
for i in $hostnames; do

    echo "Preparing "$i" for the benchmark" 

    ping -c 1 $i &> /dev/null && {

        # Cleaning RAM
        ssh $i 'sh -c '"'"'echo 1 >  /proc/sys/vm/drop_caches'"'"''
        
        continue
    } 
    
    echo "Could not reach "$i

done

