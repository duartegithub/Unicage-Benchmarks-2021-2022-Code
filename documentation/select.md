# Query processing: Select

The benchmarked select workload returns, for the e_commerce structured data-set, the goods_price and goods_amount, for goods whose goods_amount is bigger than 990000.

The materials for this experience can be found in [this folder](../workloads/query/interactive), addressed as the ./ directory through this document.

---
## Data generation:

The following script can be run in the deployer and invokes each producer to generate and load a fraction of the input data-sets into the Hadoop and Unicage clusters:

> ./genData-query_cluster.sh < volume >

---
## Sample data-set:

The data-set used in this experiment is structured e-com table data as sampled below:

> TABLE NAME: **ecom_item**\
> SCHEMA:
> > item_id (int)\
> > order_id (int)\
> > goods_id (int)\
> > goods_number (double)\
> > goods_price (double)\
> > goods_amount (double)

> SAMPLE (as is stored in HDFS):
> > 0|42594|3020|567|661.40|375117.12\
> > 1|11102|1276|601|275.27|165442.89\
> > 2|11101|3020|843|338.43|995618.31\
> > 3|11102|1267|423|923.01|991460.66

> TABLE NAME: **ecom_order**\
> SCHEMA:
> > order_id (int)\
> > buyer_id (int)\
> > create-date (string)

> SAMPLE (as is stored in HDFS):
> > 11100|33300|2007-04-24\
> > 11101|33301|2011-05-06\
> > 11102|33302|2011-06-15\
> > 11103|33303|2010-08-16

---
## Sample output:

Based on the sample data-set, this query should return:

> TABLE NAME: **select**\
> SCHEMA:
> > goods_price (double)\
> > goods_amount (double)

> SAMPLE (as is stored in HDFS):
> > 338.43|995618.31
> > 923.01|991460.66

---
## Cleaning up:

The following script can be run in the deployer to delete both input data-sets stored in the Hadoop and Unicage clusters and the outputs associated with said data-sets. This script does not delete benchmarking metric results:

> ./cleanData-query_cluster.sh < volume >

---
## Verification:

Simply run the verify-query.sh script:

> ./verify-query.sh < volume >

This script returns the MD5 hashes of each output for visual confirmation.


---
## Benchmark Results:

The benchmark results can be consulted [here](../benchmarks/benchmark-results/benchmark-results.md).
