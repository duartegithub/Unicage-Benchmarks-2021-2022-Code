package bench.spark

//import org.apache.log4j.Logger
import org.apache.spark._
import org.apache.spark.streaming._
import org.apache.spark.streaming.StreamingContext._
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions._

object HDFSWindowedWordcount extends Serializable {
//	@transient lazy val logger: logger = Logger.getLogger(getClass.getName)

	def main(args: Array[String]): Unit = {
	
		val input_file=args(0)
		val save_file=args(1)
		var r = 0
	
		val conf = new SparkConf().setMaster("local[2]").setAppName("Spark WindowedWordcount")
		val ssc = new StreamingContext(conf, Seconds(5))
			  
		// None of this will be executed until the StreamingContext is started	  
		val linesDF = ssc.textFileStream(input_file)
		val resultDS = linesDF.flatMap(_.split(" "))
		                   .map(word => (word, 1))
		                   .reduceByKey(_ + _)
			
		// for each 5 second micro-batch, store wordcount in HDFS
		resultDS.foreachRDD(rdd => {
    			if(!rdd.isEmpty) {
    				r += 1
     				rdd.saveAsTextFile(save_file + "/" + r)
    			}
		})
		
		ssc.start()
		ssc.awaitTermination()
	}
}
