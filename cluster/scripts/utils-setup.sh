#!/bin/bash 

######################################
# JDK
######################################

# These hosts need jdk
hostnames="datanode1 datanode2 datanode3 datanode4 datanode5 namenode producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING JDK IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # If jdk is not installed, install OpenJDK 8
        ssh $i 'ls /usr/lib/jvm/java* &> /dev/null || {
            sudo add-apt-repository -y ppa:openjdk-r/ppa
            sudo apt-get update
            sudo apt-get install -y openjdk-8-jdk
        }'

        # Set environmental variables
        ssh $i 'grep JAVA .bashrc &> /dev/null || cat >> .bashrc << '"'"'EOF'"'"'

# JAVA Variables START
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
# JAVA Variables END
EOF'

        continue
    } 
    
    echo "Could not reach "$i

done

}

######################################
# BUILD ESSENTIAL
######################################

# These hosts need jdk
hostnames="producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING BUILD-ESSENTIAL IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {
    
    	# If build-essential is not installed, install build-essential
    	ssh $i 'make -version &> /dev/null || {
    	    sudo apt-get update
    	    sudo apt-get install -y build-essential    
    	}'
    	    
        continue
    } 
    
    echo "Could not reach "$i

done

}

######################################
# SCALA & SBT
######################################

# These hosts need Scala
hostnames="namenode"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# Make tar folder if it doesn't exist
mkdir -p ~/tar/

# If Scala deb is not in system, download it
ls ~/tar/ | grep ^scala &> /dev/null || wget https://downloads.lightbend.com/scala/2.12.15/scala-2.12.15.deb -P ~/tar/

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING SCALA IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # If Scala is not installed, install Scala
        ssh $i 'scala -version &> /dev/null' || {
            scp -r ~/tar/scala*.deb $i:~/
            ssh $i 'sudo dpkg -i ~/scala-2.12.15.deb'
        }

        # If sbt is not installed, install sbt
        ssh $i 'sbt -version &> /dev/null || {
            echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
            echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
            curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
            sudo apt-get update
            sudo apt-get install -y sbt
        }'

        ssh $i 'rm ~/scala*.deb &> /dev/null'

        continue
    } 
    
    echo "Could not reach "$i

done

}

######################################
# PYTHON & PIP
######################################

# These hosts need Python
hostnames="namenode"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CONFIGURING PYTHON IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # If Python is not installed, install Python
        ssh $i 'python3 --version &> /dev/null || {
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo apt-get install -y python3.8
        }'

        # If pip is not installed, install pip
        ssh $i 'pip3 --version &> /dev/null || sudo apt-get install -y python3-pip'

        continue
    } 
    
    echo "Could not reach "$i

done

}
