#!/usr/env/bin bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

while [[ $# -gt 1  ]]
do
	key="$1"

	case $key in
		-i|--input)
			vcf_file="$2"
			shift
			;;
		-o|--output)
			freq_vcf_file="$2"
			shift
			;;
		*)
			# unknown option
			;;
	esac
	shift
done


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                       CREATE THE FREQ VCF FILE                        ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

grep -v "^#" $vcf_file | grep -v "LowQual" | awk -v OFS="\t" '
{
	tot_all1=0
	tot_all2=0
	for (i=10; i<=NF; ++i) {
		split($i,a,":")
		split(a[2],b, ",")
		tot_all1+=b[1]
		tot_all2+=b[2]
	}

	if (tot_all1 + tot_all2 > 0) {
		print $1"-"$2, $4, $5, $7, tot_all1, tot_all2, tot_all1 / (tot_all1 + tot_all2)
	}
}' | sort -k1,1 > $freq_vcf_file

