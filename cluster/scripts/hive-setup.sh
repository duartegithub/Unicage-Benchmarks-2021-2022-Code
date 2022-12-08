#!/bin/bash 

######################################
# HIVE
######################################

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# This host needs Hive
hostnames="namenode"

# Make tar folder if it doesn't exist
mkdir -p ~/tar/

# If Hive tar is not in system, download it
ls ~/tar/ | grep ^apache-hive &> /dev/null || wget https://dlcdn.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz -P ~/tar/

# If Hadoop is not installed, install Hadoop
ls /usr/local/hive &> /dev/null || {
    sudo tar -xvf ~/tar/apache-hive-3.1.2-bin.tar.gz -C /usr/local/
    sudo mv -T /usr/local/apache-hive-3.1.2-bin /usr/local/hive
}
sudo chmod 777 /usr/local/hive/
sudo chmod 777 /usr/local/hive/conf/

# Deploy local Hadoop configurations
basedir=$(dirname "$(readlink -f "$0")")
sudo cp $basedir/../configs/hive/* /usr/local/hive/conf/

# For each reachable host... (In this case, only the namenode)
for i in $hostnames; do

    printf "\n>>> CONFIGURING HIVE IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Set environmental variables
        ssh $i 'grep HIVE .bashrc &> /dev/null || cat >> .bashrc << '"'"'EOF'"'"'

# Hive Variables START
export HIVE_HOME=/usr/local/hive
export HIVE_CONF_DIR=$HIVE_HOME/conf
PATH=$PATH:$HIVE_HOME/bin:$HIVE_HOME/sbin
# Hive Variables END
EOF'

        # Deploy remote Hive configurations
        ssh $i 'ls /usr/local/hive/' &> /dev/null || scp -r /usr/local/hive $i:/usr/local/
        scp -r /usr/local/hive/conf/* $i:/usr/local/hive/conf/

        # Start Hive's metastore
        ssh $i 'export HADOOP_HOME=/usr/local/hadoop/; ls ~/datav/hive/conf/metastore_db &> /dev/null || /usr/local/hive/bin/schematool -initSchema -dbType derby &> /dev/null'

        continue
    } 
    
    echo "Could not reach "$i

done

}
