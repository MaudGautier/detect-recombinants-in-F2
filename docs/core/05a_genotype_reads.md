README for ``05a_genotype_reads.bash``
======================================

Description
-----------

This script genotypes all reads by creating a TSV file, reannotating alignments on the TSV (so that they are recorded in a format constistent with those of VCF files), reducing the TSV to the sole variants reported in the VCF file and genotyping each variant of each read sequenced by comparing the reference (REF) and alternate (ALT) alleles of a given variant (given by the VCF file) with the nucleotide sequenced (BASE) and the nuclotide on which it is aligned (REF) of each read (given by the TSV file).
Additionally, because TSV files are extremely large (see [the memory requirements section of the README](https://github.com/MaudGautier/detect-recombinants-in-F1#memory-requirements)), this script begins with the reduction of the input BAM file to a smaller subset (defined by an input BED file), and the name of the targeted subset is added in the output file containing the genotyped reads.

The output file is in the following format:
```
#CHROM  POS		  REF_VCF  ALT_VCF  READ_ID                                  FLAG  BASE_TSV  REF_TSV  MUT_TYPE  QUAL  FILTER_VCF  NB_VCF  FREQ_VCF  TARGET                                        GENOTYPE
chr1    3882053	  A        G        D00350:383:H3FCCBCX2:1:2208:20909:16630  163   G         A        SNP       28    PASS        35      0.371429  Control.chr1_3881920_3882919/3880920/3883919  CAST
chr1    6690792	  A        G        D00350:383:H3FCCBCX2:1:1105:16837:18805  99    A         A        SNP       27    PASS        128     0.398438  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1    6690788	  CA       C        D00350:383:H3FCCBCX2:1:1105:16837:18805  99    C         C        DEL       26    PASS        120     0.416667  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1    6690791	  C        CT       D00350:383:H3FCCBCX2:1:1105:16837:18805  99    C         C        INS       27    PASS        128     0.398438  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1	6691168	  GTATGC   G		D00350:383:H3FCCBCX2:1:1101:13116:17366  163   G		 GTATGC	  DEL		29	  PASS		  475	  0.524211  Control.chr1_6690920_6691919/6689920/6692919  CAST
chr1	6691501	  G		   GTCCC	D00350:383:H3FCCBCX2:1:1101:13871:34877  99    GTCCC	 G		  INS		21	  PASS		  661	  0.481089  Control.chr1_6690920_6691919/6689920/6692919  CAST
```


Helpful notes
-------------

On TSV files, alignments are reported vertically, i.e. one line corresponds to one nucleotide sequenced. For further information about this file format, refer to [the ``sam2tsv`` tool documentation page](http://lindenb.github.io/jvarkit/Sam2Tsv.html).

The output file contains information on which filters will be set in the ``05b_extract_recombinants.bash`` script. In particular, the filters on the quality score of variants are reported in the ``QUAL`` column. As such, performing this process on a BAM file for which base quality scores have been recalibrated with the BQRS step of GATK will allow to filter on more accurate base quality scores. I thus recommended to use the ``recal_reads.bam`` as the input BAM file for this script.


Usage
-----

```
Usage: bash ./05a_genotype_reads.bash [-s SUBMISSION_FILE] -c CONFIG -o OUTPUT_PREFIX -t TMP_PREFIX -i INPUT_BAM -f FREQ_VCF_FILE -b BED_FILE -g GENOME_FASTA -r REF_GENOME_NAME -a ALT_GENOME_NAME 
  Options:
   -s, --sub SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -o, --output_prefix OUTPUT_PREFIX
             Prefix of the output file (without the file extension)
   -t, --tmp_prefix TMP_PREFIX
             Prefix of the temporary files (without the extension)
   -i, --input_bam INPUT_BAM
             Input BAM file (mapped on the same reference genome as that given
             in parameter -g)
   -f, --freq_vcf_file FREQ_VCF_FILE
             File containing the frequencies of variant alleles (obtained 
             by running the src/utils/prepare_freq_vcf_file.bash script on
             a VCF file)
   -g, --genome GENOME_FASTA
             FASTA file of the genome to map onto. The FASTA file must have 
             been indexed beforehand with bwa index
   -b, --bed_file BED_FILE
             BED file containing a list of intervals
   -r, --ref_name REF_GENOME_NAME
             Name of the genome used as a reference
   -a, --alt_name ALT_GENOME_NAME
             Name of the genome used as an alternative
```


Requirements
------------

* java 1.8
* sam2tsv
* Bedtools v2.26.0
* Samtools 1.9
* GNU Awk 4.2.1
* GNU bash 4.4
* GNU coreutils 8.30

