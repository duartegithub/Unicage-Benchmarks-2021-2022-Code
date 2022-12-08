#!/bin/bash

# Generating command: ./cleanData-kafka_tweets.sh

# clean input and output data
curdir=`pwd`
${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/tweets_wordcount
${HADOOP_HOME}/bin/hadoop fs -rm -r /outputs/stream/tweets_windowed_hashtagcount
