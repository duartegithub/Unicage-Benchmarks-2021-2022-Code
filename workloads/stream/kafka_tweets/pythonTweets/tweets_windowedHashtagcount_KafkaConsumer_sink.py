#!/usr/bin/python3                                                                                                      

import findspark
findspark.init()
                                                                                                                        
from pyspark import SparkContext                                                                                        
from pyspark.sql import SparkSession                                                                                    
from pyspark.streaming import StreamingContext 
from pyspark.sql.functions import *
import argparse

# setting <HDFSoutput>
parser = argparse.ArgumentParser()
parser.add_argument("HDFSoutput", type=str)
args = parser.parse_args()
save_file = args.HDFSoutput 

ss = SparkSession.builder.appName("Spark Kafka TweetsWindowedHashtagcount").getOrCreate()                                            
ss.sparkContext.setLogLevel('WARN')

# read stream produced to kafka's topic 'tweets' (the 'kafka.bootstrap.servers' property needs to be adjusted to support Kafka cluster)
kafka_df = ss.readStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("subscribe", "tweets").option("startingOffsets", "earliest").load()

# from each tweet, extract the 'value' as a STRING (this is the text of the tweet), and name that column 'tweet', and include a timestamp for the aggregations
kafka_df_string = kafka_df.selectExpr("CAST(value AS STRING) AS tweet", "CAST(timestamp AS timestamp)")

# from each 'tweet' (text of tweet), generate one row for each word, separated by the ' ' character
words = kafka_df_string.withColumn('key', explode(split(col('tweet'), ' ')))

# filter 'key' (the individual words) and get only #hashtags, and count the number of times each #hashtag appeared in 5 second windows. 
count = words.select(col("*")).filter(col('key').contains('#')).withWatermark("timestamp", "5 seconds").groupBy(window('timestamp', "5 seconds", "5 seconds"),'key').count()

# rename 'count' column to 'value', to be printed in the Kafka Consumer
table = count.withColumnRenamed ('count', 'value')

# for debugging, print the schema of the result table (it must have a 'key' and a 'value' columns, to be well printed by Kafka's consumer)
table.printSchema()

# write stream to console, for debugging
# query = table.writeStream.format("console").start()

# write stream to kafka's consumer on topic 'tweets-output'
query = table.selectExpr("CAST(value AS STRING)", "CAST(key AS STRING)").repartition(1, col("window")).writeStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("topic", "tweets-output").option("checkpointLocation", save_file + "/checkpoints/KafkaConsumersink").start()

query.awaitTermination()                                                                                     
                                                                                                                       
