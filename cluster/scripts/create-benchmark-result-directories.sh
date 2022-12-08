#!/bin/bash 

######################################
# BENCHMARK RESULT DIRECTORY TREE
######################################

# These hosts need the the benchmark result directory tree
hostnames="unicageleader namenode deployer"

# If this node is the deployer
[ $HOSTNAME == deployer ] && {

# For each reachable host...
for i in $hostnames; do

    printf "\n>>> CREATING BENCHMARK RESULT DIRECTORY TREE IN "$i"\n\n"

    ping -c 1 $i &> /dev/null && {
        
        ssh $i '
        sizes="64GB 128GB 256GB 512GB 1024GB 2048GB 4096GB 8192GB"
        runs="run1 run2 run3"

        mkdir -p ~/implementation/benchmarks/benchmark-results/batch/
        workloads="grep sort wordcount"
        systems="hadoop spark unicage"

        for workload in $workloads; do
            for size in $sizes; do
                for system in $systems; do
                    for run in $runs; do
                        mkdir -p ~/implementation/benchmarks/benchmark-results/batch/${workload}/${workload}-${size}/${system}-result/${run}/raw-data
                        mkdir -p ~/implementation/benchmarks/benchmark-results/batch/${workload}/${workload}-${size}/${system}-result/${run}/treated-data
                        mkdir -p ~/implementation/benchmarks/benchmark-results/batch/${workload}/${workload}-${size}/${system}-result/${run}/tikz
                    done
                done
            done 
        done
            

        mkdir -p ~/implementation/benchmarks/benchmark-results/query/
        workloads="select aggregation join"
        systems="hive spark unicage"

        for workload in $workloads; do
            for size in $sizes; do
                for system in $systems; do
                    for run in $runs; do
                        mkdir -p ~/implementation/benchmarks/benchmark-results/query/${workload}/${workload}-${size}/${system}-result/${run}/raw-data
                        mkdir -p ~/implementation/benchmarks/benchmark-results/query/${workload}/${workload}-${size}/${system}-result/${run}/treated-data
                        mkdir -p ~/implementation/benchmarks/benchmark-results/query/${workload}/${workload}-${size}/${system}-result/${run}/tikz
                    done
                done
            done 
        done
        '

        continue
    } 
    
    echo "Could not reach "$i

done

}