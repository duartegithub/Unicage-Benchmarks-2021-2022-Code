# Batch processing: Sort

The benchmarked sort workload returns, for a one-word-per-line data-set, the sorted data-set.

The materials for this experience can be found in [this folder](../workloads/batch/sort). An alternative terasort implementaion is described [here](terasort.md). 

---
## Data generation:

The following script can be run in the deployer and invokes each producer to generate and load a fraction of the input data-sets into the Hadoop and Unicage clusters:

> ./genData-sort_cluster.sh < volume >

---
## Sample data-set:

The data-set used in this experiment is semi-structured text data, in the form of words delimited by the "\n" character, as sampled below:

>This\
>area\
>is\
>areal\
>area

---
## Sample output:

Based on the sample data-set, this workload should return:

>area\
>area\
>areal\
>is\
>This

---
## Cleaning up:

The following script can be run in the deployer to delete both input data-sets stored in the Hadoop and Unicage clusters and the outputs associated with said data-sets. This script does not delete benchmarking metric results:

> ./cleanData-sort_cluster.sh < volume >

---
## Verification:

Simply run the verify-sort.sh script:

> ./verify-sort.sh < volume >

This script returns the MD5 hashes of each output for visual confirmation.


---
## Benchmark Results:

The benchmark results can be consulted [here](../benchmarks/benchmark-results/benchmark-results.md).
