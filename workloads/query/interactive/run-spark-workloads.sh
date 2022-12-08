#!/bin/bash

# Running command: ./run-spark-workloads.sh <volume> <behcnmark-mode>
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

  # Clean previous outputs
  printf "\n>>> CLEANING PREVIOUS OUTPUTS\n\n"

  ${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/$directory-results/spark-result
  ${HADOOP_HOME}/bin/hadoop fs -mkdir -p /outputs/$directory-results/spark-result
  ${SPARK_HOME}/bin/spark-submit --class bench.spark.clean${workload_type^} $basedir/scalaQuery/target/scala-2.12/scalaquery_2.12-1.8.0.jar $a


  # Prepare cluster for benchmark
  printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"

  $basedir/../../../benchmarks/prepare-for-benchmark.sh 0


  # Run workload
  start=$(date +%s)
  printf "\n>>> STARTING SPARK ${workload_type^^}: $(date -u) ($start)\n\n"

  if [ "x$workload_type" == "xaggregation" ]; then
    ${SPARK_HOME}/bin/spark-submit --class bench.spark.Aggregation $basedir/scalaQuery/target/scala-2.12/scalaquery_2.12-1.8.0.jar /outputs/$directory-results/spark-result $a

  elif [ "x$workload_type" == "xjoin" ]; then
    ${SPARK_HOME}/bin/spark-submit --class bench.spark.Join $basedir/scalaQuery/target/scala-2.12/scalaquery_2.12-1.8.0.jar /outputs/$directory-results/spark-result $a

  elif [ "x$workload_type" == "xselect" ]; then
    ${SPARK_HOME}/bin/spark-submit --class bench.spark.Select $basedir/scalaQuery/target/scala-2.12/scalaquery_2.12-1.8.0.jar /outputs/$directory-results/spark-result $a
  
  fi

  end=$(date +%s)
  printf "\n>>> ENDING SPARK ${workload_type^^}: $(date -u) ($end)\n\n"


  # Collect metrics
  printf "\n>>> DOWNLOADING METRICS - HADOOP CLUSTER\n\n"

  $basedir/../../../benchmarks/netdata-collect.sh $a 0 "$directory/spark-result/$run" $start $end


  # Verify results
  ssh deployer 'echo '$choice' | ~/implementation/workloads/query/interactive/verify-query.sh '$a' '$run' "spark"'  

done