README for ``filter_genotypes.awk``
===================================

Description
-----------

This script allows to filter out genotyped nucleotides (reads x variants) supported by too few reads (low sequencing depth), with alleles segregating at frequencies far from the expected Mendelian transmission or sequenced at a too low quality (i.e. likely to be erroneously sequenced).
The input file should be of the following form:
```
#CHROM	POS	REF_VCF	ALT_VCF	READ_ID	FLAG  BASE_TSV	REF_TSV	MUT_TYPE  QUAL	FILTER_VCF	NB_VCF	FREQ_VCF  TARGET  GENOTYPE
```


Usage
-----

```
Usage: awk -v FILT_DEPTH=FILT_DEPTH -v FILT_FREQ=FILT_FREQ -v FILT_QUAL=FILT_QUAL -f ./filter_readsxvariants.awk INPUT_FILE
  Parameters:
   FILT_DEPTH 
             Minimum number of reads (i.e. sequencing depth) supporting a 
             variant for it not to be filtered out
   FILT_FREQ
             Frequency value set so that the variants that are not filtered out 
             have a frequency comprised between 1-FILT_FREQ and FILT_FREQ
   FILT_QUAL
             Minimum phred-score quality required for a genotyped nucleotide 
             not to be filtered out
   INPUT_FILE
             Input file (must contain the FILT_DEPTH, FILT_FREQ and FILT_QUAL in 
             columns 10, 12 and 13)
```


Requirements
------------

* GNU Awk 4.2.1


