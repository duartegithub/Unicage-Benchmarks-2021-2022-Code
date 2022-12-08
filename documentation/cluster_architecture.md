# Cluster Architecture (preliminary)

This cluster is achieved through the VPC Infrastructure of IBM Cloud. The benchmarking cluster is comprised of 17 nodes across three sub-clusters:

[**Hadoop cluster**](#hadoop-cluster):
 - Deployemnt of Hadoop/Hive/Spark
 - 6 nodes: 1 leader + 5 workers

[**Unicage cluster**](#unicage-cluster):
 - Deployment of Unicage BOA 
 - 6 nodes: 1 leader + 5 workers

[**Producer cluster**](#producer-cluster):
 - Deployment of data-set generators 
 - 4 nodes

The deployment is coordinated from the [deployment-driver-node](#deployment-driver-node).

The Hadoop and Unicage clusters are virtually identical in terms of OS, CPU, RAM, Disks and Location (London, as it's closer to Portugal). Hostnames and private IPs can and should be different. All 17 nodes may reside within the same VPC subnet and share ssh keys, to ease communication. 

---
## Hadoop cluster

This cluster is responsible for hosting the ecosystem of Hadoop, and will be used to house data-sets in HDFS and to run workloads on Hadoop 3.3.1, Hive 3.1.2 and Spark 3.2.0. It is comprised of the following nodes:

**namenode** (leader):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM -> to host namenode and YARN)
 - attached storage disks: 1024 GB, 3 IOPS (for tmp data), mounted on ~/datav
 - hostname: namenode

**datanode1** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for HDFS), mounted on ~/datav
 - hostname: datanode1

**datanode2** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for HDFS), mounted on ~/datav
 - hostname: datanode2

**datanode3** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for HDFS), mounted on ~/datav
 - hostname: datanode3

**datanode4** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for HDFS), mounted on ~/datav
 - hostname: datanode4

**datanode5** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for HDFS), mounted on ~/datav
 - hostname: datanode5

---
## Unicage cluster

This cluster is responsible for hosting Unicage BOA, and will be used to house data-sets in Bubun File System, and run BOA workloads. It is comprised of the following nodes:

**unicageleader** (leader):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM)
 - attached storage disks: 1024 GB, 3 IOPS (for tmp data), mounted on ~/datav
 - hostname: unicageleader

**unicageworker1** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for Bubun), mounted on ~/datav
 - hostname: unicageworker1

**unicageworker2** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for Bubun), mounted on ~/datav
 - hostname: unicageworker2

**unicageworker3** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for Bubun), mounted on ~/datav
 - hostname: unicageworker3

**unicageworker4** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for Bubun), mounted on ~/datav
 - hostname: unicageworker4

**unicageworker5** (worker):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-4x16 (4 cores, 16GB of RAM)
 - attached storage disks: 4096 GB, 3 IOPS (for Bubun), mounted on ~/datav
 - hostname: unicageworker5

---
## Producer cluster

This cluster is responsile for the generation of data-sets, and it will feed both the Hadoop and the Unicage clusters with identical data-sets. Despite not being datanodes, the nodes in this cluster have Hadoop configured, in order to feed the Hadoop cluster, by loading it into HDFS with `hadoop fs -put`. This cluster is comprised of the following nodes:

**producer1** (data generator):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM -> data generation must be FAST)
 - attached storage disks: 4096 GB, 3 IOPS (for local storage of generated data, before data loading), mounted on ~/datav
 - hostname: producer1

**producer2** (data generator):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM -> data generation must be FAST)
 - attached storage disks: 4096 GB, 3 IOPS (for local storage of generated data, before data loading), mounted on ~/datav
 - hostname: producer2

**producer3** (data generator):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM -> data generation must be FAST)
 - attached storage disks: 4096 GB, 3 IOPS (for local storage of generated data, before data loading), mounted on ~/datav
 - hostname: producer3

**producer4** (data generator):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: bx2d-8x32 (8 cores, 32GB of RAM -> data generation must be FAST)
 - attached storage disks: 4096 GB, 3 IOPS (for local storage of generated data, before data loading), mounted on ~/datav
 - hostname: producer4

---
## Deployment-driver-node

This node is responsible for driving the automated deployment of the tools in the corresponding sub-clusters and serves as a single point of management for the whole benchmarking cluster.

**deployer** (automated deployment):
 - location: LONDON
 - type: PUBLIC
 - architecture: x86
 - OS: Ubuntu 20.04
 - profile: cx2d-2x4 (2 cores, 4GB of RAM)
 - attached storage disks: 16000 GB, mounted on ~/datav (for data verification)
 - hostname: deployer
