README for ``prepare_freq_vcf_file.bash``
=========================================

Description
-----------

This script allows to extract pieces of information from the vcf file that will be useful to set the filters and detect recombination events. It does so by creating files containing the total number of reads supporting each of the two main alleles of each variant, as well as their relative allelic frequencies, after having removed variants of low quality score. 

Output files are in the following form:
```
chr1-100649691  T  C  PASS  3   50  0.05660377358490566
chr1-100650623  G  C  PASS  47  43  0.5222222222222223
```

Usage
-----

```
Usage: bash ./prepare_freq_vcf_file.bash -i INPUT_VCF -o OUTPUT_FREQ_VCF
  Parameters:
   -i, --input INPUT_VCF
             Input VCF file
   -o, --output OUTPUT_FREQ_VCF
             Output freq_VCF file
```


Requirements
------------

* GNU grep 3.1
* GNU Awk 4.2.1
* sort (GNU coreutils) 8.30


