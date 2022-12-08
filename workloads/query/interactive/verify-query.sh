#!/bin/bash

# Running command: ./verify-query.sh <volume> <run> <system>
#	volume: the input data size, GB
#   run: the number of the benchmark run: run1, run2, run3
#   system: the benchmarked system: hive, spark, unicage

a=$1

algorithm=(aggregation join select)
echo "Select workload"
echo "1. ${algorithm[0]} Workload"
echo "2. ${algorithm[1]} Workload"
echo "3. ${algorithm[2]} Workload"
read -p "> " choice

workload_type=${algorithm[$choice-1]} 

hdfs_directory=/outputs/query/$workload_type/$workload_type-$a"GB"-results
unicage_directory=~/datav/outputs/query/$workload_type/$workload_type-$a"GB"-results
local_directory=~/datav/outputs/query/$workload_type/$workload_type-$a"GB"-results/$2
benchmark_directory=~/implementation/benchmarks/benchmark-results/query/$workload_type/$workload_type-$a"GB"
big_data_system=$3

mkdir -p $local_directory
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# If the Hive output exists
[ $big_data_system == hive ] && {
    printf "\n>>> PREPARING FOR VERIFICATION - HIVE OUTPUT\n\n"

    # Fetch output
    hadoop fs -getmerge $hdfs_directory/hive-result $local_directory/hive-result
    
    # Prepare for verification: remove '\001' characters from data-set, sort and even out decimal places
    cat $local_directory/hive-result | tr '\001' " " | sort -k1,1 | awk '{ printf "%.2f %.2f\n", $1, $2 }' > $local_directory/hive-result.tmp
    mv $local_directory/hive-result.tmp $local_directory/hive-result
    
    # Get hash
    md5sum $local_directory/hive-result > $local_directory/hive-hash
    cat $local_directory/hive-hash | awk '{print "Hive: "$1}' > $benchmark_directory/hive-result/$2/output_hash
    cat $benchmark_directory/hive-result/$2/output_hash
    
    # Clear local output
    rm $local_directory/hive-result

    # Copy benchmark results
    scp -r namenode:$benchmark_directory/hive-result/* $benchmark_directory/hive-result/

}

# If the Spark output exists
[ $big_data_system == spark ] && {
    printf "\n>>> PREPARING FOR VERIFICATION - SPARK OUTPUT\n\n"

    # Fetch output
    hadoop fs -getmerge $hdfs_directory/spark-result $local_directory/spark-result
    
    # Prepare for verification: remove '(', ')' characters from data-set and reorder columns to match Hadoop's
    cat $local_directory/spark-result | tr '\001' " " | sort -k1,1 | awk '{ printf "%.2f %.2f\n", $1, $2 }' > $local_directory/spark-result.tmp
    mv $local_directory/spark-result.tmp $local_directory/spark-result
    
    # Get hash
    md5sum $local_directory/spark-result > $local_directory/spark-hash
    cat $local_directory/spark-hash | awk '{print "Spark: "$1}' > $benchmark_directory/spark-result/$2/output_hash
    cat $benchmark_directory/spark-result/$2/output_hash
    
    # Clear local output
    rm $local_directory/spark-result
    
    # Copy benchmark results
    scp -r namenode:$benchmark_directory/spark-result/* $benchmark_directory/spark-result/

}

# If the Unicage output exists
[ $big_data_system == unicage ] && {
    printf "\n>>> PREPARING FOR VERIFICATION - UNICAGE OUTPUT\n\n"

    # Fetch output
    scp unicageleader:$unicage_directory/unicage-result/output $local_directory
    mv $local_directory/output $local_directory/unicage-result
    
    # Prepare for verification: swap columns in data-set
    sort -k1,1 $local_directory/unicage-result | awk '{ printf "%.2f %.2f\n", $1, $2 }' > $local_directory/unicage-result.tmp
    mv $local_directory/unicage-result.tmp $local_directory/unicage-result
    
    # Get hash
    md5sum $local_directory/unicage-result > $local_directory/unicage-hash
    cat $local_directory/unicage-hash | awk '{print "Unicage: "$1}' > $benchmark_directory/unicage-result/$2/output_hash
    cat $benchmark_directory/unicage-result/$2/output_hash
    
    # Clear local output
    rm $local_directory/unicage-result
    
    # Copy benchmark results
    scp -r unicageleader:$benchmark_directory/unicage-result/* $benchmark_directory/unicage-result/

}
