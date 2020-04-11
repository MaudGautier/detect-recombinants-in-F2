
# Original output
main_genotype_ORIG=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_ORIGINAL.txt
output_main_genotype_ORIG_refined=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_ORIGINAL_REFINED.txt
output_main_genotype_ORIG_refined_good_format=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_ORIGINAL_REFINED_GOOD_FORMAT.txt

main_genotype_NEW=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_NEW.txt
output_main_genotype_NEW_refined=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_NEW_REFINED.txt
output_main_genotype_NEW_refined_good_format=/beegfs/data/gautier/3_Working_directory/TEST-py/main_genotype_NEW_REFINED_GOOD_FORMAT.txt

# ORIGINAL
cp $DATA/5_HFM1/Sequencing_2/04_Hotspot_Genotyping/Main_genotype_by_hotspot.txt $main_genotype_ORIG

## LINE TO TEST:
python $SRC/0_Routine_Scripts/Python/refine_hotspot_genotype_with_surroundings_for_8_samples.py \
	-i $main_genotype_ORIG \
	-n 5 \
	-o ${output_main_genotype_ORIG_refined}


# Modify output
sed -i 's/B6\/CA/DOM\/CAST/g' $output_main_genotype_ORIG_refined
sed -i 's/B6\/B6/DOM\/DOM/g' $output_main_genotype_ORIG_refined

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
}' $output_main_genotype_ORIG_refined > $output_main_genotype_ORIG_refined_good_format




# NEw script
# python $SRC/8_Transmission_of_scripts_to_future_workers/detect-recombinants-in-F2/src/utils/
# -i $main_genotype_NEW \
#     -n 5 \
#     -o $output_main_genotype_NEW_refined_good_format
#




diff


