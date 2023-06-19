set -o pipefail
#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string project
#string logsDir
#string projectJobsDir
#string strandedness
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version

#Load module
module load "${leafcutterVersion}"
module load "${python2Version}"
module list

# detect strand for RegTools
num1="$(tail -n 2 "${strandedness}" | awk '{print $7}' | head -n 1)"
num2="$(tail -n 1 "${strandedness}" | awk '{print $7}')"

STRANDED=$(echo -e "${num1}\t${num2}" | awk '{if ($1 > 0.6){print "1"}else if($2 > 0.6){print "2"}else if($1 < 0.6 && $2 < 0.6){print "0"} }')

echo -e "\nWith strandedness type: ${STRANDED},
where (0 = unstranded, 1 = first-strand/RF, 2, = second-strand/FR)."

rm -f "${intermediateDir}${project}_juncfiles.txt"
cd "${intermediateDir}" || exit
for bamfile in *."${sampleMergedBamExt}"
do

	echo Converting "${bamfile}" to "${bamfile}".junc
	samtools index "${bamfile}"

	#BUG: set to standed 0.
	regtools junctions extract \
	-a 8 \
	-m 50 \
	-M 500000 \
	-s 0 \
	"${bamfile}" \
	-o "${bamfile}.junc"

	echo "${intermediateDir}${bamfile}.junc" >> "${intermediateDir}${project}_juncfiles.txt"
done

python "${EBROOTLEAFCUTTER}/clustering/leafcutter_cluster_regtools.py" \
-j "${intermediateDir}/${project}_juncfiles.txt" \
-m 50 \
-r "${intermediateDir}" \
-o "${project}_leafcutter_cluster_regtools" \
-l 500000 \
--nochromcheck=NOCHROMCHECK

cd - || exit
