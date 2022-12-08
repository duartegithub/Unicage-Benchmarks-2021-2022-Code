package bench.spark

import org.apache.spark.sql.Row
import org.apache.spark.sql.SparkSession

object cleanJoin {

  def main(args: Array[String]): Unit = {
    if (args.length != 1) {
      System.err.println("Usage: cleanJoin <dataset_size>")
      System.exit(1)
    }
    
    val spark = SparkSession.builder()
  			     .appName("Spark cleanJoin")
  			     .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
  			     .enableHiveSupport()
  			     .getOrCreate()
  			  
  			  
    import spark.implicits._
    import spark.sql

    val size = args(0)
    
    spark.sql(s"""drop table if exists join_${size}GB_spark""")

    spark.stop()
  }
}
