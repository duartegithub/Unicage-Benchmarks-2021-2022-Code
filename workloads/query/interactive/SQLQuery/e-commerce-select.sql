create table select_${hivevar:gbsize}GB location '${hivevar:save_file}' as select GOODS_PRICE,GOODS_AMOUNT from ecom_item_${hivevar:gbsize}GB where GOODS_AMOUNT > 990000 ;
