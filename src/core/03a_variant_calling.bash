#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

while [[ $# -gt 1 ]]
do
	key="$1"

	case $key in
		-c|--config|--source)
			config_file="$2"
			shift
			;;
		-o|--output_prefix)
			output_prefix="$2"
			shift # past argument
			;;
		-i|--input_file)
			input_file="$2"
			shift # past argument
			;;
		-s|--sample_name)
			sample_name="$2"
			shift
			;;
		-g|--genome)
			genome_fasta="$2"
			shift # past argument
			;;
		-ks|--known_snps)
			known_snps="$2"
			shift
			;;
		-ki|--known_indels)
			known_indels="$2"
			shift
			;;
		-s|--sub)
			sub_file="$2"
			shift
			;;
		*)
			# unknown option
			;;
	esac
	shift # past argument or value
done

echo CONFIG FILE	 = "${config_file}"
echo SAMPLE NAME	 = "${sample_name}"
echo INPUT FILE      = "${input_file}"
echo OUTPUT PREFIX   = "${output_prefix}"
echo GENOME FASTA	 = "${genome_fasta}"
echo KNOWN SNPS		 = "${known_snps}"
echo KNOWN INDELS	 = "${known_indels}"
echo SUBMISSION FILE = "${sub_file}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####           PREPARE THE GATK INPUT DATA AND WORKFLOW ELEMENTS           ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Correct potential mate pair info and coordinate-sort the reads
java -jar $PICARD/FixMateInformation.jar \
	I=$input_file \
	O=${output_prefix}.sorted_reads.bam \
	SO=coordinate \
	VALIDATION_STRINGENCY=LENIENT

# 2. Mark Duplicate reads (If not already done at the mapping step)
java -jar $PICARD/MarkDuplicates.jar \
	REMOVE_DUPLICATES=FALSE \
	I=${output_prefix}.sorted_reads.bam \
	O=${output_prefix}.nodup_reads.bam \
	M=${output_prefix}.dup_metrics.txt

# 3. Add read group information required by GATK
# Read group ID for an illumina file when no other information given from the metadata
rgid=$(samtools view $input_file | head -n1 | cut -f1 | cut -d":" -f1-4 | sed 's/:/./g') 
# Add read group info
java -Xmx6g -jar $PICARD/AddOrReplaceReadGroups.jar \
	INPUT=${output_prefix}.nodup_reads.bam \
	OUTPUT=${output_prefix}.addrg_reads.bam \
	RGID=$rgid \
	RGLB=lib.$sample_name \
	RGPL=illumina \
	RGPU=$rgid \
	RGSM=$sample_name

# 4. Index the BAM file for futher use
java -jar $PICARD/BuildBamIndex.jar \
	INPUT=${output_prefix}.addrg_reads.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                 IMPROVE MAPPING BY LOCAL REALIGNMENTS                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1.a. Identify regions for INDEL local realignment of the selected chromosome
java -jar $GATK/GenomeAnalysisTK.jar \
	-T RealignerTargetCreator \
	-R ${genome} \
	-known ${known_indels} \
	-I ${output_prefix}.addrg_reads.bam \
	-o ${output_prefix}.target_intervals.list 

# 1.b. Perform indel local realignment
java -jar $GATK/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-R ${genome} \
	-known ${known_indels} \
	-I ${output_prefix}.addrg_reads.bam \
	-targetIntervals ${output_prefix}.target_intervals.list \
	-o ${output_prefix}.realigned_reads.bam

# 2.a. Analyze patterns of covariation in the sequence dataset
java -jar $GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R ${genome} \
	-knownSites ${known_SNPs} \
	-knownSites ${known_indels} \
	-I ${output_prefix}.realigned_reads.bam \
	-o ${output_prefix}.recal_data.table

# 2.b. Do a second pass to analyze covariation remaining after recalibration
java -jar $GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R ${genome} \
	-knownSites ${known_SNPs} \
	-knownSites ${known_indels} \
	-I ${output_prefix}.realigned_reads.bam \
	-BQSR ${output_prefix}.recal_data.table \
	-o ${output_prefix}.post_recal_data.table 

# 2.c. Generate before/after plots
java -jar $GATK/GenomeAnalysisTK.jar \
	-T AnalyzeCovariates \
	-R ${genome} \
	-before ${output_prefix}.recal_data.table \
	-after ${output_prefix}.post_recal_data.table \
	-plots ${output_prefix}.recalibration_plots.pdf

# 2.d. Apply the recalibration
java -jar $GATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R ${genome} \
	-I ${output_prefix}.realigned_reads.bam \
	-BQSR ${output_prefix}.recal_data.table \
	-o ${output_prefix}.recal_reads.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####              CALL ALL VARIANTS USING THE HAPLOTYPECALLER              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Call variants in sequence data
java -Xmx16G -jar $GATK/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
	-R ${genome} \
	-I ${output_prefix}.recal_reads.bam \
	-ERC GVCF \
	-variant_index_type LINEAR \
	--variant_index_parameter 128000 \
	--genotyping_mode DISCOVERY \
	-o ${output_prefix}.raw_variants.g.vcf


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

if [ ! -z $sub_file ] ; then
	if [ -s ${output_prefix}.raw_variants.g.vcf ] ; then
		rm -f $sub_file
	fi
fi


