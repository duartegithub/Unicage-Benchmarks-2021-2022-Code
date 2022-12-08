#!/bin/bash

# Running command: ./run-unicage-wordcount.sh <volume> <behcnmark-mode>
#   volume: the input data size, GB
#   benchmark-mode: write "benchmark-mode" to run this script in benchmark mode (repeat 3 times)

# If this node is the unicageleader
[ $HOSTNAME == unicageleader ] && {

a=$1
basedir=$(dirname "$(readlink -f "$0")")
unicageworkers="unicageworker1 unicageworker2 unicageworker3 unicageworker4 unicageworker5"
directory="batch/wordcount/wordcount-"$a"GB"

runs="run1"

[ "$2" = "benchmark-mode" ] && {
    printf "\n>>> BENCHMARK-MODE: THE WORKLOAD WILL RUN 3 TIMES\n\n"
    runs="run1 run2 run3"
}

for run in $runs; do

    # Clean previous outputs
    printf "\n>>> CLEANING PREVIOUS OUTPUTS\n\n"

    rm -r ~/datav/outputs/$directory-results/unicage-result/

    for i in $unicageworkers; do

        ping -c 1 $i &> /dev/null && {

            ssh $i 'rm -r ~/datav/outputs/'$directory'-results/unicage-result/'
            continue
        }

        echo "Could not reach "$i

    done


    # Prepare cluster for benchmark
    printf "\n>>> PREPARING FOR BENCHMARK - HADOOP CLUSTER\n\n"    
    
    $basedir/../../../benchmarks/prepare-for-benchmark.sh 1


    # Run workload
    start=$(date +%s)
    printf "\n>>> STARTING UNICAGE WORDCOUNT: $(date -u) ($start)\n\n"
    
    #$basedir/bashWordcount/tukubaiWordcountV2_parallel_fifo.sh $directory "$unicageworkers"
    #$basedir/bashWordcount/boaWordcount/boaWordcount.sh $directory "$unicageworkers"
    
    # BOA fix for 512+ GB input (no performance impact):
    $basedir/bashWordcount/boaWordcount/boaWordcount-fixed.sh $directory "$unicageworkers"

    end=$(date +%s)
    printf "\n>>> ENDING UNICAGE WORDCOUNT: $(date -u) ($end)\n\n"


    # Collect metrics
    printf "\n>>> DOWNLOADING METRICS - UNICAGE CLUSTER\n\n"

    $basedir/../../../benchmarks/netdata-collect.sh $a 1 "$directory/unicage-result/$run" $start $end


    # Verify results
    ssh deployer '~/implementation/workloads/batch/wordcount/verify-wordcount.sh '$a' '$run' "unicage"'

done

}