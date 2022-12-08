#!/bin/bash

# Running command: ./run-hadoop-wordcount.sh <volume> <behcnmark-mode>
#   volume: the input data size, GB
#   benchmark-mode: write "benchmark-mode" to run this script in benchmark mode (repeat 3 times)
  
a=$1
basedir=$(dirname "$(readlink -f "$0")")

runs="run1"

[ "$2" = "benchmark-mode" ] && {
    printf "\n>>> BENCHMARK-MODE: THE WORKLOAD WILL RUN 3 TIMES\n\n"
    runs="run1 run2 run3"
}

for run in $runs; do

    # Clean previous outputs
    printf "\n>>> CLEANING PREVIOUS OUTPUTS\n\n"
    
    ${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/batch/wordcount/wordcount-$a"GB"-results/hadoop-result


    # Prepare cluster for benchmark
    printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"
    
    $basedir/../../../benchmarks/prepare-for-benchmark.sh 0


    # Run workload
    start=$(date +%s)
    printf "\n>>> STARTING HADOOP WORDCOUNT: $(date -u) ($start)\n\n"
    
    # This causes buffer overflow for largerd data-sets
    #${HADOOP_HOME}/bin/hadoop jar $basedir/javaWordcount/hadoop-mapreduce-examples-*.jar  wordcount  /datasets/batch/wordcount/wordcount-$a"GB"  /outputs/batch/wordcount/wordcount-$a"GB"-results/hadoop-result
    
    # This fixes the buffer overflow for larger data-sets
    ${HADOOP_HOME}/bin/hadoop jar $basedir/javaWordcount/Wordcount.jar WordCount /datasets/batch/wordcount/wordcount-$a"GB"  /outputs/batch/wordcount/wordcount-$a"GB"-results/hadoop-result

    end=$(date +%s)
    printf "\n>>> ENDING HADOOP WORDCOUNT: $(date -u) ($end)\n\n"


    # Collect metrics
    printf "\n>>> DOWNLOADING METRICS - HADOOP CLUSTER\n\n"

    $basedir/../../../benchmarks/netdata-collect.sh $a 0 "batch/wordcount/wordcount-"$a"GB/hadoop-result/"$run"" $start $end


    # Verify results
    ssh deployer '~/implementation/workloads/batch/wordcount/verify-wordcount.sh '$a' '$run' "hadoop"'

done