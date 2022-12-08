#!/bin/bash 

# WARNING! Make sure the volumes in each node are /dev/vdc, otherwise this will not work, and may break the cluster. To do this more securely, do it manually.

######################################
# INFRASTRUCTURE
######################################

# These hosts need mounting of a data volume
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING DATA VOLUMES IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Make datav folder if it doesn't exist
        ssh $i 'mkdir -p ~/datav'

        # If data volume is not mounted, mount data volume
        ssh $i 'mount | grep /dev/vdc &> /dev/null || {
	        mkfs -t ext4 /dev/vdc
	        mount -t ext4 /dev/vdc ~/datav
        }'

        # Set environmental variables
        ssh $i 'grep DATA_VOLUME .bashrc &> /dev/null || cat >> .bashrc << '"'"'EOF'"'"'

# INFRASTRUCTURE Variables START
export DATA_VOLUME=~/datav/
# INFRASTRUCTURE Variables END
EOF'

        # Set auto-mount on boot
        ssh $i 'ls /etc/fstab.bkp &> /dev/null || cp /etc/fstab /etc/fstab.bkp'
        ssh $i 'grep "/dev/vdc" /etc/fstab &> /dev/null || sudo echo "/dev/vdc /root/datav/ ext4 defaults 0 0" >> /etc/fstab' 

        continue
    } 
    
    echo "Could not reach "$i

done

}