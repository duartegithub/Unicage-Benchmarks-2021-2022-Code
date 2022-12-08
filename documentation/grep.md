# Batch processing: Grep

The benchmarked grep workload differs from the standard UNIX grep. This workload returns, for a wikipedia entry-based data-set, the number of occurrences of words with the substring "area" as a part of them, for instance, words such as "area", "spareable" or "cesarean".

The materials for this experience can be found in [this folder](../workloads/batch/grep).

---
## Data generation:

The following script can be run in the deployer and invokes each producer to generate and load a fraction of the input data-sets into the Hadoop and Unicage clusters:

> ./genData-grep_cluster.sh < volume >

---
## Sample data-set:

The data-set used in this experiment is unstructured text data as sampled below:

>This area is areal area

---
## Sample output:

Based on the sample data-set, this workload should return:

>area 3

---
## Cleaning up:

The following script can be run in the deployer to delete both input data-sets stored in the Hadoop and Unicage clusters and the outputs associated with said data-sets. This script does not delete benchmarking metric results:

> ./cleanData-grep_cluster.sh < volume >

---
## Verification:

Simply run the verify-grep.sh script:

> ./verify-grep.sh < volume >

This script returns the MD5 hashes of each output for visual confirmation.


---
## Benchmark Results:

The benchmark results can be consulted [here](../benchmarks/benchmark-results/benchmark-results.md).
