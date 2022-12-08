#!/bin/bash
 
# Running command: ./run-spark-kafka_tweets.sh 

curdir=`pwd` 
a=$1

workloads=("wordcount", "windowed hashtagcount")
sinks=("Kafka Consumer" "HDFS")

echo "Workload:"
echo "(1) Wordcount"
echo "(2) Windowed Hashtagcount"
while [ true ] ; do
  read -p "> " workload_type
  if [ $workload_type == 1 ] || [ $workload_type == 2 ]
  then
    break
  else
    echo "Invalid!"
  fi
done

echo "Sink:"
echo "(1) Kafka Consumer" 
echo "(2) HDFS"
while [ true ] ; do
  read -p "> " sink_type
  if [ $sink_type == 1 ] || [ $sink_type == 2 ]
  then
    break
  else
    echo "Invalid!"
  fi
done

# clean-up
if [ $workload_type == 1 ]
then
	${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/tweets_wordcount/spark-result
elif [ $workload_type == 2 ]
then
	${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/tweets_windowed_hashtagcount/spark-result
else
	echo "No workload..."
fi

# run workload
echo ">>> STARTING SPARK "${workloads[$workload_type-1]^^}" WITH "${sinks[$sink_type-1]^^} "AS OUT-SINK: "$(date -u)
if [ $workload_type == 1 ]
then
	if [ $sink_type == 1 ]
	then
	  $SPARK_HOME/bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 ./pythonTweets/tweets_wordcount_KafkaConsumer_sink.py /outputs/stream/tweets_wordcount/spark-result
	else 
	  $SPARK_HOME/bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 ./pythonTweets/tweets_wordcount_HDFS_sink.py /outputs/stream/tweets_wordcount/spark-result
	fi
elif [ $workload_type == 2 ]
then
	if [ $sink_type == 1 ]
	then
	  $SPARK_HOME/bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 ./pythonTweets/tweets_windowedHashtagcount_KafkaConsumer_sink.py /outputs/stream/tweets_windowed_hashtagcount/spark-result
	else 
	  $SPARK_HOME/bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.2.0 ./pythonTweets/tweets_windowedHashtagcount_HDFS_sink.py /outputs/stream/tweets_windowed_hashtagcount/spark-result
	fi
else
	echo "No workload..."
fi
echo ">>> ENDING SPARK "${workloads[$workload_type-1]^^}" WITH "${sinks[$sink_type-1]^^} "AS OUT-SINK: "$(date -u)




