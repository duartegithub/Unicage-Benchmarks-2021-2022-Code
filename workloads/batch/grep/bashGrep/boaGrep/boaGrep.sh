# Running command: ./boaGrep.sh <directory> <unicageworkers>
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
directory='$1'\n
BOA=/home/BOA
TUKUBAI=/home/TOOL
export PATH=$PATH:'$BOA':/home/UTL:'$TUKUBAI':/home/STAT\n' > ~/tmp_script.sh

cat >> ~/tmp_script.sh <<'EOF'
parallel=$(getconf _NPROCESSORS_ONLN)
word=area

cat ~/datav/datasets/${directory}/* | tarr | uawk NF | grep "${word}" | gyo | joinx <(echo "${word}") -
EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh | sm2 1 1 > ~/datav/outputs/$output_directory/output
