#!/bin/bash

# Running command: ./run-unicage-workloads.sh <volume> <behcnmark-mode>
#   volume: the input data size, GB
#   benchmark-mode: write "benchmark-mode" to run this script in benchmark mode (repeat 3 times)

a=$1
basedir=$(dirname "$(readlink -f "$0")")
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"

algorithm=(aggregation join select)
echo "Select workload"
echo "1. ${algorithm[0]} Workload"
echo "2. ${algorithm[1]} Workload"
echo "3. ${algorithm[2]} Workload"
read -p "> " choice

workload_type=${algorithm[$choice-1]}
directory=query/query-$a"GB"
output_directory=query/$workload_type/$workload_type-$a"GB"

runs="run1"

[ "$2" = "benchmark-mode" ] && {
    printf "\n>>> BENCHMARK-MODE: THE WORKLOAD WILL RUN 3 TIMES\n\n"
    runs="run1 run2 run3"
}

for run in $runs; do

  # Clean previous outputs
  printf "\n>>> CLEANING PREVIOUS OUTPUTS\n\n"

  rm -r ~/datav/outputs/$output_directory-results/unicage-result

  for i in $unicageworkers; do

      ping -c 1 $i &> /dev/null && {

          ssh $i 'rm -r ~/datav/outputs/'$output_directory'-results/unicage-result'
          continue
      }

      echo "Could not reach "$i

  done


  # Prepare cluster for benchmark
  printf "\n>>> PREPARING FOR BENCHMARK - UNICAGE CLUSTER\n\n"

  $basedir/../../../benchmarks/prepare-for-benchmark.sh 1


  # Run workload
  start=$(date +%s)
  printf "\n>>> STARTING UNICAGE ${workload_type^^}: $(date -u) ($start)\n\n"

  if [ "x$workload_type" == "xaggregation" ]; then
    #$basedir/bashQuery/aggregation/tukubaiAggregation.sh $directory $output_directory "$unicageworkers"
    #$basedir/bashQuery/aggregation/boaAggregation/boaAggregation.sh $directory $output_directory "$unicageworkers"

    # BOA fix for 512+ GB input (some performance impact):
    $basedir/bashQuery/aggregation/boaAggregation/boaAggregationV3.sh $directory $output_directory "$unicageworkers"

  elif [ "x$workload_type" == "xjoin" ]; then
    $basedir/bashQuery/join/tukubaiJoin.sh $directory $output_directory "$unicageworkers" 

  elif [ "x$workload_type" == "xselect" ]; then
    #$basedir/bashQuery/select/tukubaiSelect_parallel_fifo.sh $directory $output_directory "$unicageworkers"
    $basedir/bashQuery/select/boaSelect/boaSelect.sh $directory $output_directory "$unicageworkers"

  fi

  end=$(date +%s)
  printf "\n>>> ENDING UNICAGE ${workload_type^^}: $(date -u) ($end)\n\n"


  # Collect metrics
  printf "\n>>> DOWNLOADING METRICS - UNICAGE CLUSTER\n\n"

  $basedir/../../../benchmarks/netdata-collect.sh $a 1 "$output_directory/unicage-result/$run" $start $end


  # Verify results
  ssh deployer 'echo '$choice' | ~/implementation/workloads/query/interactive/verify-query.sh '$a' '$run' "unicage"'

done