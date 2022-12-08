# Unicage-Benchmarks

Repository for benchmarks with Unicage.
This contains scripts for data generation and implementations of workloads.

Documentation is available in [here](/documentation/documentation.md).

An automated deployment of a local testing environment is available in [this repository](https://github.com/duartegithub/vagrant-hadoop-cluster) (WIP).

---
## DISCLAIMERS & CREDITS:

### Data generators:
- The BigDataGenerationSuite used to generate data-sets for the benchmarks was forked from [this repository](https://github.com/BenchCouncil/BigDataBench_V5.0_BigData_MicroBenchmark/tree/main/BigDataGeneratorSuite), and slightly adjusted, as made available in [this folder](./BigDataGeneratorSuite/), together with the proper LICENSE.

### Benchmarking and Monitoring:
- All cluster monitoring and benchmarked resource usage metrics collection was achieved with [Netdata](https://www.netdata.cloud/). These make up +8GB, together with the logs of the benchmarks in [this separate repository](https://github.com/duartegithub/Unicage-Benchmarks-2021-2022-Results).

### Stream processing (Kafka and Twitter API):
- There are some stream processing implementations in [this folder](./workloads/stream/). Tweets are fetched with Kafka + Twitter API and fed into Spark to be processed with Spark Streaming and Spark Structured Streaming. These implementations were not tested nor benchmarked in a cluster environment, and are not a part of the benchmark - they were purely exploratory.

---
## Benchmark Progress:

The following table keeps track of what has been done:

**Legend:**
- ✓ - reliable output - output we are confident is correct, through verification
- ✓* - reliable but unvalidated output - reliable output with no statistical vality (single runs)
- ✓? - unreliable output - output that we have no way of verifying if it is correct
- ✗ - incorrect output - output we are confident is incorrect, through verification

<table class="tg">
<thead>
  <tr>
    <th class="tg-c3ow"></th>
    <th class="tg-c3ow"></th>
    <th class="tg-c3ow" colspan="8">Size</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td class="tg-abip">Operation</td>
    <td class="tg-abip">System</td>
    <td class="tg-abip">64</td>
    <td class="tg-abip">128</td>
    <td class="tg-abip">256</td>
    <td class="tg-abip">512</td>
    <td class="tg-abip">1024</td>
    <td class="tg-abip">2048</td>
    <td class="tg-abip">4096</td>
    <td class="tg-abip">8192</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Grep</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
  </tr>
  <tr>
    <td class="tg-abip">Hadoop</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Sort</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
  </tr>
  <tr>
    <td class="tg-abip">Hadoop</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓*</td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
    <td class="tg-c3ow"></td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✗</td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Wordcount</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
  </tr>
  <tr>
    <td class="tg-abip">Hadoop</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓*</td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✗</td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Select</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
  </tr>
  <tr>
    <td class="tg-abip">Hive</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Join</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
  </tr>
  <tr>
    <td class="tg-abip">Hive</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✗</td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
    <td class="tg-abip"></td>
  </tr>
  <tr>
    <td class="tg-c3ow" rowspan="4">Aggregation</td>
    <td class="tg-c3ow">Generation &amp;<br>Loading</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
    <td class="tg-c3ow">Done</td>
  </tr>
  <tr>
    <td class="tg-abip">Hive</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✗</td>
  </tr>
  <tr>
    <td class="tg-c3ow">Spark</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
    <td class="tg-c3ow">✓</td>
  </tr>
  <tr>
    <td class="tg-abip">Unicage</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
    <td class="tg-abip">✓</td>
  </tr>
</tbody>
</table>

The complete benchmark results can be found [here](https://github.com/duartegithub/Unicage-Benchmarks-2021-2022-Results).


---
## Known Bugs & TODOs:

- The **select** Unicage workload aggregates results in leader node with no need, adding time to the workload. This aggregation should be moved to the verification script.

- The data generators for **aggregation** and **select** should be adjusted to generate a single table with the desired volume, as opposed to two tables, with one of them not being used by the workloads.

---
## Links & References:

BigDataBench 5.0:
<br> https://github.com/BenchCouncil/BigDataBench_V5.0_BigData_MicroBenchmark
<br> https://github.com/yangqiang/BigDataBench-Spark
<br> https://github.com/BenchCouncil/BigDataBench_V5.0_Streaming

HiBench:
<br> https://github.com/Intel-bigdata/HiBench

Install Hadoop 3.3.1 (pseudo-distributed):
<br> ~~https://klasserom.azurewebsites.net/Lessons/Binder/2410#CourseStrand_3988~~
<br> https://www.youtube.com/watch?v=QDpA3A0MXJY&t=156s&ab_channel=ChrisDyck (and Part 2)

Install Hive 3.1.2 (pseudo-distributed):
<br> https://hadooptutorials.info/2020/10/11/part-3-install-hive-on-hadoop/

Install Spark 3.2.0 (pseudo-distributed):
<br> https://msris108.medium.com/how-to-setup-a-pseudo-distributed-cluster-with-hadoop-3-2-1-and-apache-spark-3-0-34406a85130f

Streaming examples in Spark Streaming:
<br> https://spark.apache.org/docs/latest/streaming-programming-guide.html
<br> https://github.com/apache/spark/tree/master/examples/src/main/scala/org/apache/spark/examples/streaming
<br> https://jhui.github.io/2017/01/15/Apache-Spark-Streaming/

Kafka Streams wordcount example:
<br> https://kafka.apache.org/documentation.html#quickstart

Kafka generic non-JVM producer/consumer (may be useful for stream processing in Unicage BOA!)
<br> https://github.com/edenhill/kcat 

Kafka + TwitterAPI + Spark Streaming + Hive example:
<br> https://github.com/dbusteed/kafka-spark-streaming-example
<br> https://www.youtube.com/watch?v=9D7-BZnPiTY
<br> **WARNING**: This example uses Spark Streaming from Spark 2.4.0. Kafka no longer integrates with Spark Streaming, as of v2.4, instead it integrates with Spark Structured Streaming. [How to integrate Kafka with Structured Streaming in Spark 3.2.0.](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)
