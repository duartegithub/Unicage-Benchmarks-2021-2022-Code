#!/bin/bash

# Running command: ./treat-metrics.sh <directory> <cluster>
#       directory: the directory where to read the .csv files from
#       cluster: the cluster under test, 0 for Hadoop Cluster, 1 for Unicage Cluster

basedir=$(dirname "$(readlink -f "$0")")
directory=$basedir/benchmark-results/$1
cluster=$2

[ ! -d $directory/raw-data ] && {
    exit
}

rm -r $directory/treated-data &> /dev/null
mkdir -p $directory/treated-data
cd $directory

# Selecting cluster to be observed
if [[ $cluster -eq 0 ]]
then

    printf "\n>>> TREATING METRICS - HADOOP CLUSTER\n\n"
    workerprefix="datanode"
    leaderprefix="namenode"

elif [[ $cluster -eq 1 ]]
then

    printf "\n>>> TREATING METRICS - UNICAGE CLUSTER\n\n"
    workerprefix="unicageworker"
    leaderprefix="unicageleader"

else

    exit

fi

######################################
# EXECUTION TIME & DPS
######################################

head -n 1 raw-data/execution_time | awk '{print $1}' > treated-data/execution_time
cat raw-data/data_processed_per_second | awk '{print $1}' > treated-data/data_processed_per_second

######################################
# CPU
######################################

echo "time,usage" > treated-data/$leaderprefix-cpu.csv
tail -n +2 raw-data/$leaderprefix-cpu.csv | awk -F, '
{
    usage = 0; 
    for (i=2; i<=NF; i++) {
        usage += $i;
    }
    print $1","usage;
}
' >> treated-data/$leaderprefix-cpu.csv

count=1
while true; do
    [ -e raw-data/$workerprefix$count-cpu.csv ] || break
    echo "time,usage" > treated-data/$workerprefix$count-cpu.csv
    tail -n +2 raw-data/$workerprefix$count-cpu.csv | awk -F, '
    {
        usage = 0; 
        for (i=2; i<=NF; i++) {
            usage += $i;
        }
        print $1","usage;
    }
    ' >> treated-data/$workerprefix$count-cpu.csv
    tail -n +2 treated-data/$workerprefix$count-cpu.csv >> treated-data/compound-cpu.csv

    count=$(($count + 1))
done

count=$(($count - 1))
echo "time,usage" > treated-data/compound-cpu.csv.tmp
cat treated-data/compound-cpu.csv | awk -F, '{a[$1]+=$2;}END{for(i in a)print i","a[i]/'$count';}' | sort -k 1 >> treated-data/compound-cpu.csv.tmp
mv treated-data/compound-cpu.csv.tmp treated-data/compound-cpu.csv


######################################
# IO
######################################

echo "time,in,out" > treated-data/$leaderprefix-io.csv
tail -n +2 raw-data/$leaderprefix-io.csv >> treated-data/$leaderprefix-io.csv

count=1
while true; do
    [ -e raw-data/$workerprefix$count-io.csv ] || break
    echo "time,in,out" > treated-data/$workerprefix$count-io.csv
    tail -n +2 raw-data/$workerprefix$count-io.csv >> treated-data/$workerprefix$count-io.csv
    tail -n +2 treated-data/$workerprefix$count-io.csv >> treated-data/compound-io.csv

    count=$(($count + 1))
done

count=$(($count - 1))
echo "time,in,out" > treated-data/compound-io.csv.tmp
cat treated-data/compound-io.csv | awk -F, '{a[$1]+=$2;b[$1]+=$3;}END{for(i in a)print i","a[i]","b[i];}' | sort -k 1 >> treated-data/compound-io.csv.tmp
mv treated-data/compound-io.csv.tmp treated-data/compound-io.csv


######################################
# NETWORK
######################################

echo "time,in,out" > treated-data/$leaderprefix-network.csv
tail -n +2 raw-data/$leaderprefix-network.csv >> treated-data/$leaderprefix-network.csv

count=1
while true; do
    [ -e raw-data/$workerprefix$count-network.csv ] || break
    echo "time,in,out" > treated-data/$workerprefix$count-network.csv
    tail -n +2 raw-data/$workerprefix$count-network.csv >> treated-data/$workerprefix$count-network.csv
    tail -n +2 treated-data/$workerprefix$count-network.csv >> treated-data/compound-network.csv

    count=$(($count + 1))
done

count=$(($count - 1))
echo "time,in,out" > treated-data/compound-network.csv.tmp
cat treated-data/compound-network.csv | awk -F, '{a[$1]+=$2;b[$1]+=$3;}END{for(i in a)print i","a[i]","b[i];}' | sort -k 1 >> treated-data/compound-network.csv.tmp
mv treated-data/compound-network.csv.tmp treated-data/compound-network.csv


######################################
# RAM
######################################

echo "time,free,used" > treated-data/$leaderprefix-ram.csv
tail -n +2 raw-data/$leaderprefix-ram.csv | awk -F, '
{
    free = $2+$4
    used = $3+$5
    print $1","free","used;
}
' >> treated-data/$leaderprefix-ram.csv

count=1
while true; do
    [ -e raw-data/$workerprefix$count-ram.csv ] || break
    echo "time,free,used" > treated-data/$workerprefix$count-ram.csv
    tail -n +2 raw-data/$workerprefix$count-ram.csv | awk -F, '
    {
        free = $2+$4
        used = $3+$5
        print $1","free","used;
    }
    ' >> treated-data/$workerprefix$count-ram.csv
    tail -n +2 treated-data/$workerprefix$count-ram.csv >> treated-data/compound-ram.csv


    count=$(($count + 1))
done

count=$(($count - 1))
echo "time,free,used" > treated-data/compound-ram.csv.tmp
cat treated-data/compound-ram.csv | awk -F, '{a[$1]+=$2;b[$1]+=$3;}END{for(i in a)print i","a[i]","b[i];}' | sort -k 1 >> treated-data/compound-ram.csv.tmp
mv treated-data/compound-ram.csv.tmp treated-data/compound-ram.csv