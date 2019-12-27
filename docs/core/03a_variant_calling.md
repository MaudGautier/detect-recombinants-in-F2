README for ``03a_variant_calling.bash``
=======================================

Description
-----------

This script prepares the input data for GATK (by fixing potential mate information error, marking duplicates and adding read group information), performs local realignment using the GATK tool suite, performs the base quality score recalibration (BQSR) step recommended by GATK and calls variant using GATK HaplotypeCaller to create genomic variant-calling files (gVCF).


Helpful notes
-------------

The preprocessing steps (in particular the read group information added) are designed for a sequencing obtained with an illumina platform.

The way base quality score recalibration (BQSR) works is detailed in this [GATK documentation page](https://software.broadinstitute.org/gatk/documentation/article.php?id=44).

The list of known SNPs or known INDELs should be obtained from an external project. The resource bundle recommended by GATK for humans can be found [here](https://software.broadinstitute.org/gatk/download/bundle) and more information about resource bundles can be found [here](https://gatkforums.broadinstitute.org/gatk/discussion/11017/resource-bundle).

If they do not exist for the species studied, they can be obtained by a prior variant-calling bootstrapped several times (see specifications on the GATK documentation on the [Troubleshooting section of the BQSR documentation page](https://software.broadinstitute.org/gatk/documentation/article.php?id=44#Troubleshooting) for further information on that matter).
A discussion on the best resources for non-human species is given on [this page of the GATK forum](https://gatkforums.broadinstitute.org/gatk/discussion/1243).


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
* java 1.8


