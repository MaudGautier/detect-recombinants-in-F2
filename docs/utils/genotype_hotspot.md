README for ``genotype_hotspot.py``
==================================

Description
-----------

This script allows to genotype a hotspot in a F2 individual that results from a cross between parental genome 1 (PG1) and parental genome 2 (PG2), the latter being the result of the introgression of PG2_introgressed into PG2_main.

Hotspot genotyping is performed in three consecutive steps:

**1. Selecting unambiguously genotypable SNPs**
Given the cross (PG1 x PG2_main/PG2_introgressed), the hotspot *cannot* be in a PG1/PG1 background. 
Thus, when using the mapping against genome PG1, if, for a given SNP, the variant-caller (e.g. GATK) has assigned a "0/0" genotype in at least one of the samples, it necessarily means that the "0/0"-genotyped sample is in a PG1 x PG2_main background with allele PG1 == allele PG2_main, or in a PG1 x PG2_introgressed background with allele PG1 == allele PG2_introgressed.
Also, if a '0/0' genotype is reported by the variant-caller, it means that at lest one alternative allele has been found (PG2_introgressed in the case of a PG1 x PG2_main background or PG2_main in the case of a PG1 x PG2_introgressed background).

Since only the variants between PG1 and PG2 are of interest (but not those between PG2_introgressed and PG2_main) and to avoid genotyping errors (since reads have not been mapped directly on the PG2_introgressed genome), SNPs for which the PG2_introgressed allele and the PG2_main allele are different were excluded to genotype the hotspot.
Therefore, in practice, if for one SNP, one sample has been assigned a "0/0" genotype by the variant-caller, the corresponding SNP is excluded from this analysis (i.e. to genotype the hotspot).

In addition, only SNPs that are supported by a minimum read coverage (argument ``-f`` or ``--filter_coverage``) are retained. 
Last, insertions and deletions are excluded from this analysis as well, because their genotyping is oftentimes more complicated and they are *not* indispensable to genotype the background of the hotspots.

**2. Genotyping SNPs**
For the reamining SNPs, the genotyping is straightforward:

* if the genotype assignment in the VCF is 0/1, the genotype of the SNP is PG1/PG2;
* if the genotype assignment in the VCF is 1/1, the genotype of the SNP is PG2/PG2.


**3. Genotyping the background of the hotspot**
If a minimum percentage of SNPs of the hotspot (90% by default, modifiable with argument ``-p`` or ``--perc_genot``) have all been assigned the same genotype, the background of the hotspot will be assigned this same genotype.



Usage
-----

```
Usage: python ./genotype_hotspot.py [--help] [-l OUTPUT_LIST_SNP_ORIGINS] -v VCF_FILE -o OUTPUT_HOTSPOT_GENOTYPES -f FILTER_COVERAGE -p PERCENTAGE_GENOTYPES -n HOTSPOT_NAME -s SAMPLES --PG1 PG1 --PG2 PG2 --PG2_main PG2_MAIN --PG2_introgressed PG2_INTROGRESSED
  Options:
   -h, --help
             Print help
   -l, --output_origin_SNPs OUTPUT_LIST_SNP_ORIGINS
             Path to the (optional) output_file of SNP origins
  Parameters:
   -i, --vcf_file VCF_FILE
             Path to the input VCF corresponding to the hotspot analysed
   -o, --output_file_genotypes_hotspots OUTPUT_HOTSPOT_GENOTYPES
             Path to the output_file of hotspot genotypes
   -f, --filter_coverage FILTER_COVERAGE
             The minimum read depth for a SNP to be retained
   -p, --perc_genot PERCENTAGE_GENOTYPES
             The minimum percentage of SNPs in one hotspot that
             should have the same genotype to infer that of the hotspot
   -n, --name_hotspot HOTSPOT_NAME
             Name of the hotspot
   -s, --samples SAMPLES
             Names of all samples (separated by comas)
   --PG1 PG1 Name of parental genome 1 (no introgression)
   --PG1 PG2 Name of parental genome 2 (global name)
   --PG2_main PG2_MAIN
             Name of genome receiver in parental genome 2
   --PG2_introgressed PG2_INTROGRESSED
             Name of genome introgressed into parental genome 2
```


Requirements
------------

* Python 2.7.13


