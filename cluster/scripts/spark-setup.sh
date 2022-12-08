#!/bin/bash 

######################################
# SPARK
######################################

# These hosts need Hadoop
hostnames="namenode"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# Make tar folder if it doesn't exist
mkdir -p ~/tar/

# If Spark tar is not in system, download it
ls ~/tar/ | grep ^spark &> /dev/null || wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz -P ~/tar/

# If Spark is not installed, install Spark
ls /usr/local/spark &> /dev/null || {
    sudo tar -xvf ~/tar/spark-3.2.1-bin-hadoop3.2.tgz -C /usr/local/
    sudo mv -T /usr/local/spark-3.2.1-bin-hadoop3.2 /usr/local/spark
}
sudo chmod 777 /usr/local/spark/

# Deploy local Spark configurations
basedir=$(dirname "$(readlink -f "$0")")
sudo cp $basedir/../configs/spark/* /usr/local/spark/conf

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING SPARK IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Set environmental variables
        ssh $i 'grep SPARK .bashrc &> /dev/null || cat >> .bashrc << '"'"'EOF'"'"'

# Spark Variables START
export SPARK_HOME=/usr/local/spark
export SPARK_CONF_DIR=$SPARK_HOME/conf
PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=python3
# Spark Variables END
EOF'

        # Deploy remote Spark configurations
        ssh $i 'ls /usr/local/spark/' &> /dev/null || scp -r /usr/local/spark $i:/usr/local/
        scp -r /usr/local/spark/conf/* $i:/usr/local/spark/conf/

        # If PySpark is not installed, install PySpark
        ssh $i 'pip3 list | grep spark &> /dev/null || {
            echo "i" | pip3 install pyspark
        }'

        continue
    } 
    
    echo "Could not reach "$i

done

}

