#!/bin/bash

# Generating command: ./genData-windowed_wordcount.sh <velocity> <variety>
#	velocity: the input rate of the data-set, MB/4s (roughly)
#	variety: the input variety, X means 10*X different files will be streamed in round-robin to HDFS
  
a=$1
b=$2

# generate input data
curdir=`pwd`

echo "DISCLAIMER: As it stands, due to the latency of HDFS, in our development setup, the selected rate corresponds to about data generated each 4 seconds. 100MB/4s is roughly our maximum rate, as HDFS latency is not great for small files, but tends to grow little with bigger files."

cd ../../../BigDataGeneratorSuite/Text_datagen/

rm -fr $curdir/datasets/windowd_wordcount-$a"MBpersec"
${HADOOP_HOME}/bin/hadoop fs -rm -r /datasets/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"
${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"
${HADOOP_HOME}/bin/hadoop fs -mkdir -p /datasets/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"

let L=10*$a
let V=10*$b
./gen_text_data.sh lda_wiki1w $V $L 15500 $curdir/datasets/windowed_wordcount-$a"MBpersec"

countrA=1
countrB=1

while true
do
	DATE_MARK=`date '+%Y-%m-%d-%H-%M-%S'`
	echo $DATE_MARK
	
	${HADOOP_HOME}/bin/hadoop fs -put $curdir/datasets/windowed_wordcount-$a"MBpersec"/lda_wiki1w_$countrA /datasets/stream/windowed_wordcount/windowed_wordcount-$a"MBpersec"/lda_wiki1w_$countrA"_"$countrB
	
	let countrA++
	if [ $countrA -ge $V ]
	then
		let countrA=1
		let countrB++
	fi
	sleep 1
done



