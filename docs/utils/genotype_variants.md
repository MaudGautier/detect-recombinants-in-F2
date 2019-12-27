README for ``genotype_variants.awk``
====================================

Description
-----------

This script allows to genotype variants from an input file containing the following columns:
```
#CHROM	POS	REF_VCF	ALT_VCF	READ_ID	FLAG	BASE_TSV	REF_TSV	QUAL	FILTER_VCF	NB_VCF	FREQ_VCF	TARGET
```


Implementation notes
--------------------

The algorithm consists in comparing the nucleotide reported for the reference (REF) and alternative (ALT) genomes on both the VCF and the TSV files.
Expectations differ depending on whether the variant is a SNP, a deletion or an insertion: indeed, for deletions and insertions, only the first nucleotide of the sequence can be compared to the reference/alternate genome of the TSV file.


Usage
-----

```
Usage: awk -v REF_GENOME=REF_GENOME -v ALT_GENOME=ALT_GENOME -f ./genotype_variants.awk INPUT_FILE
  Parameters:
   REF_GENOME 
             Name of the reference genome
   ALT_GENOME
             Name of the alternate genome
   INPUT_FILE
             Input file (must contain the REF_VCF, ALT_VCF, BASE_TSV and REF_TSV in columns 3, 4, 7 and 8)
```


Requirements
------------

* GNU Awk 4.2.1


