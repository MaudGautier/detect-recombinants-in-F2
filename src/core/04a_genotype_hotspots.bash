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
 #$SRC/0_Routine_Scripts/Python/genotype_hotspot_by_SNPs_not_genot_DB_GENERALISED.py \
		-s $samples \
		-i $tmp_dir/${hotspot}.vcf \
		-f 500 \
		-o $output_genotype_hotspots \
		-n ${hotspot} \
		-l $output_origin_SNPs
done




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                          GENOTYPE HOTSPOTS                            ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

## OPTION: refine si on le souhaite OPTION --refine


# (TODO: MODIFIER DE FACON A N'AVOIR QUE LE BON FORMAT) Transform file in good format
file_genotype_by_hotspot=$HOTSPOT_GENOT/Main_genotype_by_hotspot.txt
file_list_origin_markers=$HOTSPOT_GENOT/List_origin_SNPs.txt

# Transformer le fichier dans le meme format que precedemment
file_genotype_by_hotspot_good_format=$HOTSPOT_GENOT/Main_genotype_by_hotspot_good_format.txt
awk -v OFS="\t" '
NR==1 {print "NA", "NA", "NA", $1}
NR >1 { 
if ($2=="B6/CA") { $2 = "HET" } else if ($2=="B6/B6") { $2 = "B6" }
if ($4=="B6/CA") { $4 = "HET" } else if ($4=="B6/B6") { $4 = "B6" }
if ($6=="B6/CA") { $6 = "HET" } else if ($6=="B6/B6") { $6 = "B6" }
if ($8=="B6/CA") { $8 = "HET" } else if ($8=="B6/B6") { $8 = "B6" }
if ($10=="B6/CA") { $10 = "HET" } else if ($10=="B6/B6") { $10 = "B6" }
if ($12=="B6/CA") { $12 = "HET" } else if ($12=="B6/B6") { $12 = "B6" }
if ($14=="B6/CA") { $14 = "HET" } else if ($14=="B6/B6") { $14 = "B6" }
if ($16=="B6/CA") { $16 = "HET" } else if ($16=="B6/B6") { $16 = "B6" }

	print $1, "NA", "NA", $2"-"$4"-"$6"-"$8"-"$10"-"$12"-"$14"-"$16
 }
' $file_genotype_by_hotspot > $file_genotype_by_hotspot_good_format


# Optional: Refine hotspot genotype with surroundings ## DE PLUS (NOUVEAU PAR RAPPORT A SCRIPT D'AVANT QUE J'AI COPIE COLLE) — REFINE LES GENOTYPE DES HOTSPOTS SI NA
python $SRC/0_Routine_Scripts/Python/refine_hotspot_genotype_with_surroundings_for_8_samples.py -i $file_genotype_by_hotspot -n 5 -o ${file_genotype_by_hotspot/.txt/.refined_with_surroundings.txt}
# Transformer en bon format
file_genotype_by_hotspot_REFINED_good_format=$HOTSPOT_GENOT/Main_genotype_by_hotspot.refined_with_surroundings_good_format.txt
awk -v OFS="\t" '
NR==1 {print "NA", "NA", "NA", $1}
NR >1 { 
if ($2=="B6/CA") { $2 = "HET" } else if ($2=="B6/B6") { $2 = "B6" }
if ($4=="B6/CA") { $4 = "HET" } else if ($4=="B6/B6") { $4 = "B6" }
if ($6=="B6/CA") { $6 = "HET" } else if ($6=="B6/B6") { $6 = "B6" }
if ($8=="B6/CA") { $8 = "HET" } else if ($8=="B6/B6") { $8 = "B6" }
if ($10=="B6/CA") { $10 = "HET" } else if ($10=="B6/B6") { $10 = "B6" }
if ($12=="B6/CA") { $12 = "HET" } else if ($12=="B6/B6") { $12 = "B6" }
if ($14=="B6/CA") { $14 = "HET" } else if ($14=="B6/B6") { $14 = "B6" }
if ($16=="B6/CA") { $16 = "HET" } else if ($16=="B6/B6") { $16 = "B6" }

	print $1, "NA", "NA", $2"-"$4"-"$6"-"$8"-"$10"-"$12"-"$14"-"$16
 }
' ${file_genotype_by_hotspot/.txt/.refined_with_surroundings.txt} > ${file_genotype_by_hotspot_REFINED_good_format}





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


