#!/bin/bash 

######################################
# IMPLEMENTATIONS
######################################

# These hosts need the implementations
hostnames="unicageleader namenode producer1 producer2 producer3 producer4"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> DEPLOYING DATA GENERATION SCRIPTS IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {

        # Clean-up
        ssh $i 'rm -r ~/implementation/workloads'
        
        # If the node is the namenode...
        [ $i == namenode ] && {

            ssh $i 'mkdir -p ~/implementation/benchmarks/'
            scp -r ~/implementation/benchmarks/*.sh $i:~/implementation/benchmarks/
            
            ssh $i 'mkdir -p ~/implementation/workloads/batch/grep'
            scp -r ~/implementation/workloads/batch/grep/run-{hadoop,spark}-grep.sh $i:~/implementation/workloads/batch/grep/
            scp -r ~/implementation/workloads/batch/grep/scalaGrep $i:~/implementation/workloads/batch/grep/
            scp -r ~/implementation/workloads/batch/grep/javaGrep $i:~/implementation/workloads/batch/grep/
            ssh $i '~/implementation/workloads/batch/grep/scalaGrep/package.sh'

            ssh $i 'mkdir -p ~/implementation/workloads/batch/sort'
            scp -r ~/implementation/workloads/batch/sort/run-{hadoop,spark}-sort.sh $i:~/implementation/workloads/batch/sort/
            scp -r ~/implementation/workloads/batch/sort/scalaSort $i:~/implementation/workloads/batch/sort/
            scp -r ~/implementation/workloads/batch/sort/javaSort $i:~/implementation/workloads/batch/sort/
            ssh $i '~/implementation/workloads/batch/sort/scalaSort/package.sh'
            
            ssh $i 'mkdir -p ~/implementation/workloads/batch/wordcount'
            scp -r ~/implementation/workloads/batch/wordcount/run-{hadoop,spark}-wordcount.sh $i:~/implementation/workloads/batch/wordcount/
            scp -r ~/implementation/workloads/batch/wordcount/scalaWordcount $i:~/implementation/workloads/batch/wordcount/
            scp -r ~/implementation/workloads/batch/wordcount/javaWordcount $i:~/implementation/workloads/batch/wordcount/
            ssh $i '~/implementation/workloads/batch/wordcount/scalaWordcount/package.sh'

            ssh $i 'mkdir -p ~/implementation/workloads/query/interactive'
            scp -r ~/implementation/workloads/query/interactive/run-{hive,spark}-workloads.sh $i:~/implementation/workloads/query/interactive/
            scp -r ~/implementation/workloads/query/interactive/SQLQuery $i:~/implementation/workloads/query/interactive/
            scp -r ~/implementation/workloads/query/interactive/scalaQuery $i:~/implementation/workloads/query/interactive/
            ssh $i '~/implementation/workloads/query/interactive/scalaQuery/package.sh'

        }

        # If the node is the unicageleader...
        [ $i == unicageleader ] && {

            ssh $i 'mkdir -p ~/implementation/benchmarks/'
            scp -r ~/implementation/benchmarks/*.sh $i:~/implementation/benchmarks/
            
            ssh $i 'mkdir -p ~/implementation/workloads/batch/grep'
            scp -r ~/implementation/workloads/batch/grep/run-unicage-grep.sh $i:~/implementation/workloads/batch/grep/
            scp -r ~/implementation/workloads/batch/grep/bashGrep $i:~/implementation/workloads/batch/grep/

            ssh $i 'mkdir -p ~/implementation/workloads/batch/sort'
            scp -r ~/implementation/workloads/batch/sort/run-unicage-sort.sh $i:~/implementation/workloads/batch/sort/
            scp -r ~/implementation/workloads/batch/sort/bashSort $i:~/implementation/workloads/batch/sort/

            ssh $i 'mkdir -p ~/implementation/workloads/batch/wordcount'
            scp -r ~/implementation/workloads/batch/wordcount/run-unicage-wordcount.sh $i:~/implementation/workloads/batch/wordcount/
            scp -r ~/implementation/workloads/batch/wordcount/bashWordcount $i:~/implementation/workloads/batch/wordcount/
            
            ssh $i 'mkdir -p ~/implementation/workloads/query/interactive'
            scp -r ~/implementation/workloads/query/interactive/run-unicage-workloads.sh $i:~/implementation/workloads/query/interactive/
            scp -r ~/implementation/workloads/query/interactive/bashQuery $i:~/implementation/workloads/query/interactive/

        }
        
        # If the node is a producer...
        [[ $i == producer* ]] && {

            ssh $i 'mkdir -p ~/implementation/workloads/batch/grep'
            scp -r ~/implementation/workloads/batch/grep/genData-grep_cluster.sh $i:~/implementation/workloads/batch/grep/
            scp -r ~/implementation/workloads/batch/grep/cleanData-grep_cluster.sh $i:~/implementation/workloads/batch/grep/

            ssh $i 'mkdir -p ~/implementation/workloads/batch/sort'
            scp -r ~/implementation/workloads/batch/sort/genData-sort_cluster.sh $i:~/implementation/workloads/batch/sort/
            scp -r ~/implementation/workloads/batch/sort/cleanData-sort_cluster.sh $i:~/implementation/workloads/batch/sort/

            ssh $i 'mkdir -p ~/implementation/workloads/batch/wordcount'
            scp -r ~/implementation/workloads/batch/wordcount/genData-wordcount_cluster.sh $i:~/implementation/workloads/batch/wordcount/
            scp -r ~/implementation/workloads/batch/wordcount/cleanData-wordcount_cluster.sh $i:~/implementation/workloads/batch/wordcount/

            ssh $i 'mkdir -p ~/implementation/workloads/query/interactive'
            scp -r ~/implementation/workloads/query/interactive/genData-query_cluster.sh $i:~/implementation/workloads/query/interactive/
            scp -r ~/implementation/workloads/query/interactive/cleanData-query_cluster.sh $i:~/implementation/workloads/query/interactive/
            scp -r ~/implementation/workloads/query/interactive/SQLQuery $i:~/implementation/workloads/query/interactive/
            
        }

        continue
    } 
    
    echo "Could not reach "$i

done

}