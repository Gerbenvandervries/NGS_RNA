#MOLGENIS nodes=1 ppn=1 mem=8gb walltime=06:00:00

#Parameter mapping
#string seqType
#string intermediateDir
#string sampleMergedBam
#string sampleMergedDedupBam
#string annotationRefFlat
#string annotationIntervalList
#string indexSpecies
#string insertsizeMetrics
#string insertsizeMetricspdf
#string insertsizeMetricspng
#string tempDir
#string scriptDir
#string flagstatMetrics
#string recreateinsertsizepdfR
#string qcMatrics
#string rnaSeqMetrics
#string dupStatMetrics
#string idxstatsMetrics
#string alignmentMetrics
#string externalSampleID
#string picardVersion
#string anacondaVersion
#string samtoolsVersion
#string ngsversion
#string pythonVersion
#string ghostscriptVersion
#string picardJar
#string project
#string collectMultipleMetricsPrefix
#string groupname
#string tmpName
#string logsDir

#Load module
module load "${picardVersion}"
module load "${samtoolsVersion}"
module load "${pythonVersion}"
module load "${ngsversion}"
module load "${ghostscriptVersion}"
module list

makeTmpDir "${intermediateDir}"
tmpIntermediateDir="${MC_tmpFile}"

#If paired-end do fastqc for both ends, else only for one
if [ "${seqType}" == "PE" ]
then
	echo -e "generate CollectMultipleMetrics"

	# Picard CollectMultipleMetrics
		java -jar -Xmx6g -XX:ParallelGCThreads=4 "${EBROOTPICARD}/${picardJar}" CollectMultipleMetrics \
		I="${sampleMergedDedupBam}" \
		O="${collectMultipleMetricsPrefix}" \
		R="${indexSpecies}" \
		PROGRAM=CollectAlignmentSummaryMetrics \
		PROGRAM=QualityScoreDistribution \
		PROGRAM=MeanQualityByCycle \
		PROGRAM=CollectInsertSizeMetrics \
		TMP_DIR="${tempDir}"/processing
	

	#Flagstat for reads mapping to the genome.
	samtools flagstat "${sampleMergedDedupBam}" >  "${flagstatMetrics}"
	
	# Fagstats idxstats, reads per chr.
	samtools idxstats "${sampleMergedDedupBam}" > "${idxstatsMetrics}"

	#CollectRnaSeqMetrics.jar
	java -XX:ParallelGCThreads=4 -jar -Xmx6g "${EBROOTPICARD}/${picardJar}" CollectRnaSeqMetrics \
	REF_FLAT="${annotationRefFlat}" \
	I="${sampleMergedDedupBam}" \
	STRAND_SPECIFICITY=NONE \
	CHART_OUTPUT="${rnaSeqMetrics}.pdf"  \
	RIBOSOMAL_INTERVALS="${annotationIntervalList}" \
	VALIDATION_STRINGENCY=LENIENT \
	O="${rnaSeqMetrics}"

	# Collect QC data from several QC matricses, and write a tablular output file.

elif [ "${seqType}" == "SR" ]
then

		#Flagstat for reads mapping to the genome.
		samtools flagstat "${sampleMergedDedupBam}" > "${flagstatMetrics}"

	# Fagstats idxstats, reads per chr.
		samtools idxstats "${sampleMergedDedupBam}" > "${idxstatsMetrics}"

	echo -e "generate CollectMultipleMetrics"

		# Picard CollectMultipleMetrics
		java -jar -Xmx6g -XX:ParallelGCThreads=4 "${EBROOTPICARD}/${picardJar}" CollectMultipleMetrics \
		I="${sampleMergedDedupBam}" \
		O="${collectMultipleMetricsPrefix}" \
		R="${indexSpecies}" \
		PROGRAM=CollectAlignmentSummaryMetrics \
		PROGRAM=QualityScoreDistribution \
		PROGRAM=MeanQualityByCycle \
		PROGRAM=CollectInsertSizeMetrics \
		TMP_DIR="${tempDir}"/processing


	#CollectRnaSeqMetrics.jar
		java -XX:ParallelGCThreads=4 -jar -Xmx6g "${EBROOTPICARD}/${picardJar}" CollectRnaSeqMetrics \
		REF_FLAT="${annotationRefFlat}" \
		I="${sampleMergedDedupBam}" \
		STRAND_SPECIFICITY=NONE \
		RIBOSOMAL_INTERVALS="${annotationIntervalList}" \
		CHART_OUTPUT="${rnaSeqMetrics}.pdf" \
		VALIDATION_STRINGENCY=LENIENT \
		O="${rnaSeqMetrics}"

fi
