README for ``reconstitute_fragments.awk``
=========================================

Description
-----------

This script allows to reconstitute fragments from a file of genotyped variants by regrouping genotyped nucleotides on pairs of reads together.
The input file should be of the following form:
```
#CHROM	POS	REF_VCF	ALT_VCF	READ_ID	FLAG  BASE_TSV	REF_TSV	MUT_TYPE  QUAL	FILTER_VCF	NB_VCF	FREQ_VCF  TARGET  GENOTYPE
```


Usage
-----

```
Usage: awk -v NAME_REF=NAME_REF -v NAME_ALT=NAME_ALT -f ./reconstitute_fragments.awk INPUT_FILE
  Parameters:
   NAME_REF  Name of the parental genome used as a reference
   NAME_ALT  Name of the parental genome used as an alternative
   INPUT_FILE
             Input file (in the form described above)
```


Requirements
------------

* GNU Awk 4.2.1


