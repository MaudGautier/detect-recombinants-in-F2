#!/usr/bin/awk -f

BEGIN {
	# Define input and output field separators
	FS = OFS = "\t"
	# Change quality from ASCII to phred score for ILLUMINA reads (-33)
	for (n=0; n<256; n++) { ord[sprintf("%c",n)] = n - 33}
}

!/^#/ {
	
	### ~~~~~~ ###
	### STEP 1:   Define variables
	### ~~~~~~ ###

	# Get variables from input file
	cigar = $9
	read_name = $1
	flag = $2
	ID = $1"-"$2
	base = $5
	ref = $8
	
	# Objective: create output lines of the form below:
	# READ_ID  FLAG  CHR-POS  CHR  POS  BASE  REF  CIGAR  QUAL
	
	# Prepare the corresponding prefix and suffixes for INS and DEL sequences
	line = $1"\t"$2"\t"$3"-"$7"\t"$3"\t"$7"\t"$5"\t"$8"\t"$9"\t"ord[$6]
	prefix_INS_base = $1"\t"$2"\t"$3"-"$7"\t"$3"\t"$7
	suffix_INS_base = $8"\t"$9"\t"ord[$6]
	prefix_DEL_ref = $1"\t"$2"\t"$3"-"$7"\t"$3"\t"$7"\t"$5
	suffix_DEL_ref = $9"\t"ord[$6]



	### ~~~~~~ ###
	### STEP 2:   Extract sequences of INDELS and SNPs
	### ~~~~~~ ###

	# CASE 1: Current and previous nucleotides on the same read
	if (ID == prev_ID) {
		# Case 1-a: Previous cigar = "M"
		if (prev_cigar == "M") {
			# If current = "M" => Write previous as SNP
			if (cigar == "M") { print prev_line }
			# If current = "I" => complete seqINS
			else if (cigar == "I") { 
				seq_INS = prev_base
				prefix_line_INS = prev_prefix_INS_base
				suffix_line_INS = prev_suffix_INS_base
			}
			# If current = "D" => complete seqDEL
			else if (cigar == "D") { 
				seq_DEL = prev_ref
				prefix_line_DEL = prev_prefix_DEL_ref
				suffix_line_DEL = prev_suffix_DEL_ref
			}
		}

		# Case 1-b: Previous cigar = "D" => The previous base is necessarily a DEL
		else if (prev_cigar == "D") { 
			# If current = "M" => Write previous as DEL + delete seqDEL
			if (cigar == "M" || cigar == "I") {
				seq_DEL = seq_DEL""prev_ref
				print prefix_line_DEL"\t"seq_DEL"\t"suffix_line_DEL
				prefix_line_DEL = ""
				suffix_line_DEL = ""
				seq_DEL = ""
			}
			# If current = "D" => complete seqDEL
			else if (cigar == "D") {
				seq_DEL = seq_DEL""prev_ref
			}
		}

		# Case 1-c: Previous cigar = "I" => The previous base is necessarily a INS
		else if (prev_cigar == "I") { 
			# If current = "M" => Write previous as INS + delete seqINS
			if (cigar == "M" || cigar == "D") {
				seq_INS = seq_INS""prev_base
				print prefix_line_INS"\t"seq_INS"\t"suffix_line_INS
				prefix_line_INS = ""
				suffix_line_INS = ""
				seq_INS = ""
			}
			# If current = "I" => complete seqINS
			else if (cigar == "I") {
				seq_INS = seq_INS""prev_base
			}
		}
		
	}

	# CASE 2: Current and previous nucleotide on different reads
	else if (ID != prev_ID) {
		if (prev_cigar == "M") { 
			print prev_line
		}
		else if (prev_cigar == "I") {
			print prefix_line_INS"\t"seq_INS"\t"suffix_line_INS
			prefix_line_INS = ""
			suffix_line_INS = ""
			seq_INS = ""
		}
		else if (prev_cigar == "D") { 
			print prefix_line_DEL"\t"seq_DEL"\t"suffix_line_DEL
			prefix_line_DEL = ""
			suffix_line_DEL = ""
			seq_DEL = ""		
		}
	}
	
	
	### ~~~~~~ ###
	### STEP 3:   Re-initialise variables corresponding to the next "previous"
	### ~~~~~~ ###

	prev_line = line
	prev_cigar = cigar
	prev_ID = ID
	prev_prefix_INS_base = prefix_INS_base
	prev_suffix_INS_base = suffix_INS_base
	prev_ref = ref
	prev_base = base
	prev_prefix_DEL_ref = prefix_DEL_ref
	prev_suffix_DEL_ref = suffix_DEL_ref

}

END {
	if (cigar == "M") {
		print prev_line
	}
	else if (cigar == "I") {
		seq_INS = seq_INS""prev_base
		print prefix_line_INS"\t"seq_INS"\t"suffix_line_INS
	}
	else if (cigar == "D") {
	   seq_DEL = seq_DEL""prev_ref
		print prefix_line_DEL"\t"seq_DEL"\t"suffix_line_DEL
	}
}


