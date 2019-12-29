#!/usr/env/bin bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

while [[ $# -gt 1  ]]
do
	key="$1"

	case $key in
		-i|--input)
			input_bam="$2"
			shift
			;;
		-o|--output)
			output_bed="$2"
			shift
			;;
		*)
			# unknown option
			;;
	esac
	shift
done


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                      CREATE THE PAIRED BED FILE                       ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# 1. Create bed file
bamToBed -i $input_bam > ${input_bam/.bam/.bed}

# 2. Separate between Reads 1 and 2 from the bed file
awk -v FILENAME=${input_bam/.bam/.bed} -v OFS="\t" '{
	split($4, a, "/")
	print $1, $2, $3, a[1], a[2], $5, $6 >FILENAME"_"a[2]
}' ${input_bam/.bam/.bed}
rm -f ${input_bam/.bam/.bed}

# 3. Sort both files and remove temporary files
sort -k4,4 ${input_bam/.bam/.bed_1} > ${input_bam/.bam/.bed_1.sorted}
sort -k4,4 ${input_bam/.bam/.bed_2} > ${input_bam/.bam/.bed_2.sorted}
rm -f ${input_bam/.bam/.bed_1}
rm -f ${input_bam/.bam/.bed_2}

# 4. Join both reads to extract start and end of the fragments
join -1 4 -2 4 \
	-t $'\t' \
	-o 1.1,1.2,1.3,1.4,1.5,2.1,2.2,2.3,2.4,2.5 \
	${input_bam/.bam/.bed_1.sorted} \
	${input_bam/.bam/.bed_2.sorted} \
	> ${input_bam/.bam/.bed_joined}
rm -f ${input_bam/.bam/.bed_1.sorted}
rm -f ${input_bam/.bam/.bed_2.sorted}

# 5. Extract Bed file information (especially start and end of the fragments)
awk -v OFS="\t" '{
	if ($2 < $7) {
		start = $2
	} else {
		start = $7
	}

	if ($3 > $8) {
		end = $3
	} else {
		end = $8
	}

	print $1, start, end, $4
}' ${input_bam/.bam/.bed_joined} > $output_bed

# 6. Remove temporary files
rm -f ${input_bam/.bam/.bed_joined}


