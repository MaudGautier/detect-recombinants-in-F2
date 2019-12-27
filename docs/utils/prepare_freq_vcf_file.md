README for ``prepare_freq_vcf_file.bash``
=========================================

Description
-----------

This script allows to extract pieces of information from the vcf file that will be useful to set the filters and detect recombination events. It does so by creating files containing the total number of reads supporting each of the two main alleles of each variant, as well as their relative allelic frequencies, after having removed variants of low quality score. 

Output files are in the following form:
chr1-100649691  T  C  PASS  3   50  0.05660377358490566
chr1-100650623  G  C  PASS  47  43  0.5222222222222223


Usage
-----

```
Usage: bash ./prepare_freq_vcf°file.bash -i INPUT_VCF -o OUTPUT_PREFIX_FREQ_VCF
  Parameters:
   -i, --input_file INPUT_BAM
             Input BAM file (mapped on the same reference genome as that given 
             in parameter -g)
   -o, --output_prefix OUTPUT_PREFIX_VCF
             Prefix of the output VCF file (without the file extension)
```


Requirements
------------

* GNU grep 3.1
* GNU Awk 4.2.1
* sort (GNU coreutils) 8.30


