#!/bin/bash 

######################################
# HADOOP
######################################

# These hosts need Hadoop
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# Make tar folder if it doesn't exist
mkdir -p ~/tar/

# If Hadoop tar is not in system, download it
ls ~/tar/ | grep hadoop &> /dev/null || wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz -P ~/tar/

# If Hadoop is not installed, install Hadoop
ls /usr/local/hadoop &> /dev/null || {
    sudo tar -xvf ~/hadoop-3.3.1.tar.gz -C /usr/local/
    sudo mv -T /usr/local/hadoop-3.3.1/ /usr/local/hadoop
}
sudo chmod 777 /usr/local/hadoop/

# Deploy local Hadoop configurations
basedir=$(dirname "$(readlink -f "$0")")
sudo cp $basedir/../configs/hadoop/* /usr/local/hadoop/etc/hadoop/

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING HADOOP IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Disable iptables
        # ssh $i 'sudo ufw disable'

        # If pdsh is not installed, install pdsh
        # ssh $i 'pdsh -V &> /dev/null || {
        #     sudo apt-get -y update
        #     sudo apt-get -y install pdsh
        # }'

        # Set environmental variables
        ssh $i 'grep HADOOP .bashrc &> /dev/null || cat >> .bashrc << '"'"'EOF'"'"'

# PDSH Variables START
export PDSH_RCMD_TYPE=ssh
# PDSH Variables END

# HADOOP Variables START
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export YARN_EXAMPLES=$HADOOP_HOME/share/hadoop/mapreduce
export HDFS_NAMENODE_USER="root"
export HDFS_DATANODE_USER="root"
export HDFS_SECONDARYNAMENODE_USER="root"
export YARN_RESOURCEMANAGER_USER="root"
export YARN_NODEMANAGER_USER="root"
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
# HADOOP Variables END
EOF'

        # Deploy remote Hadoop configurations
        ssh $i 'ls /usr/local/hadoop/' &> /dev/null || scp -r /usr/local/hadoop $i:/usr/local/
        scp -r /usr/local/hadoop/etc/hadoop/* $i:/usr/local/hadoop/etc/hadoop/

        # If host is namenode...
        [ $i == namenode ] && {

            # Format HDFS
            ssh $i 'cat formatted_hdfs &> /dev/null || {
                echo "Y" | /usr/local/hadoop/bin/hdfs namenode -format &> /dev/null
                touch formatted_hdfs
                chmod 444 formatted_hdfs
            }'

        } || echo "This is not a namenode"

        continue
    } 
    
    echo "Could not reach "$i

done

}