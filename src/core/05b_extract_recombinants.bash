#!/usr/bin/env bash


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                           GLOBAL VARIABLES                            ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Get parameters
while [[ $# -gt 1  ]]
do
	key="$1"

	case $key in
		-c|--config|--source)
			config_file="$2"
			shift
			;;
		-n|--name)
			FILT_NAME="$2"
			shift
			;;
		-d|--depth)
			FILT_DEPTH="$2"
			shift
			;;
		-f|--freq)
			FILT_FREQ="$2"
			shift
			;;
		-q|--qual)
			FILT_QUAL="$2"
			shift
			;;
		-m|--min_alleles)
			FILT_MIN_ALLELES="$2"
			shift
			;;
		-i|--input_file)
			input_file="$2"
			shift
			;;
		-o|--output_prefix)
			output_prefix="$2"
			shift
			;;
		-b|--bed_file)
			bed_file="$2"
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
	shift # past argument or value
done

# Print parameters
echo CONFIG FILE     = "${config_file}"
echo OUTPUT PREFIX	 = "${output_prefix}"
echo INPUT FILE      = "${input_file}"
echo BED FILE		 = "${bed_file}"
echo FILTER DEPTH	 = "${FILT_DEPTH}"
echo FILTER FREQ     = "${FILT_FREQ}"
echo FILTER QUAL     = "${FILT_QUAL}"
echo FILTER NAME     = "${FILT_NAME}"
echo FILTER ALLELES  = "${FILT_MIN_ALLELES}"
echo REF GENOME NAME = "${ref_name}"
echo ALT GENOME NAME = "${alt_name}"
echo SUBMISSION FILE = "${sub_file}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####             STEP 1 : FILTER GENOTYPES (READS x VARIANTS)              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Filter each line after having sorted the input file
gawk -v FILT_DEPTH=$FILT_DEPTH \
	-v FILT_FREQ=$FILT_FREQ \
	-v FILT_QUAL=$FILT_QUAL \
	-f $PROJ_SRC/utils/filter_genotypes.awk \
	<(sed '1,1d' $input_file) \
	| sort -k5,5 -k2,2g \
	> ${output_prefix}.${FILT_NAME}.ReadsxVariants.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        STEP 2 : GET FRAGMENTS                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Reconstitute fragments by writing on one line all the variants of each pair 
# of reads
gawk -v NAME_REF=$ref_name -v NAME_ALT=$alt_name \
	-f $PROJ_SRC/utils/reconstitute_fragments.awk \
	${output_prefix}.${FILT_NAME}.ReadsxVariants.txt \
	> ${output_prefix}.${FILT_NAME}.Fragments.NO_OVERLAP.txt

# Remove temporary file
rm -f ${output_prefix}.${FILT_NAME}.ReadsxVariants.txt


# Add overlapping weights when one base sequenced twice (once by each read)
python $PROJ_SRC/utils/modify_weight_of_overlaps.py \
	-i ${output_prefix}.${FILT_NAME}.Fragments.NO_OVERLAP.txt \
	-o ${output_prefix}.${FILT_NAME}.Fragments.txt \
	-r $ref_name -a $alt_name \
	--skip_header

# Remove temporary file
rm -f ${output_prefix}.${FILT_NAME}.Fragments.NO_OVERLAP.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####          STEP 3 : ADD START AND STOP POSITIONS OF FRAGMENTS           ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Sort file
bash $PROJ_SRC/utils/parallel_sort.bash \
	${output_prefix}.${FILT_NAME}.Fragments.txt \
	${output_prefix}.${FILT_NAME}.Fragments.sorted.txt \
	1 \
	10000000

# Join with targets
join -1 1 -2 4 \
	-a1 -e "NA" \
	-t $'\t' \
	-o 1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,1.15,1.16,1.17,2.1,2.2,2.3 \
	${output_prefix}.${FILT_NAME}.Fragments.sorted.txt \
	$bed_file \
	> ${output_prefix}.${FILT_NAME}.Fragments.sorted.read_ends.txt

# Remove temporary files
rm -f ${output_prefix}.${FILT_NAME}.Fragments.txt
rm -f ${output_prefix}.${FILT_NAME}.Fragments.sorted.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#                          STEP 4 : GET RECOMBINANTS                          #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Filter recombinants based on the number of each parental allleles carried
awk -v MIN_NB=$FILT_MIN_ALLELES '$3 >= MIN_NB && $4 >= MIN_NB {print}' \
	${output_prefix}.${FILT_NAME}.Fragments.sorted.read_ends.txt \
	> ${output_prefix}.${FILT_NAME}.Recombinants.Min_allele_${FILT_MIN_ALLELES}.txt

# Compress output files
gzip -f ${output_prefix}.${FILT_NAME}.Fragments.sorted.read_ends.txt
gzip -f ${output_prefix}.${FILT_NAME}.Recombinants.Min_allele_${FILT_MIN_ALLELES}.txt


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Delete submission file if everything finished
if [ ! -z $sub_file ] ; then
	if [ -s ${output_prefix}.${FILT_NAME}.Recombinants.Min_allele_${FILT_MIN_ALLELES}.txt ] ; then
		rm -f $sub_file
	fi
fi

