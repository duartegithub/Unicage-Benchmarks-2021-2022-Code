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

ss = SparkSession.builder.appName("Spark Kafka TweetsWordcount").getOrCreate()                                            
ss.sparkContext.setLogLevel('WARN')

# read stream produced to kafka's topic 'tweets' (the 'kafka.bootstrap.servers' property needs to be adjusted to support Kafka cluster)
kafka_df = ss.readStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("subscribe", "tweets").option("startingOffsets", "earliest").load()

# from each tweet, extract the 'value' as a STRING (this is the text of the tweet), and name that column 'key'
kafka_df_string = kafka_df.selectExpr("CAST(value AS STRING) AS key")

# from each 'key' (text of tweet), count the number of words (the -1 is there to ignore a space that is generated at the end of each tweet)
table = kafka_df_string.withColumn('value', size(split(col('key'), ' ')) - 1)

# for debugging, print the schema of the result table (it must have a 'key' and a 'value' columns, to be well printed by Kafka's consumer)
table.printSchema()

# write stream to console, for debugging
# query = table.writeStream.format("console").start()

# write stream to HDFS
query = table.selectExpr("CAST(value AS STRING)", "CAST(key AS STRING)").writeStream.format("json").option("path", save_file).option("truncate","false").outputMode("append").option("checkpointLocation", save_file + "/checkpoints/HDFSsink").start()

query.awaitTermination()                                                                                     
                                                                                                                       
