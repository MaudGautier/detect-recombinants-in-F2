README for ``03b_variant_calling.bash``
=======================================

Description
-----------

This script merges the gVCF records given as input and performs the variant quality score recalibration (VQSR) step recommended by GATK.


Helpful notes
-------------

The way variant quality score recalibration (VQSR) works is detailed in this [GATK documentation page](https://software.broadinstitute.org/gatk/documentation/article.php?id=39).

The list of true SNPs, untrue SNPs, true INDELs and untrue INDELs should be obtained from an external project. 
A recommendation on the kind of SNP and INDEL resources that should be used for this step as well as the annotations that should be selected to build the machine learning models can be found in [this guide](https://software.broadinstitute.org/gatk/documentation/article.php?id=1259).

It is important to note that the VQSR step may not work properly. Indeed, in this procedure, we selected target regions, which means that the total number of variants on which GATK can build its model is relatively small (this comes back to a set smaller than [exomes for which GATK recommends having a minimum of 30 samples to achieve a correct VQSR](https://software.broadinstitute.org/gatk/documentation/article.php?id=1259#important-notes-for-exome-capture-experiments)).
As such, we have two main possibilities: 
* either add the ``--maxGaussians 4`` parameter to make bigger clusters of variants, hopefully sufficiently big for GATK to build its model by passing statistical requirements;
* or, as stated [here](https://gatkforums.broadinstitute.org/gatk/discussion/6893/vqsr-for-single-sample-exome-targeted-regions), apply hard filters to a call set, as described [here](https://gatkforums.broadinstitute.org/gatk/discussion/2806/howto-apply-hard-filters-to-a-call-set).
In the case of this script, I chose the first option and, when errors came out during the VQSR step, stating that the number of variants was too little, I performed the rest of the analysis using the ``raw_variants.vcf`` file (i.e. the VCF obtained prior to the VQSR step), since improving the quality scores of variant calls was not absolutely critical for the aim of this project (identifying recombination events).


Usage
-----

```
Usage: bash ./03b_variant_calling.bash [-s SUBMISSION_FILE] -c CONFIG -o OUTPUT_PREFIX_VCF -l LIST_GVCF -g GENOME_FASTA -ts TRUE_SNPS -us UNTRUE_SNPS -ti TRUE_INDELS -ui UNTRUE_INDELS
  Options:
   -s, --sub SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -o, --output_prefix OUTPUT_PREFIX_VCF
             Prefix of the output VCF file (without the file extension)
   -l, --list_gvcf LIST_GVCF
             List of input gVCF files to merge into the final VCF; all gVCF 
             files must be separated by a coma without spacing
             e.g.: -l file1.g.vcf,file2.g.vcf,file3.g.vcf
   -g, --genome GENOME_FASTA
             FASTA file of the genome to map onto. The FASTA file must have 
             been indexed beforehand with bwa index
   -ts, --true_snps TRUE_SNPS
             VCF file containing a list of true SNPs (obtained from external 
             projects) for GATK to build its machine learning models
   -us, --untrue_snps UNTRUE_SNPS
             VCF file containing a list of untrue (i.e. unsure) SNPs (obtained 
             from external projects) for GATK to build its machine learning 
             models
   -ti, --true_indels TRUE_INDELS
             VCF file containing a list of true INDELs (obtained from external 
             projects) for GATK to build its machine learning models
   -ui, --untrue_indels UNTRUE_INDELS
             VCF file containing a list of untrue (i.e. unsure) INDELs 
             (obtained from external projects) for GATK to build its machine 
             learning models
```


Requirements
------------

* GATK 3.8
* java 1.8


