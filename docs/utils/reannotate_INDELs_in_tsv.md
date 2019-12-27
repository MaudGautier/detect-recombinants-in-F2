README for ``reannotate_INDELs_in_tsv.awk``
===========================================

Description
-----------

This script allows to reannotate INDEL sequences of the TSV files so that they are under the same format as in VCF files and thus, that it becomes easy to join variant records from the VCF and genotypes from the TSV.

Output files will have the following columns:
```
#READ_ID FLAG	CHROM-POS CHROM	POS	BASE	REF	CIGAR QUAL
```

Implementation notes
--------------------

The algorithm consists in comparing the CIGAR record from two consecutive lines of the TSV file (i.e. two consecutive nucleotides sequenced).
Hereunder is the pseudocode for it (looped over all nucleotides sequenced):
```
* CASE 1: Current and previous nucleotides on the same read
  ** CASE 1A: Previous CIGAR == "M" => Need to check the current CIGAR to know if INS, DEL or SNP
	*** if current CIGAR == "M":
		--> Write previous nucleotide as SNP
	*** if current CIGAR == "I":
		--> Open an INS sequence with the previous nucleotide
	*** if current CIGAR == "D":
		--> Open a DEL sequence with the previous nucleotide

  ** CASE 1B: Previous CIGAR == "D":
	*** if current CIGAR == "M":
		--> Finish the DEL sequence with the previous nucleotide
	*** if current CIGAR == "I":
		--> Normally, impossible case
	*** if current CIGAR == "D":
		--> Add the previous nucleotide to the DEL sequence

  ** CASE 1C: Previous CIGAR == "I":
	*** if current CIGAR == "M":
		--> Finish the INS sequence with the previous nucleotide
	*** if current CIGAR == "I":
		--> Add the previous nucleotide to the INS sequence
	*** if current CIGAR == "D":
		--> Normally, impossible case

* CASE 2: Current and previous nucleotide on different reads
  --> Finish DEL or INS sequence if was started
```


Usage
-----

```
Usage: awk -f ./reannotate_INDELs_in_tsv.awk INPUT_TSV
  Parameters:
   INPUT_TSV Input TSV file (obtained with the tool sam2tsv)
```


Requirements
------------

* GNU Awk 4.2.1


