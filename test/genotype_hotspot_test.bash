
# Original output
hotspot=P9peak.chr1_4532254_4533494
CAST_INTERVALS=/beegfs/data/gautier/0_Genomes/Mus_musculus/MYbaits_data_3kb/intervals_5kb_CAST_EiJ.bed
bed_file_hotspot=/beegfs/data/gautier/3_Working_directory/TEST-py/${hotspot}.bed
vcf_file_hotspot=/beegfs/data/gautier/3_Working_directory/TEST-py/${hotspot}.vcf
vcf_file_CAST=/beegfs/data/gautier/5_HFM1/Sequencing_2/03_SNP_Calling/02_castaneus/Joint_variant_calling_SEQ1_AND_SEQ2.raw_variants.vcf

output_main_genotype_ORIG=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_ORIGINAL.txt
output_origin_SNPs_ORIG=/beegfs/data/gautier/3_Working_directory/TEST-py/origin-SNPs-ORIGINAL.txt
output_main_genotype_ORIG_good_format=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_ORIGINAL_GOOD_FORMAT.txt

output_main_genotype_NEW=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_NEW.txt
output_origin_SNPs_NEW=/beegfs/data/gautier/3_Working_directory/TEST-py/origin-SNPs-NEW.txt
output_main_genotype_NEW_good_format=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_NEW_GOOD_FORMAT.txt


# Prepare
grep $hotspot $CAST_INTERVALS > $bed_file_hotspot
intersectBed -a $vcf_file_CAST -b $bed_file_hotspot > $vcf_file_hotspot

# ORIGINAL
samples=`grep -v "##" $vcf_file_CAST|head -n1|cut -f10-|sed 's/\t/,/g'`
python $SRC/0_Routine_Scripts/Python/genotype_hotspot_by_SNPs_not_genot_DB_GENERALISED.py \
	-s $samples \
	-i $vcf_file_hotspot \
	-f 500 \
	-o $output_main_genotype_ORIG \
	-n ${hotspot} \
	-l $output_origin_SNPs_ORIG

# Modify output
sed -i 's/B6\/CAST/DOM\/CAST/g' $output_origin_SNPs_ORIG
sed -i 's/B6\/CA/DOM\/CAST/g' $output_main_genotype_ORIG
sed -i 's/B6\/B6/DOM\/DOM/g' $output_main_genotype_ORIG

awk -v OFS="\t" '
{
	if ($2== "DOM/CAST") {  $2 = "HET"  } else if ($2== "DOM/DOM") {  $2 = "DOM"  }
	if ($4== "DOM/CAST") {  $4 = "HET"  } else if ($4== "DOM/DOM") {  $4 = "DOM"  }
	if ($6== "DOM/CAST") {  $6 = "HET"  } else if ($6== "DOM/DOM") {  $6 = "DOM"  }
	if ($8== "DOM/CAST") {  $8 = "HET"  } else if ($8== "DOM/DOM") {  $8 = "DOM"  }
	if ($10=="DOM/CAST") { $10 = "HET"  } else if ($10=="DOM/DOM") { $10 = "DOM"  }
	if ($12=="DOM/CAST") { $12 = "HET"  } else if ($12=="DOM/DOM") { $12 = "DOM"  }
	if ($14=="DOM/CAST") { $14 = "HET"  } else if ($14=="DOM/DOM") { $14 = "DOM"  }
	if ($16=="DOM/CAST") { $16 = "HET"  } else if ($16=="DOM/DOM") { $16 = "DOM"  }
	print $1, $2"-"$4"-"$6"-"$8"-"$10"-"$12"-"$14"-"$16
}' $output_main_genotype_ORIG > $output_main_genotype_ORIG_good_format


# NEW
# rm -f $output_main_genotype_NEW
# rm -f $output_origin_SNPs_NEW
rm -f $output_main_genotype_NEW_good_format
python $SRC/8_Transmission_of_scripts_to_future_workers/detect-recombinants-in-F2/src/utils/genotype_hotspot.py \
	-s $samples \
	-v $vcf_file_hotspot \
	-f 500 \
	-o $output_main_genotype_NEW_good_format \
	-n ${hotspot} \
	--PG1 "CAST" --PG2 "DOM" --PG2_main "B6" --PG2_introgressed "DB"


# DIFF (AVANT D'INTEGRER LE GOOD FORMAT)
# diff $output_main_genotype_NEW $output_main_genotype_ORIG
# diff $output_origin_SNPs_ORIG $output_origin_SNPs_NEW

# APRES INTEGRATION DU GOOD FORMAT
diff $output_main_genotype_NEW_good_format $output_main_genotype_ORIG_good_format


