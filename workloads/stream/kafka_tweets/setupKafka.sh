#!/bin/bash

# Generating command: ./setup

echo "> STARTING ZOOKEEPER"
gnome-terminal -- $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties
sleep 20

echo "> STARTING KAFKA BROKER"
gnome-terminal -- $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
sleep 20

echo "> CREATING KAFKA TOPICS"
# the bootstrap-server, replication and partitions will need editing when migrating to a cluster.
$KAFKA_HOME/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic tweets
$KAFKA_HOME/bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic tweets-output
$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic tweets
$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic tweets-output

echo "> LISTING KAFKA TOPICS"
$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

echo "> STARTING KAFKA CONSOLE CONSUMER"
gnome-terminal -- $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic tweets-output --property print.key=true
