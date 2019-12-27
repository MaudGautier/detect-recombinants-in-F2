#!/usr/bin/awk -f
# Required options = REF_GENOME (B6), ALT_GENOME (CAST)

# Write header
NR == 1 { 
	FS = OFS = "\t"
	print $1, $2, $3, $4, $5, $6, $7, $8, "MUT_TYPE", $9, $10, $11, $12, $13, "GENOTYPE"
}


# Genotype and write line
NR > 1 {
	
	# Capitalise to avoid typo problems
	ref_vcf = toupper($3)
	alt_vcf = toupper($4)
	base_tsv = toupper($7)
	ref_tsv = toupper($8)


	# Define whether the variant is a SNP, an INS or a DEL
	if (length(ref_vcf) == 1 && length(alt_vcf) == 1) { mut_type = "SNP" }
	else if (length(ref_vcf) == 1 && length(alt_vcf) > 1) { mut_type = "INS" }
	else if (length(ref_vcf) > 1 && length(alt_vcf) == 1) { mut_type = "DEL"}
	else { mut_type = "NA" }
	

	# Remove all cases in which there are more than two alleles (1 REF + 2 ALT or more)
	if (alt_vcf ~ /,/) { genot = "NA" }
	# Case SNP
	else if (mut_type == "SNP") {
		if ((base_tsv == ref_vcf) && (ref_vcf == substr(ref_tsv,1,1))) { genot = REF_GENOME }
		else if ((base_tsv == alt_vcf) && (ref_vcf == ref_tsv)) { genot = ALT_GENOME }
		else { genot = "NA" }
	}
	# Case INS	
	else if (mut_type == "INS") {
		if ((base_tsv == ref_vcf) && (substr(alt_vcf,1,1) == ref_tsv)) { genot = REF_GENOME }
		else if ((base_tsv == alt_vcf) && (ref_vcf == ref_tsv)) { genot = ALT_GENOME }
		else { genot = "NA" }
	}
	# Case DEL
	else if (mut_type == "DEL") {
		if ((base_tsv == alt_vcf) && (base_tsv == ref_tsv)) { genot = REF_GENOME }
		else if ((base_tsv == alt_vcf) && (ref_tsv == ref_vcf)) { genot = ALT_GENOME }
		else { genot = "NA" }
	}
	
	# Write output
	print $1, $2, $3, $4, $5, $6, $7, $8, mut_type, $9, $10, $11, $12, $13, genot

}


