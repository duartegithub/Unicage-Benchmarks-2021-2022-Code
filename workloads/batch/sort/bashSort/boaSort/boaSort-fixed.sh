# Running command: ./boaSort.sh <directory> <unicageworkers>
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
parallel=$(getconf _NPROCESSORS_ONLN)

mkdir -p ~/datav/outputs/${output_directory}
tmpd=$(mktemp -d ~/datav/outputs/${output_directory}/tmp-XXXXXX)

echo ~/datav/datasets/${directory}/*           |
grep -v \*                                                  |
tarr                                                        |
juni                                                        |
while read index target; do
	semwait --less_than "${parallel}" "${tmpd}/semaphore.*"
	touch "${tmpd}/semaphore.${index}"

	{
		msort "key=${2:-1}" "${target}" > ~/datav/outputs/${output_directory}/sort.${index}
		#rm "${tmpd}/semaphore.${index}"
	} &
done

wait



DIR=~/datav/outputs/${output_directory}/
BATCH_SIZE=1000
SUBFOLDER_NAME="grouped-"
COUNTER=1

while [ `find $DIR -maxdepth 1 -type f| wc -l` -gt $BATCH_SIZE ] ; do
  NEW_DIR=$DIR/${SUBFOLDER_NAME}${COUNTER}
  mkdir $NEW_DIR
  find $DIR -maxdepth 1 -type f | head -n $BATCH_SIZE | xargs -I {} mv {} $NEW_DIR
  let COUNTER++
if [ `find $DIR -maxdepth 1 -type f| wc -l` -le $BATCH_SIZE ] ; then
  NEW_DIR=$DIR/${SUBFOLDER_NAME}${COUNTER}
  mkdir $NEW_DIR
  find $DIR -maxdepth 1 -type f | head -n $BATCH_SIZE | xargs -I {} mv {} $NEW_DIR
fi
done

COUNTER=1

while [ -d $DIR/${SUBFOLDER_NAME}${COUNTER} ] ; do
  dmerge key=1 $DIR/${SUBFOLDER_NAME}${COUNTER}/* > $DIR/split-$COUNTER
  rm -r $DIR/${SUBFOLDER_NAME}${COUNTER}/
  let COUNTER++
done



#rm -rf "${tmpd}"

EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh
distr-dmerge ~/unicageworkers key=1 ~/datav/outputs/${output_directory}/split-* > ~/datav/outputs/${output_directory}/output
rm -rf "${tmpd}"
