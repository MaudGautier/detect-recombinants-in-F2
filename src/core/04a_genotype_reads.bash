#!/usr/env/bin bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get parameters
while [[ $# -gt 1 ]]
do
	key="$1"
	
	case $key in 
		-c|--config|--source)
			config_file="$2"
			shift
			;;
		-t|--tmp_prefix)
			tmp_prefix="$2"
			shift # past argument
			;;
		-i|--input_bam)
			input_bam="$2"
			shift
			;;
		-f|--freq_vcf_file)
			freq_vcf_file="$2"
			shift
			;;
		-o|--output_prefix)
			output_prefix="$2"
			shift
			;;
		-b|--bed_file)
			bed_subset="$2"
			shift
			;;
		-g|--genome)
			genome="$2"
			shift
			;;
		-r|--ref_name)
			ref_name="$2"
			shift
			;;
		-a|--alt_name)
			alt_name="$2"
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
		shift
done

# Print parameters
echo CONFIG FILE	 = "${config_file}"
echo OUTPUT PREFIX	 = "${output_prefix}"
echo TMP PREFIX      = "${tmp_prefix}"
echo INPUT FILE      = "${input_bam}"
echo FREQ VCF FILE	 = "${freq_vcf_file}"
echo BED SUBSET	     = "${bed_subset}"
echo GENOME			 = "${genome}"
echo REF GENOME NAME = "${ref_name}"
echo ALT GENOME NAME = "${alt_name}"
echo SUBMISSION FILE = "${sub_file}"

# Create tmp and output directories
if [ ! -d "${tmp_prefix%/*}" ] ; then mkdir -p "${tmp_prefix%/*}" ; fi
if [ ! -d "${output_prefix%/*}" ] ; then mkdir -p "${output_prefix%/*}" ; fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                REDUCE BAM FILE TO THE SELECTED HOTSPOTS               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

intersectBed -a $input_bam -b $bed_subset > ${tmp_prefix}.bam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                            CREATE TSV FILES                           ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Create SAM files
samtools view -h ${tmp_prefix}.bam > ${tmp_prefix}.sam

# 2. Convert SAM to TSV
sam2tsv -r $genome -o ${tmp_prefix}.tsv ${tmp_prefix}.sam

# 3. Delete temporary SAM file
rm -f ${tmp_prefix}.sam


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                       REANNOTATE THE ALIGNMENTS                       ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Get INDEL sequences and reannotate SNP/INS/DEL
awk -f $PROJ_SRC/utils/reannotate_INDELs_in_tsv.awk \
	${tmp_prefix}.tsv \
	> ${tmp_prefix}.annotated.tsv
rm -f ${tmp_prefix}.tsv

# 2. Sort the file
bash $PROJ_SRC/utils/parallel_sort.bash \
	${tmp_prefix}.annotated.tsv \
	${tmp_prefix}.annotated.sorted.tsv \
	3 \
	50000000
rm -f ${tmp_prefix}.annotated.tsv


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                         REDUCE TSV TO VARIANTS                        ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Join FREQ_VCF and TSV records
join -1 1 -2 3 \
	-t $'\t' \
	-o 2.4,2.5,1.2,1.3,2.1,2.2,2.6,2.7,2.9,1.4,1.5,1.6,1.7 \
	${freq_vcf_file} \
	${tmp_prefix}.annotated.sorted.tsv \
	> ${tmp_prefix}.annotated.onlyVariantPositions.MISSING.txt

# 2. Sort joined records on ID
awk -v OFS="\t" '{ 
	print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11+$12, $13 
	}' ${tmp_prefix}.annotated.onlyVariantPositions.MISSING.txt | \
	sort -k5,5 | uniq \
	> ${tmp_prefix}.annotated.onlyVariantPositions.sorted.txt

# 3. Delete temporary file
rm -f ${tmp_prefix}.annotated.onlyVariantPositions.MISSING.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                           ADD INTERVAL NAME                           ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Associate each read to the locus it targets
intersectBed -abam ${tmp_prefix}.bam -b $bed_subset -bed -wb | \
	awk -v OFS="\t" '{split($4,a,"/") ; print a[1],$16"/"$14"/"$15}' | \
	sort -k1,1 | uniq \
	> ${tmp_prefix}.targets.txt

# 2. Link the reduced file (TSV joined with VCF) with targets
join -t $'\t' -1 5 -2 1 -a1 -e "NA" \
	-o 1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,2.2 \
	${tmp_prefix}.annotated.onlyVariantPositions.sorted.txt \
	${tmp_prefix}.targets.txt | sort -k1,1 -k2,2g | \
	awk -v OFS="\t" '
	BEGIN {
		print "#CHROM", "POS", "REF_VCF", "ALT_VCF", "READ_ID", "FLAG", "BASE_TSV", "REF_TSV", "QUAL", "FILTER_VCF", "NB_VCF", "FREQ_VCF", "TARGET"
	}
	{print}' \
	> ${tmp_prefix}.onlyVariantPositions.allFilters.sorted.targets.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                         GENOTYPE EACH VARIANT                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

awk -v REF_GENOME=$ref_name -v ALT_GENOME=$alt_name \
	-f $PROJ_SRC/utils/genotype_variants.awk \
	${tmp_prefix}.onlyVariantPositions.allFilters.sorted.targets.txt \
	> ${output_prefix}.Genotyped_ReadsxVariants.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Delete temporary files
rm -rf "${tmp_prefix%/*}"

# Delete submission file if everything finished
if [ ! -z $sub_file ] ; then
	if [ -f ${output_prefix}.hq_recalibrated_variants.vcf ] ; then
		rm -f $sub_file
	fi
fi


