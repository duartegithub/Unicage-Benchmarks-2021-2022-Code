name := "scalaSort"

version := "1.8.0"

scalaVersion := "2.12.15"

// https://mvnrepository.com/artifact/org.apache.spark/spark-core
libraryDependencies += "org.apache.spark" %% "spark-core" % "3.2.0"

// https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-mapreduce-examples
libraryDependencies += "org.apache.hadoop" % "hadoop-mapreduce-examples" % "3.3.1"

// https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-common
libraryDependencies += "org.apache.hadoop" % "hadoop-common" % "3.3.1"

// https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-client
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "3.3.1"
