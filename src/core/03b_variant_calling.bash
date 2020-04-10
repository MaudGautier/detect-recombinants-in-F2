#!/usr/bin/env bash

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
		-o|--output_prefix)
			output_prefix="$2"
			shift # past argument
			;;
		-l|--list_gvcf)
			list_gvcf="$2"
			shift # past argument
			;;
		-g|--genome)
			genome="$2"
			shift # past argument
			;;
		-ts|--true_snps)
			true_SNPs="$2"
			shift
			;;
		-us|--untrue_snps)
			untrue_SNPs="$2"
			shift
			;;
		-ti|--true_indels)
			true_indels="$2"
			shift
			;;
		-ui|--untrue_indels)
			untrue_indels="$2"
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

# Transform list of gvcf files into array
array_gvcf=($(echo $list_gvcf | tr "," "\n"))

# Print parameters
echo CONFIG FILE	 = "${config_file}"
echo OUTPUT PREFIX   = "${output_prefix}"
echo GENOME FASTA	 = "${genome}"
echo TRUE SNPS		 = "${true_SNPs}"
echo UNTRUE SNPS	 = "${untrue_SNPs}"
echo TRUE INDELS	 = "${true_indels}"
echo UNTRUE INDELS	 = "${untrue_indels}"
echo SUBMISSION FILE = "${sub_file}"
echo ARRAY GVCF:
for i in "${array_gvcf[@]}" ; do
	echo $i
done


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####              CALL ALL VARIANTS USING THE HAPLOTYPECALLER              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 0. Declare array of gvcf files as full array with arguments for GATK
declare -a full_array_gvcf
for i in "${array_gvcf[@]}" ; do
	full_array_gvcf+=( -V "$i"   )
done

# 1. Perform joint SNP-calling
java -jar $GATK/GenomeAnalysisTK.jar \
	-T GenotypeGVCFs \
	-R ${genome} \
	-o ${output_prefix}.raw_variants.vcf \
	"${full_array_gvcf[@]}"

# 2.a. Recalibrate variant scores in two steps: SNP then INDELS
java -jar $GATK/GenomeAnalysisTK.jar \
	-T VariantRecalibrator \
	-R ${genome} \
	-input ${output_prefix}.raw_variants.vcf \
	-resource:true_SNPs,known=false,training=true,truth=true,prior=10.0 ${true_SNPs} \
	-resource:untrue_SNPs,known=true,training=true,truth=false,prior=2.0 ${untrue_SNPs} \
	-an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
	-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
	-mode SNP \
	-recalFile ${output_prefix}.recalibrate_SNP.recal \
	-tranchesFile ${output_prefix}.recalibrate_SNP.tranches \
	-rscriptFile ${output_prefix}.recalibrate_SNP_plots.R

# 2.b. Apply SNP recalibration
java -jar $GATK/GenomeAnalysisTK.jar \
	-T ApplyRecalibration \
	-R ${genome} \
	-input ${output_prefix}.raw_variants.vcf \
	-mode SNP \
	--ts_filter_level 99.9 \
	-recalFile ${output_prefix}.recalibrate_SNP.recal \
	-tranchesFile ${output_prefix}.recalibrate_SNP.tranches \
	-o ${output_prefix}.recalibrated_snps_raw_indels.vcf

# 3.a. Build the Indel recalibration model
java -jar $GATK/GenomeAnalysisTK.jar \
	-T VariantRecalibrator \
	-R ${genome} \
	-input ${output_prefix}.recalibrated_snps_raw_indels.vcf \
	-resource:true_INDELs,known=false,training=true,truth=true,prior=10.0 ${true_INDELs} \
	-resource:untrue_INDELs,known=true,training=true,truth=false,prior=2.0 ${untrue_INDELs} \
	-an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
	-mode INDEL \
	-tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
	--maxGaussians 4 \
	-recalFile ${output_prefix}.recalibrate_INDEL.recal \
	-tranchesFile ${output_prefix}.recalibrate_INDEL.tranches \
	-rscriptFile ${output_prefix}.recalibrate_INDEL_plots.R 

# 3.b. Apply the desired level of recalibration to the Indels in the call set
java -Xmx6g -jar $GATK/GenomeAnalysisTK.jar \
	-T ApplyRecalibration \
	-R ${genome} \
	-input ${output_prefix}.recalibrated_snps_raw_indels.vcf \
	-mode INDEL \
	--ts_filter_level 99.9 \
	-recalFile ${output_prefix}.recalibrate_INDEL.recal \
	-tranchesFile ${output_prefix}.recalibrate_INDEL.tranches \
	-o ${output_prefix}.recalibrated_variants.vcf

grep -v "LowQual" ${output_prefix}.recalibrated_variants.vcf \
	> ${output_prefix}.hq_recalibrated_variants.vcf


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

if [ ! -z $sub_file ] ; then
	if [ -s ${output_prefix}.hq_recalibrated_variants.vcf ] ; then
		rm -f $sub_file
	fi
fi


