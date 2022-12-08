#!/bin/bash

# Running command: ./simplify-metrics.sh <directory> <cluster>
#       directory: the directory where to read the .csv files from
#       cluster: the cluster under test, 0 for Hadoop Cluster, 1 for Unicage Cluster

basedir=$(dirname "$(readlink -f "$0")")
directory=$basedir/benchmark-results/$1
cluster=$2

[ ! -d $directory/treated-data ] && {
    exit
}

rm -r $directory/tikz &> /dev/null
mkdir -p $directory/tikz
cd $directory

# Selecting cluster to be observed
if [[ $cluster -eq 0 ]]
then

    printf "\n>>> SIMPLIFYING METRICS - HADOOP CLUSTER\n\n"
    workerprefix="datanode"
    leaderprefix="namenode"

elif [[ $cluster -eq 1 ]]
then

    printf "\n>>> SIMPLIFYING METRICS - UNICAGE CLUSTER\n\n"
    workerprefix="unicageworker"
    leaderprefix="unicageleader"

else

    exit

fi

for file in $(ls treated-data/*.csv); do 
    filename=$(basename $file)
    cat treated-data/$filename | head -n 1 > tikz/$filename
    cat treated-data/$filename | tail -n +2 | nl | head -n 1 > tikz/$filename-tmp
    cat treated-data/$filename | tail -n +2 | nl | awk 'NR%60==0' >> tikz/$filename-tmp
    cat treated-data/$filename | tail -n +2 | nl | tail -n 1 >> tikz/$filename-tmp
    cat tikz/$filename-tmp | tr "," " " | awk '{print $1" "$4}' | tr " " "," >> tikz/$filename
    rm tikz/$filename-tmp
done
