#!/bin/bash

# Generating command: ./cleanData-windowed_wordcount.sh <velocity>
#	velocity: the input rate of the data-set, MB/4s (roughly)
  
a=$1

# clean input and output data
curdir=`pwd`
rm -fr $curdir/datasets/windowed_wordcount-$a"MBpersec"
${HADOOP_HOME}/bin/hadoop fs -rm -r /datasets/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"
${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"
