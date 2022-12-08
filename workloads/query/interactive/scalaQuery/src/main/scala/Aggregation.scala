package bench.spark

import org.apache.spark.sql.Row
import org.apache.spark.sql.SparkSession

object Aggregation {

  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: Aggregation <save_file> <dataset_size>")
      System.exit(1)
    }
    
    val spark = SparkSession.builder()
  			     .appName("Spark Aggregation")
  			     .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
  			     .enableHiveSupport()
  			     .getOrCreate()
  			  
  			  
    import spark.implicits._
    import spark.sql

    val save_file = args(0)
    val size = args(1)
    
    spark.sql(s"""create table aggregation_${size}GB_spark location '${save_file}' as select GOODS_ID, sum(GOODS_NUMBER) from ecom_item_${size}GB group by GOODS_ID""")

    spark.stop()
  }
}
