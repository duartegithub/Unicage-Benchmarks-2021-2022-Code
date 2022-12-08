package bench.spark

import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

object WordCount {

  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      System.err.println("Usage: WordCount <data_file> <save_file>" +
        " [<slices>]")
      System.exit(1)
    }
    
    val conf = new SparkConf().setAppName("Spark WordCount")
    val spark = new SparkContext(conf)

    var splits = 2
    val filename = args(0)
    val save_file = args(1)
    if (args.length > 2) splits = args(2).toInt

    val lines = spark.textFile(filename, splits)
    val result = lines.flatMap(line => line.split(" "))
                      .map(word => (word, 1L))
                      .reduceByKey(_ + _)
    
    result.saveAsTextFile(save_file)
    println("Result has been saved to: " + save_file)
    
    spark.stop()
  }

}
