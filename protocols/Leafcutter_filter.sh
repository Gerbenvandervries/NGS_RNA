#MOLGENIS nodes=1 ppn=1 mem=34gb walltime=05:00:00

#Parameter mapping
#string intermediateDir
#string externalSampleID
#string project
#string logsDir
#string projectJobsDir
#string projectResultsDir
#string ngsversion
#string sampleMergedBamExt
#string leafcutterVersion
#string python2Version
#string omimList

#Load module
module load "${leafcutterVersion}"
module load "${ngsversion}"
module load "${python2Version}"
module list

# adding coordinates to leafcutter results
mkdir -p "${projectResultsDir}/leafcutter/"

echo "running format_leafcutter.py"
"${EBROOTNGS_RNA}/scripts/format_leafcutter.py" \
-i "${intermediateDir}${externalSampleID}.leafcutter.outlier_cluster_significance.txt" \
-e "${intermediateDir}${externalSampleID}.leafcutter.outlier_effect_sizes.txt" \
-o "${intermediateDir}${externalSampleID}.leafcutter.format.tsv"

# omim annotation
echo "Annotation with OMIM genes using annotate_leafcutter_events.py"
"${EBROOTNGS_RNA}/scripts/annotate_leafcutter_events.py" \
-i "${intermediateDir}${externalSampleID}.leafcutter.format.tsv" \
-d "${omimList}" \
-o "${intermediateDir}${externalSampleID}.leafcutter.format.omim.tsv"

# filter and produce the final report
echo "filter and produce the final report"

grep "^cluster" "${intermediateDir}${externalSampleID}.leafcutter.format.omim.tsv" > "${projectResultsDir}/leafcutter/${externalSampleID}.leafcutter.report.tsv"
awk -F "\t" '($6<0.05){print $0}' "${intermediateDir}${externalSampleID}.leafcutter.format.omim.tsv" >> "${projectResultsDir}/leafcutter/${externalSampleID}.leafcutter.report.tsv"

echo "created ${projectResultsDir}/leafcutter/${externalSampleID}.leafcutter.report.tsv"
