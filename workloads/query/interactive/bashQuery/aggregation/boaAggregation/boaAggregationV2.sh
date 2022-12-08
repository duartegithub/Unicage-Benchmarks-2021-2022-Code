# Running command: ./boaAggregation.sh <directory> <unicageworkers>
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

printf '#!/bin/bash\n
directory='$1'
output_directory='$output_directory'\n
BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT\n' > ~/tmp_script.sh

cat >> ~/tmp_script.sh <<'EOF'
mkdir -p ~/datav/outputs/${output_directory}/
tmpd=$(mktemp -d ~/datav/outputs/${output_directory}/tmp-XXXXXX)

exec 2> >(cat >&2; rm -rf "${tmpd}")

mkdir -p ~/datav/outputs/${output_directory}/splits/
for file in $(ls ~/datav/datasets/${directory}/OS_ORDER_ITEM-*); do
    basename="$(basename -- $file)"
    split -l179200000 $file ~/datav/outputs/${output_directory}/splits/$basename
done

for part in $(echo ~/datav/outputs/${output_directory}/splits/* | tarr); do
    tr '|' ' ' < "${part}" |
    self 3 4               |
    msort key=1            |
    sm2 1 1 2 2            > "${tmpd}/$(basename "${part}")"
done

dmerge key=1 "${tmpd}/"* |
sm2 1 1 2 2              > ~/datav/outputs/${output_directory}/split
EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh
distr-dmerge ~/unicageworkers key=1 ~/datav/outputs/${output_directory}/split | sm2 1 1 2 2 > ~/datav/outputs/${output_directory}/output
