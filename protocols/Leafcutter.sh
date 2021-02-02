#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#list externalSampleID
#string project
#string logsDir
#string strandedness
#string sampleMergedBamExt
#string leafcutterVersion

#Load module
module load ${leafcutterVersion}
module list

#https://www.researchgate.net/publication/282645615_Alternative_Splicing_Signatures_in_RNA-seq_Data_Percent_Spliced_in_PSI

# detect strand for RegTools
STRANDED="$(num1="$(tail -n 2 "${strandedness}" | awk '{print $7'} | head -n 1)"; num2="$(tail -n 2 "${strandedness}" | awk '{print $7'} | tail -n 1)"; if (( $(echo "$num1 > 0.6" | bc -l) )); then echo "1"; fi; if (( $(echo "$num2 > 0.6" | bc -l) )); then echo "2"; fi; if (( $(echo "$num1 < 0.6 && $num2 < 0.6" | bc -l) )); then echo "0"; fi)"

echo -e "\nWith strandedness type: ${STRANDED}, 
where (0 = unstranded, 1 = first-strand/RF, 2, = second-strand/FR)."

rm -f "${intermediateDir}""${project}"_juncfiles.txt
cd "${intermediateDir}"
for bamfile in $(ls *.${sampleMergedBamExt}); do

    echo Converting "${bamfile}" to "${bamfile}".junc
    samtools index "${bamfile}"

    regtools junctions extract \
    -a 8 \
    -m 50 \
    -M 500000 \
    -s "${STRANDED}" \
    "${bamfile}" \
    -o "${bamfile}".junc

    echo "${bamfile}".junc >> "${intermediateDir}${project}"_juncfiles.txt
done

python "${EBROOTLEAFCUTTER}"/clustering/leafcutter_cluster_regtools.py \
-j "${intermediateDir}/${project}"_juncfiles.txt \
-m 50 \
-r "${intermediateDir}" \
-o "${project}"_leafcutter_cluster_regtools \
-l 500000 \
--checkchrom

echo "create group_list"
awk -F',' '{print $1".sorted.merged.bam\t"$2}' "${intermediateDir}"/metadata.csv \
> "${intermediateDir}${project}"_groups_file.txt

sed 1d "${intermediateDir}${project}"_groups_file.txt > "${intermediateDir}${project}"_groups_file.txt

Rscript "${EBROOTLEAFCUTTER}"/scripts/leafcutter_ds.R \
--num_threads 4 \
-o "${intermediateDir}${project}_leafcutter_ds" \
"${intermediateDir}${project}"_leafcutter_cluster_regtools_perind_numers.counts.gz \
"${intermediateDir}${project}"_groups_file.txt

Rscript "${EBROOTLEAFCUTTER}"/scripts/ds_plots.R \
-e "${EBROOTLEAFCUTTER}"/annotation_codes/gencode_hg19/gencode_hg19_all_exons.txt.gz \
-o "${intermediateDir}${project}_leafcutter_ds" \
"${intermediateDir}${project}"_leafcutter_cluster_regtools_perind_numers.counts.gz \
"${intermediateDir}${project}"_groups_file.txt \
"${intermediateDir}${project}"_leafcutter_ds_cluster_significance.txt \
-f 0.05

cd -
