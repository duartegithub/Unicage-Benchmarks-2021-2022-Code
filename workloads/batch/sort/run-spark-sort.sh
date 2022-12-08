#!/bin/bash

# Running command: ./run-spark-sort.sh <volume> <behcnmark-mode>
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
    
    ${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/batch/sort/sort-$a"GB"-results/spark-result


    # Prepare cluster for benchmark
    printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"

    $basedir/../../../benchmarks/prepare-for-benchmark.sh 0


    # Run workload
    start=$(date +%s)
    printf "\n>>> STARTING SPARK SORT: $(date -u) ($start)\n\n"

    ${SPARK_HOME}/bin/spark-submit --class bench.spark.Sort $basedir/scalaSort/target/scala-2.12/scalasort_2.12-1.8.0.jar /datasets/batch/sort/sort-$a"GB" /outputs/batch/sort/sort-$a"GB"-results/spark-result

    end=$(date +%s)
    printf "\n>>> ENDING SPARK SORT: $(date -u) ($end)\n\n"


    # Collect metrics
    printf "\n>>> DOWNLOADING METRICS - HADOOP CLUSTER\n\n"

    $basedir/../../../benchmarks/netdata-collect.sh $a 0 "batch/sort/sort-"$a"GB/spark-result/"$run"" $start $end


    # Verify results
    ssh deployer '~/implementation/workloads/batch/sort/verify-sort.sh '$a' '$run' "spark"'

done