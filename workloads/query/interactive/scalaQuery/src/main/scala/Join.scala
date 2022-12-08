package bench.spark

import org.apache.spark.sql.Row
import org.apache.spark.sql.SparkSession

object Join {

  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: Join <save_file> <dataset_size>")
      System.exit(1)
    }
    
    val spark = SparkSession.builder()
  			     .appName("Spark Join")
  			     .config("spark.sql.warehouse.dir", "/user/hive/warehouse")
  			     .enableHiveSupport()
  			     .getOrCreate()
  			  
  			  
    import spark.implicits._
    import spark.sql

    val save_file = args(0)
    val size = args(1)
    
    spark.sql(s"""create table join_${size}GB_spark location '${save_file}' as select ecom_order_${size}GB.buyer_id,  ecom_item_${size}GB.goods_amount from ecom_item_${size}GB join ecom_order_${size}GB on ecom_item_${size}GB.order_id = ecom_order_${size}GB.order_id""")

    spark.stop()
  }
}
