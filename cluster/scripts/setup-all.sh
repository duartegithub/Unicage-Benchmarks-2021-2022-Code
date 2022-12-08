#!/bin/bash 

######################################
# RUN ALL CONFIGURATIONS
######################################

basedir=$(dirname "$(readlink -f "$0")")

$basedir/ssh-setup.sh
# $basedir/infra-setup.sh # WARNING! Make sure the volumes in each node are /dev/vdc, otherwise this will not work, and may break the cluster. To do this more securely, do it manually.
$basedir/utils-setup.sh
$basedir/hadoop-setup.sh
$basedir/hive-setup.sh
$basedir/spark-setup.sh
$basedir/bdgs-setup.sh
$basedir/netstat-setup.sh