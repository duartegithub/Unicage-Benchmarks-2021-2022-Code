// adapted from: https://github.com/phatak-dev/spark2.0-examples/blob/master/src/main/scala/com/madhukaraphatak/examples/sparktwo/streaming/IngestionTimeWindow.scala

package bench.spark

import java.sql.Timestamp

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._
import org.apache.spark.sql.streaming.OutputMode
import org.apache.spark.sql.streaming.Trigger

object NetworkWindowedWordcount {

  def main(args: Array[String]): Unit = {
  
    val input_file = args(0)
    val save_file = args(1)
  
    val sparkSession = SparkSession.builder
      .master("local")
      .appName("Spark WindowedWordcount")
      .getOrCreate()
      
    //create stream from socket
    sparkSession.sparkContext.setLogLevel("ERROR")
    val socketStreamDf = sparkSession.readStream
      .format("socket")
      .option("host", "localhost")
      .option("port", 9999)
      .option("includeTimestamp", true)
      .load()
      
    import sparkSession.implicits._
    val socketDs = socketStreamDf.as[(String, Timestamp)]
    val wordsDs = socketDs
      .flatMap(line => line._1.split(" ").map(word => {
        (word, line._2)
      }))
      .toDF("word", "timestamp")

    val windowedCount = wordsDs
      .withWatermark("timestamp", "5 seconds")
      .groupBy(window($"timestamp", "5 seconds", "5 seconds"),$"word")
      .count()

    val query = windowedCount
    	.repartition(1, col("window")) //avoid creation of a lot of small files (https://stackoverflow.com/questions/42360497/spark-structured-streaming-writing-to-parquet-creates-so-many-files).
    	.writeStream
    	.format("json")        
    	.option("path", save_file)
    	.option("truncate","false")
	.option("checkpointLocation", savefile + "/checkpoints")
    	.outputMode(OutputMode.Append())
    	.start()

    query.awaitTermination()
  }
}
