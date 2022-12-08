#!/bin/bash

# Running command: ./run-hadoop-grep.sh <volume> <behcnmark-mode>
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

${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/batch/grep/grep-$a"GB"-results/hadoop-result


# Prepare cluster for benchmark
printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"

$basedir/../../../benchmarks/prepare-for-benchmark.sh 0


# Run workload
start=$(date +%s)
printf "\n>>> STARTING HADOOP GREP: $(date -u) ($start)\n\n"

${HADOOP_HOME}/bin/hadoop jar $basedir/javaGrep/hadoop-mapreduce-examples-*.jar grep  /datasets/batch/grep/grep-$a"GB"  /outputs/batch/grep/grep-$a"GB"-results/hadoop-result area

end=$(date +%s)
printf "\n>>> ENDING HADOOP GREP: $(date -u) ($end)\n\n"


# Collect metrics
printf "\n>>> DOWNLOADING METRICS - HADOOP CLUSTER\n\n"

$basedir/../../../benchmarks/netdata-collect.sh $a 0 "batch/grep/grep-"$a"GB/hadoop-result/"$run"" $start $end


# Verify results
ssh deployer '~/implementation/workloads/batch/grep/verify-grep.sh '$a' '$run' "hadoop"'

done
