#!/bin/bash 

######################################
# NETSTAT
######################################

# These hosts need Netstat
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# If Hadoop tar is not in system, download it
netdata -version &> /dev/null || (wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && {
    echo "y" | sh /tmp/netdata-kickstart.sh --disable-telemetry
})

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING NETSTAT IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Install Netstat
        ssh $i 'netdata -version &> /dev/null' || ssh $i 'wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && {
            echo "y" | sh /tmp/netdata-kickstart.sh --disable-telemetry
        }'

        continue
    } 
    
    echo "Could not reach "$i

done

# Bonus:
printf "\nNetdata configuration for remote access and cluster monitoring depends on private tokens, therefore cannot be automated in this script. Create a Netstat account, and run the following script in each individual node:

wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh 
--claim-token <your-account-token> 
--claim-rooms <your-war-room-token> 
--claim-url https://app.netdata.cloud\n\n"

}