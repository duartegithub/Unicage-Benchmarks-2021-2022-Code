# Running command: ./boaSelect.sh <directory> <unicageworkers>
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
directory='$1'\n
BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT\n' > ~/tmp_script.sh

cat >> ~/tmp_script.sh <<'EOF'
cat ~/datav/datasets/${directory}/OS_ORDER_ITEM-* | tr '|' ' ' | uawk '$6 > 990000' | self 5 6

EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh > ~/datav/outputs/$output_directory/output
