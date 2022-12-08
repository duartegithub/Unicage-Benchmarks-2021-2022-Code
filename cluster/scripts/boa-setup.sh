#!/bin/bash 

######################################
# BOA
######################################

# These hosts need BOA
hostnames="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader producer1 producer2 producer3 producer4"
# (The producers won't participate in the workloads, but they will load the generated data-sets into the unicageworker nodes)

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

#
# Do stuff to be done in the deployer here
#

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING BOA IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        #
        # Do stuff to be done in each hostname here
        # Execute a command in the hostname $i with ssh $i '<command>'
        # Copy things into the hostname $i with scp <source> $i:<destination>
        #

        continue
    } 
    
    echo "Could not reach "$i

done

}