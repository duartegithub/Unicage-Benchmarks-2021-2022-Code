#!/bin/bash

# Running command: ./boaJoin.sh <directory> <output_directory> <unicageworkers>
#   directory: the directory of the input data-set
#   output_directory: the directory where the output will be stored
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$2-results/unicage-result
unicageworkers=$3

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/

rm ~/unicageworkers

for worker in $unicageworkers; do
    echo $worker >> ~/unicageworkers
done

unicageworkers_no_space=$(echo $unicageworkers | tr " " "_")

printf '#!/bin/bash\n
directory='$1'
output_directory='$output_directory'
unicageworkers_no_space='$unicageworkers_no_space'
unicageworkers=$(echo $unicageworkers_no_space | tr "_" " ")\n
BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT\n' > ~/tmp_script.sh

cat >> ~/tmp_script.sh <<'EOF'
mkdir -p ~/datav/outputs/${output_directory}/tmp/master
mkdir -p ~/datav/outputs/${output_directory}/tmp/tran

worker_threads=$(getconf _NPROCESSORS_ONLN)

open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
    printf %s 000 >&3
    done
}

run_with_lock(){
    local x
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
    ( "$@"; )
    printf '%.3d' $? >&3
    )&
}

task1(){
    tr "|" " " < $1 | self 1 2 >> ~/datav/outputs/${output_directory}/tmp/master/$(basename -- $1)            
    split -l420000000 ~/datav/outputs/${output_directory}/tmp/master/$(basename -- $1) ~/datav/outputs/${output_directory}/tmp/master/$(basename -- $1)
    rm ~/datav/outputs/${output_directory}/tmp/master/$(basename -- $1)
}

open_sem ${worker_threads}
for file in $(ls ~/datav/datasets/${directory}/OS_ORDER-producer*); do 
    run_with_lock task1 "$file"
done

wait

for master_split in $(ls ~/datav/outputs/${output_directory}/tmp/master/); do 

    LANG=C sort -c ~/datav/outputs/${output_directory}/tmp/master/${master_split} &> /dev/null || {
        LANG=C sort -k1,1 < ~/datav/outputs/${output_directory}/tmp/master/${master_split} > ~/datav/outputs/${output_directory}/tmp/master/${master_split}-tmp
        mv ~/datav/outputs/${output_directory}/tmp/master/${master_split}-tmp ~/datav/outputs/${output_directory}/tmp/master/$master_split
    }
            
done

for worker in ${unicageworkers}; do

    for tran_file in $(ssh ${worker} 'ls ~/datav/datasets/'${directory}'/OS_ORDER_ITEM-producer*'); do        
    
        basename_tran="$(basename -- ${tran_file})"
        scp ${worker}:${tran_file} ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}
        tr "|" " " < ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran} | self 2 6 > ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}-tmp
        mv ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}-tmp ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}

        for master_split in $(ls ~/datav/outputs/${output_directory}/tmp/master/); do 
            cjoin1 key=1 ~/datav/outputs/${output_directory}/tmp/master/${master_split} ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}
        done

        rm ~/datav/outputs/${output_directory}/tmp/tran/${basename_tran}

    done

done

EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh | self 2 3 > ~/datav/outputs/$output_directory/output
