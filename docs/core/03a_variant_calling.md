README for ``03a_variant_calling.bash``
=======================================

Description
-----------

This script prepares the input data for GATK (by fixing potential mate information error, marking duplicates and adding read group information), performs local realignment using the GATK tool suite, performs the base quality score recalibration (BQSR) step recommended by GATK and calls variant using GATK HaplotypeCaller to create genomic variant-calling files (gVCF).

Note that the preprocessing steps (in particular the read group information added) is designed for a sequencing obtained with an illumina platform.
Note that the list of known SNPs or known INDELs should be obtained from an external project. If they do not exist for the species studied, they can be obtained by a prior variant-calling bootstrapped several times (see specifications on the GATK forum for further info on that matter).


Usage
-----

```
Usage: bash ./03a_variant_calling.bash [-s SUBMISSION_FILE] -c CONFIG -i INPUT_BAM -o OUTPUT_PREFIX_VCF -s SAMPLE_NAME -g GENOME_FASTA -ks KNOWN_SNPS -ki KNOWN_INDELS
  Options:
   -s SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -i, --input_file INPUT_BAM
             Input BAM file (mapped on the same reference genome as that given 
             in parameter -g)
   -o, --output_prefix OUTPUT_PREFIX_VCF
             Prefix of the output VCF file (without the file extension)
   -s, --sample_name SAMPLE_NAME
             Name of the sample processed
   -g, --genome GENOME_FASTA
             FASTA file of the genome to map onto. The FASTA file must have 
             been indexed beforehand with bwa index
   -ks, --known_snps KNOWN_SNPS
             VCF file containing a list of known SNPs (obtained from external 
             projects) for GATK to build its machine learning models
   -ki, --known_indels KNOWN_INDELS
             VCF file containing a list of known INDELs (obtained from external 
             projects) for GATK to build its machine learning models
```


Requirements
------------

* samtools 1.9
* PicardTools 1.98
* GATK 3.8
* java 1.7


