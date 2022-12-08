# Running command: ./boaWordcount.sh <directory> <unicageworkers>
#   directory: the directory of the input data-set
#   unicageworkers: the list of unicageworkers

directory=$1
output_directory=$directory-results/unicage-result
unicageworkers=$2

BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:$BOA:/home/UTL:$TUKUBAI:/home/STAT

mkdir -p ~/datav/outputs/$output_directory/

rm ~/unicageworkers

for worker in $unicageworkers; do
    echo $worker >> ~/unicageworkers
done

printf '#!/bin/bash\n
directory='$1'
output_directory='$output_directory'\n
BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT\n' > ~/tmp_script.sh

cat >> ~/tmp_script.sh <<'EOF'
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

task(){
        tr " " "\n" < ~/datav/datasets/${directory}/$1 | uawk NF | msort key=1 | count 1 1 > ~/datav/outputs/${output_directory}/counts/$1-counts;
}

mkdir -p ~/datav/outputs/${output_directory}/counts

open_sem ${worker_threads}
for file in $(ls ~/datav/datasets/${directory}); do
	run_with_lock task "$file"
done

wait

dmerge key=1 ~/datav/outputs/${output_directory}/counts/* | sm2 1 1 2 2 > ~/datav/outputs/${output_directory}/split

EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh
distr-dmerge ~/unicageworkers key=1 ~/datav/outputs/${output_directory}/split | sm2 1 1 2 2 > ~/datav/outputs/${output_directory}/output
