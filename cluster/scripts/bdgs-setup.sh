#!/bin/bash 

######################################
# INFRASTRUCTURE
######################################

# These hosts need bdgs
hostnames="producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING BDGS IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Make implementation folder if it doesn't exist
        ssh $i 'mkdir -p ~/implementation'

        # Deploy uncompiled BDGS to remote host
        ssh $i 'ls ~/implementation/BigDataGeneratorSuite' &> /dev/null || scp -r ~/implementation/BigDataGeneratorSuite $i:~/implementation
            
        # Run BDGS compilation script
        ssh $i 'cd ~/implementation/BigDataGeneratorSuite/Text_datagen
            ls gsl-1.15 &> /dev/null || tar -zxvf gsl-1.15.tar.gz 
            cd gsl-1.15  
            ./configure
            make
            make install'

        continue
    } 
    
    echo "Could not reach "$i

done

}
