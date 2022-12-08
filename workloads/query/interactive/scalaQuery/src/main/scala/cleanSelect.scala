package bench.spark

import org.apache.spark.sql.Row
import org.apache.spark.sql.SparkSession

object cleanSelect {

  def main(args: Array[String]): Unit = {
    if (args.length != 1) {
      System.err.println("Usage: cleanSelect <dataset_size>")
      System.exit(1)
    }
    
    val spark = SparkSession.builder()
  			     .appName("Spark cleanSelect")
  			     .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
  			     .enableHiveSupport()
  			     .getOrCreate()
  			  
  			  
    import spark.implicits._
    import spark.sql

    val size = args(0)
    
    spark.sql(s"""drop table if exists select_${size}GB_spark""")

    spark.stop()
  }
}
