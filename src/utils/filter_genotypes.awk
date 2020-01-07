#!/usr/bin/awk -f
# Required options = FILT_DEPTH, FILT_FREQ, FILT_QUAL

# Write header
NR == 1 { 
	FS = OFS = "\t"
	print $0
}

# Write genotype
NR > 1 {
	
	# Set column numbers for filters
	col_qual = 10
	col_depth = 12
   	col_freq = 13

	# Print line only if all filters are passed
	if (($col_qual >= FILT_QUAL) && 
		 ($col_depth >= FILT_DEPTH) && 
		 ($col_freq >= (1 - FILT_FREQ)) && 
		 ($col_freq <= FILT_FREQ)) {
		print $0
	}
	
}


