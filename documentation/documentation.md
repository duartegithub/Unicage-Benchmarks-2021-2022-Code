# Benchmarking Documentation

---
## Requirements:

This benchmark suite aims to compare complex big data systems and lean big data systems. The considered systems are:
- Hadoop 3.3.1
- Hive 3.1.2
- Spark 3.2.0
- Unicage Tukubai and BOA

---
## Experiments:

The experiments are listed as follows:

---
### ***Batch processing***

Batch processing translates to offline processing of a bounded data-set with limited size fully available at the time of processing. The following workloads were considered for this modality:

- [grep](grep.md)
- [sort](sort.md)
- [wordcount](wordcount.md)

---
### ***Query processing***

Query processing translates to batch processing with a structured data-set stored in a database. The following workloads were considered for this modality:

- [select](select.md)
- [join](join.md)
- [aggregation](aggregation.md)

## Infrastructure:

Documentation regarding the planned cluster architecture can be consulted [here](cluster_architecture.md).

---
## Conclusions:

The benchmark results can be consulted [here](../benchmarks/benchmark-results/benchmark-results.md).