README for ``04a_genotype_hotspots.bash``
=========================================

Description
-----------

This script genotypes all hotspots by inferring the background of origin of SNPs in each hotspot (see details in [the documentation of ``src/utils/genotype_hotspot.py``](https://github.com/MaudGautier/detect-recombinants-in-F1/blob/master/src/utils/genotype_hotspot.py) and in [the corresponding section of the README](https://github.com/MaudGautier/detect-recombinants-in-F2#genotyping-hotspots)).

This script works by genotyping each hotspot individually. Though, as a fraction of them cannot be genotyped with unambiguously, their genotype cannot be inferred. 
Optionnally, one can account for that by setting the option ``--refine`` to refine the genotype of these ambiguous hotspots based on the genotype of other hotspots in their surroundings. 
In that case, if at least ``n`` hotspots on its 3' side and ``n`` hotspots on its 5' side are genotyped unambiguously and with the same genotype, the ambiguous hotspot in the middle will be assigned this genotype as well.

The output file is in the following format:
```
#Hotspot    sample1-sample2-sample3-sample4
hotspot1    DOM-DOM-HET-HET
hotspot2    DOM-DOM-HET-HET
hotspot3    DOM-HET-HET-HET
hotspot4    DOM-HET-HET-HET
```


Usage
-----

```
Usage: bash ./04a_genotype_hotspots.bash [-s SUBMISSION_FILE] [--refined NB_HOTSPOTS] -c CONFIG -o OUTPUT_ORIGIN_SNPS -g OUTPUT_GENOTYPE_HOTSPOTS -t TMP_DIR -v VCF_FILE -b BED_FILE
  Options:
   -s, --sub SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
   --refined NB_HOTSPOTS
             Refinement will be performed with NB_HOTSPOTS on the 5' side and 
             NB_HOTSPOT on the 3' side of the ambiguous hotspots
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -o, --origin_snps OUTPUT_ORIGIN_SNPS
             Path to the output file containing the list of origins for all SNPs
   -g, --genotype_hotspots OUTPUT_GENOTYPE_HOTSPOTS
             Path to the output file containing the genotypes inferred for all 
             hotspots
   -t, --tmp_dir TMP_DIR
             Path to the temporary directory
   -v, --vcf_file VCF_FILE
             Path to the variant-calling file of the unambiguous parental genome
   -b, --bed_file BED_FILE
             BED file containing a list of intervals (coordinates of the 
             unambiguous parental genome)
```


Requirements
------------

* Python 2.7.13
* GNU Awk 4.2.1
* GNU bash 4.4
* GNU coreutils 8.30

