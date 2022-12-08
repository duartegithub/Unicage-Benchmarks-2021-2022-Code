#!/bin/bash 

######################################
# CLUSTER SPECIFICATIONS
######################################

# These hosts will be described
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> FETCHING "$i" SPECS\n"

    ping -c 1 $i &> /dev/null && {

        # Get OS and kernel info
        printf "\n$i - OS INFO: \n"
        ssh $i 'lsb_release -d'
        printf "Kernel:         "
        ssh $i 'uname -r'

        # Get CPU info
        printf "\n$i - CPU INFO: \n"
        ssh $i 'lscpu | head -n 25'
        # Get RAM into
        printf "\n$i - RAM INFO: \n"
        ssh $i 'cat /proc/meminfo | grep MemTotal'

        # Get Disk into
        printf "\n$i - VOLUMES INFO: \n"
        ssh $i 'lsblk'
        (ssh $i 'touch test_file &> /dev/null; rm test_file &> /dev/null' && echo "/dev/vda STATUS: OK") || echo "/dev/vda STATUS: NOT OK"
        (ssh $i 'touch ~/datav/test_file &> /dev/null; rm ~/datav/test_file &> /dev/null' && echo "/dev/vdc STATUS: OK") || echo "/dev/vdc STATUS: NOT OK"

        continue
    } 
    
    echo "Could not reach "$i

done

}