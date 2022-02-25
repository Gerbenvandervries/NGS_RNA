#MOLGENIS walltime=2:59:00 mem=4gb ppn=1

#Parameter mapping
#string tempDir
#string tmpDataDir
#string project
#string externalSampleID
#string intermediateDir
#string projectJobsDir
#string gtexJunc
#string annotationGtf
#string omimList
#string Python2PlusVersion
#string project
#string groupname
#string tmpName
#string logsDir


makeTmpDir "${intermediateDir}"
tmpSampleMergedDedupBam="${MC_tmpFile}"

module load ${Python2PlusVersion}
module load NGS_RNA/beta
module list

#tmp
EBROOTNGS_RNA='/home/umcg-gvdvries/git/NGS_RNA'

echo "Running ${EBROOTNGS_RNA}/scripts/annotate_SJ_with_sjdb.py"

"${EBROOTNGS_RNA}/scripts/annotate_SJ_with_sjdb.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.out.norm.tab" \
-j "${intermediateDir}/${externalSampleID}._STARgenome/sjdbList.fromGTF.out.tab" \
-o "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.tab"

echo "created: ${intermediateDir}/${externalSampleID}.SJ.out.sjdb.tab"

# Annot with genes
###TODO path###

echo "Running ${EBROOTNGS_RNA}/scripts/annotate_SJ_with_genes.py"

"${EBROOTNGS_RNA}/scripts/annotate_SJ_with_genes.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.tab" \
-g "${annotationGtf}" \
-o "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.tab"

echo "Created: ${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.tab"

# Annot with batch

echo "Running ${EBROOTNGS_RNA}/scripts/annotate_SJ_with_batch.py"

"${EBROOTNGS_RNA}/scripts/annotate_SJ_with_batch.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.tab" \
-b "${intermediateDir}/${project}.SJ.batch.list" \
-o "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.tab"

echo "Created: ${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.tab"

# Annot with GTEx
#### TODO path ####

echo "Running ${EBROOTNGS_RNA}/scripts/annotate_SJ_with_GTEx.py"

"${EBROOTNGS_RNA}/scripts/annotate_SJ_with_GTEx.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.tab" \
-g "${gtexJunc}" \
-o "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.gtex.tab"

echo "Created ${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.gtex.tab"

### Filter SJ ###

echo "Running ${EBROOTNGS_RNA}/scripts/filter_SJ.py"

"${EBROOTNGS_RNA}/scripts/filter_SJ.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.out.sjdb.genes.batch.gtex.tab" \
-o "${intermediateDir}/${externalSampleID}.SJ.filtered.tsv"

echo "Created ${intermediateDir}/${externalSampleID}.SJ.filtered.tsv"

### SJ to bed ###

echo "Running ${EBROOTNGS_RNA}/scripts/SJ_to_bed.py"

"${EBROOTNGS_RNA}/scripts/SJ_to_bed.py" \
-i "${intermediateDir}/${externalSampleID}.SJ.filtered.tsv" \
-o "${intermediateDir}/${externalSampleID}.SJ.filtered.bed"

echo "${intermediateDir}/${externalSampleID}.SJ.filtered.bed"

### Annot with OMIM ###

echo "Running: ${EBROOTNGS_RNA}/scripts/annotate_SJ_with_OMIM.py"

"${EBROOTNGS_RNA}/scripts/annotate_SJ_with_OMIM.py" \
-d "${omimList}" \
-i "${intermediateDir}/${externalSampleID}.SJ.filtered.tsv" \
-o "${intermediateDir}/${externalSampleID}.SJ.filtered.annotated.tsv"

echo "Created: ${intermediateDir}/${externalSampleID}.SJ.filtered.annotated.tsv"

