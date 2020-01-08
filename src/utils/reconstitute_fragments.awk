#!/usr/bin/awk -f
# Required options = NAME_REF, NAME_ALT

## Write header
BEGIN {
	FS = OFS = "\t"
	print "#READ_ID", "NB_VARIANTS", "NB_GENOT_REF", "NB_GENOT_ALT", \
		  "CHR", "POS", "GENOTYPES", "VARIANT_TYPES", "QUALITIES", \
		  "ALLELES", "ALLELES_REF", "ALLELES_ALT", \
		  "VCF_FILTER", "VCF_DEPTH", "VCF_FREQ", "TARGET"
}

## Implement function to increment counts of searched value
function increment_counts(count, searched, val) {
	if (val == searched) { return count + 1; }
	else { return count; }
}

## Process all genotyped bases
{
	
	## Associate category to each column
	# IDs
	read = $5 # Read ID
	target = $14 # Target ID
	
	# General info
	chrom = $1
	pos = $2
	REF_allele = $3 # allele of the REF (PARENTAL GENOME USED AS REFERENCE)
	ALT_allele = $4 # allele of the ALT (PARENTAL GENOME USED AS ALTERNATE)
	IND_allele = $7	# allele of the base sequenced for the individual
	TSV_REF_allele = $8 # allele of the TSV REF (Useful for cases of DEL)
	mut_type = $9 # SNP, INS or DEL
	genotype = $15 # whether genotype PARENT_1 or PARENT_2

	# Filters
	qual = $10 # phred-score
	vcf_filter = $11 # PASS, Low_qual, or a given threshold (obtained with GATK VQSR)
	vcf_cov = $12 # Depth (i.e. number of reads) supporting the variant
	vcf_freq = $13 # Allelic frequency of the major allele of the variant
	

	## Print everything if new read
	if (NR >1 && prev_read != read) {
		print prev_read, nb, nb_REF, nb_ALT, \
			  prev_chrom, pos_list [prev_read], genotype_list [prev_read], \
			  mut_type_list [prev_read], qual_list [prev_read], \
			  IND_allele_list [prev_read], REF_allele_list [prev_read], ALT_allele_list [prev_read], \
			  vcf_filter_list [prev_read], vcf_cov_list [prev_read],\
			  vcf_freq_list [prev_read], prev_target
	}
	
	
	## Case 1: First time we see this read
	if (pos_list [read] == "") {
		
		# Begin all lists
		pos_list [read] = pos
		REF_allele_list [read] = REF_allele
		ALT_allele_list [read] = ALT_allele
		if (mut_type == "DEL" && length(TSV_REF_allele) == 1) {
			IND_allele_list [read] = REF_allele
		} else {
			IND_allele_list [read] = IND_allele
		}
		mut_type_list [read] = mut_type
		genotype_list [read] = genotype

		qual_list [read] = qual
		vcf_filter_list [read] = vcf_filter
		vcf_cov_list [read] = vcf_cov
		vcf_freq_list [read] = vcf_freq
		
		first_genotype = genotype

		# Increment counts for the genotypes of parents REF and ALT
		nb_REF = increment_counts(0, NAME_REF, genotype)
		nb_ALT = increment_counts(0, NAME_ALT, genotype)
		nb = 1

		# Is the fragment a recombinant ?
		recombinant = "FALSE"

	}

	## Case 2: Not the first time we see this read 
	else {
		
		# Increment all lists
		pos_list [read] = pos_list [read] ";" pos
		REF_allele_list [read] = REF_allele_list [read] ";" REF_allele
		ALT_allele_list [read] = ALT_allele_list [read] ";" ALT_allele
		if (mut_type == "DEL" && length(TSV_REF_allele) == 1) {
			IND_allele_list [read] = IND_allele_list [read] ";" REF_allele
		} else {
			IND_allele_list [read] = IND_allele_list [read] ";" IND_allele
		}
		mut_type_list [read] = mut_type_list [read] ";" mut_type
		genotype_list [read] = genotype_list [read] ";" genotype
		
		qual_list [read] = qual_list [read] ";" qual
		vcf_filter_list [read] = vcf_filter_list [read] ";" vcf_filter
		vcf_cov_list [read] = vcf_cov_list [read] ";" vcf_cov
		vcf_freq_list [read] = vcf_freq_list [read] ";" vcf_freq
		
		# Increment counts for the counts of REF and ALT genotypes
		nb_REF = increment_counts(nb_REF, NAME_REF, genotype)
		nb_ALT = increment_counts(nb_ALT, NAME_ALT, genotype)
		nb = nb + 1
		
		# Is the fragment a recombinant ?
		if (genotype != first_genotype) {
			recombinant = "TRUE"
		}

	}
	
	## Re-initialise variables for next pass	
	prev_read = read
	prev_chrom = chrom	
	prev_target = target


}

## Write last fragment
END {
	if (NR > 0) {
		print read, nb, nb_REF, nb_ALT, \
			  prev_chrom, pos_list [prev_read], genotype_list [prev_read], \
			  mut_type_list [prev_read], qual_list [prev_read], \
			  IND_allele_list [prev_read], REF_allele_list [prev_read], ALT_allele_list [prev_read], \
			  vcf_filter_list [prev_read], vcf_cov_list [prev_read],\
			  vcf_freq_list [prev_read], target
	}
}


