# Batch processing: Wordcount

The benchmarked wordcount workload returns, for a wikipedia entry-based data-set, the number of occurrences of each word.

The materials for this experience can be found in [this folder](../workloads/batch/wordcount).

---
## Data generation:

The following script can be run in the deployer and invokes each producer to generate and load a fraction of the input data-sets into the Hadoop and Unicage clusters:

> ./genData-wordcount_cluster.sh < volume >

---
## Sample data-set:

The data-set used in this experiment is unstructured text data as sampled below:

>This area is areal area

---
## Sample output:

Based on the sample data-set, this workload should return:

>area 2\
>areal 1\
>is 1\
>This 1

---
## Cleaning up:

The following script can be run in the deployer to delete both input data-sets stored in the Hadoop and Unicage clusters and the outputs associated with said data-sets. This script does not delete benchmarking metric results:

> ./cleanData-wordcount_cluster.sh < volume >

---
## Verification:

Simply run the verify-wordcount.sh script:

> ./verify-wordcount.sh < volume >

This script returns the MD5 hashes of each output for visual confirmation.

---
## Benchmark Results:

The benchmark results can be consulted [here](../benchmarks/benchmark-results/benchmark-results.md).