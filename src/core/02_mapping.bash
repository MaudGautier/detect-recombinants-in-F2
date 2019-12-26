#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
###                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Default parameters
num_threads=1

# Get parameters
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
		-f1|--fastq1)
			fastq1="$2"
			shift # past argument
			;;
		-f2|--fastq2)
			fastq2="$2"
			shift # past argument
			;;
		-g|--genome)
			genome_fasta="$2"
			shift # past argument
			;;
		-t|--threads)
			num_threads="$2"
			shift
			;;
		-b|--bedfile)
			intervals_bedfile="$2"
			shift # past argument
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
echo OUTPUT PREFIX   = "${output_prefix}"
echo INPUT FASTQ 1   = "${fastq1}"
echo INPUT FASTQ 2   = "${fastq2}"
echo GENOME FASTA	 = "${genome_fasta}"
echo INTERVALS BED	 = "${intervals_bedfile}"
echo NUM THREADS     = "${num_threads}"
echo SUBMISSION FILE = "${sub_file}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                  MAPPING WITH BWA MEM ON DOMESTICUS                   ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Map reads on the genome
bwa mem -M $genome_fasta \
	-t $num_threads \
	$fastq1 \
	$fastq2 \
	> ${output_prefix}.sam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                             PREPROCESSING                             ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Transform SAM to BAM
samtools view -bhS ${output_prefix}.sam -o ${output_prefix}.bam

# Sort alignments 
samtools sort -o ${output_prefix}.sorted.bam ${output_prefix}.bam

# Index
samtools index ${output_prefix}.sorted.bam

# Remove temporary files
rm -f ${output_prefix}.sam
rm -f ${output_prefix}.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                            MARK DUPLICATES                            ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Mark Duplicates
java -jar $PICARD/MarkDuplicates.jar \
	METRICS_FILE=${output_prefix}.markDup_metrics.txt \
	INPUT=${output_prefix}.sorted.bam \
	OUTPUT=${output_prefix}.sorted.markedDup.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####               FILTER DATA TO GET PROPER FRAGMENTS ONLY                ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Filter fragments
samtools view -h \
	-f 0x2 \
	-F 0x4 \
	-F 0x8 \
	-F 0x100 \
	${output_prefix}.sorted.markedDup.bam \
	> ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.sam

# Turn to BAM file
samtools view \
	-bhS ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.sam \
	-o ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.bam   

# Remove temporary file
rm -f ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.sam



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                          SUBSET TO INTERVALS                          ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Intersect with BED file
intersectBed -abam ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.bam \
	-b $intervals_bedfile \
	> ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.onIntervals.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

if [ ! -z $sub_file  ] ; then
	if [ -s ${output_prefix}.sorted.markedDup.only_mapped_fragments.only_primary.bam ] ; then
		rm -f $sub_file
	fi
fi



