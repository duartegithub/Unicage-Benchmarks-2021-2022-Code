create external table ecom_item_${hivevar:gbsize}GB(item_id int,order_id int,goods_id int,goods_number double,goods_price double,goods_amount double) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/datasets/query/query-${hivevar:gbsize}GB/item';
create external table ecom_order_${hivevar:gbsize}GB(order_id int,buyer_id int,create_date string) ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' STORED AS TEXTFILE LOCATION '/datasets/query/query-${hivevar:gbsize}GB/order';
create table item_temp_${hivevar:gbsize}GB as select ORDER_ID from ecom_item_${hivevar:gbsize}GB;

