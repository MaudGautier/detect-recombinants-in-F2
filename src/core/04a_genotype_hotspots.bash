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
		-t|--tmp_dir)
			tmp_dir="$2"
			shift # past argument
			;;
		-o|--origin_snps)
			output_origin_SNPs="$2"
			shift
			;;
		-g|--genotype_hotspots)
			output_genotype_hotspots="$2"
			shift
			;;
		-b|--bed_file)
			bed_intervals="$2"
			shift
			;;
		-v|--vcf_file)
			vcf_file="$2"
			shift
			;;
		--PG1|--pg1)
			PG1="$2"
			shift
			;;
		--PG2|--pg2)
			PG2="$2"
			shift
			;;
		--PG2_introgressed|--pg2_introgressed|--PG2_intro)
			PG2_introgressed="$2"
			shift
			;;
		--PG2_main|--pg2_main)
			PG2_main="$2"
			shift
			;;
		-r|--refine|--refine_file)
			refine_file="${2}"
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
echo CONFIG FILE     = "${config_file}"
echo GENOT HOTSPOTS  = "${output_genotype_hotspots}"
echo ORIGIN SNPS     = "${output_origin_SNPs}"
echo VCF FILE        = "${vcf_file}"
echo BED FILE        = "${bed_intervals}"
echo TMP DIR         = "${tmp_dir}"
echo PG1             = "${PG1}"
echo PG2             = "${PG2}"
echo PG2_MAIN        = "${PG2_main}"
echo PG2_INTROGRESSED= "${PG2_introgressed}"
echo REFINE FILE     = "${refine_file}"
echo SUBMISSION FILE = "${sub_file}"

# Create tmp directory
if [ ! -d "${tmp_dir}" ] ; then mkdir -p "${tmp_dir}" ; fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                          GENOTYPE HOTSPOTS                            ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Initialise output files
grep -v "^##" $vcf_file | head -n1 | awk -v OFS="-" '
	{
		sample_list=$10
		for (i=11; i<=NF; ++i) { sample_list=sample_list"-"$i }
	} END {
		print sample_list
	}' > $output_genotype_hotspots
echo -e "#HOTSPOT\tCHR\tPOS\tREF\tALT\tORIGIN"> $output_origin_SNPs

# Write output files for each hotspot
#TODO: modifier en while read chr start stop hotspot
list_hotspots=(`cut -f4 $bed_intervals`)
echo -e "Genotyping all hotspots..."
for hotspot in ${list_hotspots[@]} ; do

	# Prepare hotspot
	grep $hotspot $bed_intervals > $tmp_dir/${hotspot}.bed
	intersectBed -a $vcf_file -b $tmp_dir/${hotspot}.bed > $tmp_dir/${hotspot}.vcf

	# Write line of hotspot
	samples=`grep -v "##" $vcf_file|head -n1|cut -f10-|sed 's/\t/,/g'`
	python $PROJ_SRC/utils/genotype_hotspot.py \
		-s $samples \
		-v $tmp_dir/${hotspot}.vcf \
		-f 500 \
		-o $output_genotype_hotspots \
		-n ${hotspot} \
		--PG1 $PG1 --PG2 $PG2 --PG2_main $PG2_main \
		--PG2_introgressed $PG2_introgressed
done


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                       OPTIONAL: REFINE GENOTYPES                      ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# TODO: REWORK AND ADD SCRIPT REFINEMENT
if [ ! -z $refine_file ] ; then
	echo -e "Performing refinement..."
   #  python $SRC/0_Routine_Scripts/Python/refine_hotspot_genotype_with_surroundings_for_8_samples.py \
		# -i $file_genotype_by_hotspot \
		# -n 5 \
		# -o $refine_file
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Delete temporary folder
rm -rf $tmp_dir

# Delete submission file if everything finished
if [ ! -z $sub_file ] ; then
	if [ -s $output_genotype_hotspots ] ; then
		rm -f $sub_file
	fi
fi


