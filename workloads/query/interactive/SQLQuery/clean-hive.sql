drop table if exists ecom_item_${hivevar:gbsize}GB;
drop table if exists ecom_order_${hivevar:gbsize}GB;
drop table if exists item_temp_${hivevar:gbsize}GB;
drop table if exists aggregation_${hivevar:gbsize}GB;
drop table if exists aggregation_${hivevar:gbsize}GB_spark;
drop table if exists join_${hivevar:gbsize}GB;
drop table if exists join_${hivevar:gbsize}GB_spark;
drop table if exists select_${hivevar:gbsize}GB;
drop table if exists select_${hivevar:gbsize}GB_spark;
