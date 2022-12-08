#!/bin/bash

# Running command: ./run-hive-workloads.sh <volume> <behcnmark-mode>
#   volume: the input data size, GB
#   benchmark-mode: write "benchmark-mode" to run this script in benchmark mode (repeat 3 times)

a=$1
basedir=$(dirname "$(readlink -f "$0")")

algorithm=(aggregation join select)
echo "Select workload"
echo "1. ${algorithm[0]} Workload"
echo "2. ${algorithm[1]} Workload"
echo "3. ${algorithm[2]} Workload"
read -p "> " choice

workload_type=${algorithm[$choice-1]}
directory=query/$workload_type/$workload_type-$a"GB"

runs="run1"

[ "$2" = "benchmark-mode" ] && {
    printf "\n>>> BENCHMARK-MODE: THE WORKLOAD WILL RUN 3 TIMES\n\n"
    runs="run1 run2 run3"
}

for run in $runs; do

  # clean previous outputs
  printf "\n>>> CLEANING PREVIOUS OUTPUTS\n\n"

  hive --hivevar gbsize=$a -f $basedir/SQLQuery/clean-e-commerce-$workload_type.sql


  # Prepare cluster for benchmark
  printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"

  $basedir/../../../benchmarks/prepare-for-benchmark.sh 0


  # Run workload
  start=$(date +%s)
  printf "\n>>> STARTING HIVE ${workload_type^^}: $(date -u) ($start)\n\n"

  if [ "x$workload_type" == "xaggregation" ]; then
    hive --hivevar gbsize=$a --hivevar save_file=/outputs/$directory-results/hive-result -f $basedir/SQLQuery/e-commerce-aggregation.sql

  elif [ "x$workload_type" == "xjoin" ]; then
    hive --hivevar gbsize=$a --hivevar save_file=/outputs/$directory-results/hive-result -f $basedir/SQLQuery/e-commerce-join.sql

  elif [ "x$workload_type" == "xselect" ]; then
    hive --hivevar gbsize=$a --hivevar save_file=/outputs/$directory-results/hive-result -f $basedir/SQLQuery/e-commerce-select.sql
  
  fi

  end=$(date +%s)
  printf "\n>>> ENDING HIVE ${workload_type^^}: $(date -u) ($end)\n\n"


  # Collect metrics
  printf "\n>>> DOWNLOADING METRICS - HADOOP CLUSTER\n\n"

  $basedir/../../../benchmarks/netdata-collect.sh $a 0 "$directory/hive-result/$run" $start $end


  # Verify results
  ssh deployer 'echo '$choice' | ~/implementation/workloads/query/interactive/verify-query.sh '$a' '$run' "hive"'

done