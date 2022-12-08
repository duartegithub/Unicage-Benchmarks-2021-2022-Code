#!/bin/bash 

######################################
# CLEAN
######################################

# These hosts need clean environment
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CLEANING "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Reset ~/.ssh/known_hosts
        ssh $i 'rm ~/.ssh/known_hosts &> /dev/null'

        # Reset data 
        ssh $i 'rm -r ~/datav/hadoop &> /dev/null'
        ssh $i 'rm -r ~/datav/hive &> /dev/null'
	    # ssh $i 'umount ~/datav'
    
        # Uninstall Hadoop
        ssh $i 'rm -r /usr/local/hadoop &> /dev/null'

        # Uninstall Hive
        ssh $i 'rm -r /usr/local/hive &> /dev/null'

        # Uninstall Spark
        ssh $i 'rm -r /usr/local/spark &> /dev/null'

        # If host is namenode
        [ $i == namenode ] && {
            
            # Remove formatted_hdfs flag
            ssh $i 'rm ~/formatted_hdfs &> /dev/null'

        }

        # Uninstall data generators
        ssh $i 'rm -r ~/implementation/BigDataGenerationSuite &> /dev/null'

        continue
    } 

    echo "Could not reach "$i

done

}