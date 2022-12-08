name := "scalaWindowedWordcount"

version := "1.8.0"

scalaVersion := "2.12.15"

libraryDependencies += "org.apache.spark" %% "spark-core" % "3.2.0"

libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "3.3.1"

// https://mvnrepository.com/artifact/org.apache.spark/spark-sql
libraryDependencies += "org.apache.spark" %% "spark-sql" % "3.2.0" % "provided"

// https://mvnrepository.com/artifact/org.apache.spark/spark-streaming
libraryDependencies += "org.apache.spark" %% "spark-streaming" % "3.2.0" % "provided"


