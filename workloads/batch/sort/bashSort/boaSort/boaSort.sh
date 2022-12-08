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

#rm -rf "${tmpd}"

EOF

chmod +x ~/tmp_script.sh

distr-shell ~/unicageworkers ~/tmp_script.sh
distr-dmerge ~/unicageworkers key=1 ~/datav/outputs/${output_directory}/sort.* > ~/datav/outputs/${output_directory}/output
rm -rf "${tmpd}"
