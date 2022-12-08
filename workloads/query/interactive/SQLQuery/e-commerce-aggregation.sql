create table aggregation_${hivevar:gbsize}GB location '${hivevar:save_file}' as select GOODS_ID, sum(GOODS_NUMBER) from ecom_item_${hivevar:gbsize}GB group by GOODS_ID;
