#!/bin/bash

# Running command: ./verify-grep.sh <volume> <run> <system>
#	volume: the input data size, GB
#   run: the number of the benchmark run: run1, run2, run3
#   system: the benchmarked system: hadoop, spark, unicage

a=$1
hdfs_directory=/outputs/batch/grep/grep-$a"GB"-results
unicage_directory=~/datav/outputs/batch/grep/grep-$a"GB"-results
local_directory=~/datav/outputs/batch/grep/grep-$a"GB"-results/$2
benchmark_directory=~/implementation/benchmarks/benchmark-results/batch/grep/grep-$a"GB"
big_data_system=$3

mkdir -p $local_directory
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# If the Hadoop output exists
[ $big_data_system == hadoop ] && {
    printf "\n>>> PREPARING FOR VERIFICATION - HADOOP OUTPUT\n\n"

    # Fetch output
    hadoop fs -getmerge $hdfs_directory/hadoop-result $local_directory/hadoop-result
    
    # Prepare for verification: remove '\t' characters from data-set
    sed -i s/'\t'/' '/g $local_directory/hadoop-result
    
    # Get hash
    md5sum $local_directory/hadoop-result > $local_directory/hadoop-hash
    cat $local_directory/hadoop-hash | awk '{print "Hadoop: "$1}' > $benchmark_directory/hadoop-result/$2/output_hash
    cat $benchmark_directory/hadoop-result/$2/output_hash
    
    # Clear local output
    rm $local_directory/hadoop-result

    # Copy benchmark results
    scp -r namenode:$benchmark_directory/hadoop-result/* $benchmark_directory/hadoop-result/

}

# If the Spark output exists
[ $big_data_system == spark ] && {
    printf "\n>>> PREPARING FOR VERIFICATION - SPARK OUTPUT\n\n"

    # Fetch output
    hadoop fs -getmerge $hdfs_directory/spark-result $local_directory/spark-result
    
    # Prepare for verification: remove '(', ')' characters from data-set and reorder columns to match Hadoop's
    cat $local_directory/spark-result | sed 's/[()]//g' | sed 's/,/ /g' | awk '{print $2" "$1}' > $local_directory/spark-result.tmp
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
    cat $local_directory/unicage-result | awk '{print $2" "$1}' > $local_directory/unicage-result.tmp
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
