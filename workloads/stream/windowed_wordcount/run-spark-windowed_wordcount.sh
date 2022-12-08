#!/bin/bash
 
# Running command: ./run-spark-windowed_wordcount.sh < velocity >
#	velocity: the input rate of the data-set, MB/4s (roughly)

curdir=`pwd` 
a=$1

# run workload
echo "running spark streaming wordcount"
$SPARK_HOME/bin/spark-submit --class bench.spark.HDFSWindowedWordcount scalaWindowedWordcount/target/scala-2.12/scalawindowedwordcount_2.12-1.8.0.jar /datasets/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec" /outputs/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"/spark-results
echo "spark streaming wordcount ended"

