#!/bin/bash 

#####################################################
# SSH
#####################################################

# These hosts need ssh
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5 unicageleader producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# Populate /etc/hosts with default IPs
sudo chmod 777 /etc/hosts
grep "datanode1" /etc/hosts &> /dev/null || sudo echo "192.168.2.11 datanode1" >> /etc/hosts
grep "datanode2" /etc/hosts &> /dev/null || sudo echo "192.168.2.12 datanode2" >> /etc/hosts
grep "datanode3" /etc/hosts &> /dev/null || sudo echo "192.168.2.13 datanode3" >> /etc/hosts
grep "datanode4" /etc/hosts &> /dev/null || sudo echo "192.168.2.14 datanode4" >> /etc/hosts
grep "datanode5" /etc/hosts &> /dev/null || sudo echo "192.168.2.15 datanode5" >> /etc/hosts
grep "namenode" /etc/hosts &> /dev/null || sudo echo "192.168.2.10 namenode" >> /etc/hosts
grep "unicageworker1" /etc/hosts &> /dev/null || sudo echo "192.168.3.11 unicageworker1" >> /etc/hosts
grep "unicageworker2" /etc/hosts &> /dev/null || sudo echo "192.168.3.12 unicageworker2" >> /etc/hosts
grep "unicageworker3" /etc/hosts &> /dev/null || sudo echo "192.168.3.13 unicageworker3" >> /etc/hosts
grep "unicageworker4" /etc/hosts &> /dev/null || sudo echo "192.168.3.14 unicageworker4" >> /etc/hosts
grep "unicageworker5" /etc/hosts &> /dev/null || sudo echo "192.168.3.15 unicageworker5" >> /etc/hosts
grep "unicageleader" /etc/hosts &> /dev/null || sudo echo "192.168.3.10 unicageleader" >> /etc/hosts
grep "producer1" /etc/hosts &> /dev/null || sudo echo "192.168.4.11 producer1" >> /etc/hosts
grep "producer2" /etc/hosts &> /dev/null || sudo echo "192.168.4.12 producer2" >> /etc/hosts
grep "producer3" /etc/hosts &> /dev/null || sudo echo "192.168.4.13 producer3" >> /etc/hosts
grep "producer4" /etc/hosts &> /dev/null || sudo echo "192.168.4.13 producer4" >> /etc/hosts
grep "deployer" /etc/hosts &> /dev/null || sudo echo "192.168.5.10 deployer" >> /etc/hosts

# Update IPs here:
sed -i 's/^.*datanode1.*$/192.168.0.11 datanode1/' /etc/hosts #updated
sed -i 's/^.*datanode2.*$/192.168.0.14 datanode2/' /etc/hosts #updated
sed -i 's/^.*datanode3.*$/192.168.0.15 datanode3/' /etc/hosts #updated
sed -i 's/^.*datanode4.*$/192.168.0.12 datanode4/' /etc/hosts #updated
sed -i 's/^.*datanode5.*$/192.168.0.17 datanode5/' /etc/hosts #updated
sed -i 's/^.*namenode.*$/192.168.0.8 namenode/' /etc/hosts #updated
sed -i 's/^.*unicageworker1.*$/192.168.0.28 unicageworker1/' /etc/hosts #updated
sed -i 's/^.*unicageworker2.*$/192.168.0.33 unicageworker2/' /etc/hosts #updated
sed -i 's/^.*unicageworker3.*$/192.168.0.5 unicageworker3/' /etc/hosts #updated
sed -i 's/^.*unicageworker4.*$/192.168.0.31 unicageworker4/' /etc/hosts #updated
sed -i 's/^.*unicageworker5.*$/192.168.0.32 unicageworker5/' /etc/hosts #updated
sed -i 's/^.*unicageleader.*$/192.168.0.27 unicageleader/' /etc/hosts #updated
sed -i 's/^.*producer1.*$/192.168.0.10 producer1/' /etc/hosts #updated
sed -i 's/^.*producer2.*$/192.168.0.6 producer2/' /etc/hosts #updated
sed -i 's/^.*producer3.*$/192.168.0.19 producer3/' /etc/hosts #updated
sed -i 's/^.*producer4.*$/192.168.0.7 producer4/' /etc/hosts #updated
sed -i 's/^.*deployer.*$/192.168.0.9 deployer/' /etc/hosts #updated

# Avoid host resolution confusions
grep -v "^127.0." /etc/hosts > hosts.tmp
sudo mv hosts.tmp /etc/hosts

# Generate keys for vm-vm comm
[ -f ~/.ssh/id_rsa ] || {
   ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ''
}

# Allow ssh passwordless
grep 'root@' ~/.ssh/authorized_keys &>/dev/null || {
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
}

# Exclude nodes from host checking
cat > ~/.ssh/config <<EOF
Host datanode1
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host datanode2
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host datanode3
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host datanode4
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host datanode5
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host namenode
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageworker1
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageworker2
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageworker3
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageworker4
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageworker5
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host unicageleader
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host producer1
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host producer2
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host producer3
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host producer4
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
Host deployer
   IdentityFile "~/.ssh/id_rsa"
   StrictHostKeyChecking no
EOF

# For each reachable host...
for i in $hostnames; do

   printf "\n>>> CONFIGURING SSH IN "$i"\n\n"

   ping -c 1 $i &> /dev/null && {

      # Deploy ssh keys
      scp -i ~/.ssh/ibmc_rsa ~/.ssh/id_rsa* $i:~/.ssh/
      scp -i ~/.ssh/ibmc_rsa ~/.ssh/authorized_keys $i:~/.ssh/
      scp -i ~/.ssh/ibmc_rsa ~/.ssh/config $i:~/.ssh/
      scp -i ~/.ssh/ibmc_rsa /etc/hosts $i:/etc/

      # Set the right ssh permissions
      ssh -i ~/.ssh/ibmc_rsa $i 'chmod 0400 ~/.ssh/id_rsa'
      ssh -i ~/.ssh/ibmc_rsa $i 'chmod 0600 ~/.ssh/authorized_keys'

      # Reset known_hosts
      ssh -i ~/.ssh/ibmc_rsa $i 'rm ~/.ssh/known_hosts'

      continue
   } 
   
   echo "Could not reach "$i

done

# Set the right ssh permissions
chmod 0400 ~/.ssh/id_rsa
chmod 0600 ~/.ssh/authorized_keys

}