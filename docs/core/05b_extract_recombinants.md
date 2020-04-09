README for ``05b_extract_recombinants.bash``
============================================

Description
-----------

This script extracts recombinants from an input file containing all genotyped nucleotides (reads x variants) in the following format:
```
#CHROM  POS		  REF_VCF  ALT_VCF  READ_ID                                  FLAG  BASE_TSV  REF_TSV  MUT_TYPE  QUAL  FILTER_VCF  NB_VCF  FREQ_VCF  TARGET                                        GENOTYPE
chr1    3882053	  A        G        D00350:383:H3FCCBCX2:1:2208:20909:16630  163   G         A        SNP       28    PASS        35      0.371429  Control.chr1_3881920_3882919/3880920/3883919  CAST
chr1    6690792	  A        G        D00350:383:H3FCCBCX2:1:1105:16837:18805  99    A         A        SNP       27    PASS        128     0.398438  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1    6690788	  CA       C        D00350:383:H3FCCBCX2:1:1105:16837:18805  99    C         C        DEL       26    PASS        120     0.416667  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1    6690791	  C        CT       D00350:383:H3FCCBCX2:1:1105:16837:18805  99    C         C        INS       27    PASS        128     0.398438  Control.chr1_6690920_6691919/6689920/6692919  B6
chr1	6691168	  GTATGC   G		D00350:383:H3FCCBCX2:1:1101:13116:17366  163   G		 GTATGC	  DEL		29	  PASS		  475	  0.524211  Control.chr1_6690920_6691919/6689920/6692919  CAST
chr1	6691501	  G		   GTCCC	D00350:383:H3FCCBCX2:1:1101:13871:34877  99    GTCCC	 G		  INS		21	  PASS		  661	  0.481089  Control.chr1_6690920_6691919/6689920/6692919  CAST
```

Recombinants are extracted by filtering out genotypes (i.e. reads x variants) that do not respect the filtering criteria in terms of sequencing depth supporting a variant, segregating frequency of its alleles and phred-score (i.e. quality) of the nucleotide sequenced.
Next, fragments are rewritten based on the remaining genotyped nucleotides (those that passed all filters) and, among those, recombinants are those that pass the additional filter of a minimum number of alleles of each parental genome carried by each fragment.

The output file is in the following format:
```
#READ_ID                                       NB_VARIANTS  NB_GENOT_REF  NB_GENOT_ALT  CHR   POS                      GENOTYPES  VARIANT_TYPES  QUALITIES  ALLELES  ALLELES_REF  ALLELES_ALT  NB_OVERLAP  VCF_FILTER      VCF_DEPTH    VCF_FREQ                   TARGET                                       NA    NA       NA
HISEQ-KERMIT:318:C9K39ANXX:8:1101:10304:70238  3            3             0             chr1  4542836;4543132;4543171  B6;B6;B6   SNP;SNP;SNP    31;29;32   C;T;C    C;T;C        A;A;G        1;1;1       PASS;PASS;PASS  926;672;550  0.506479;0.50744;0.523636  P9peak.chr1_4532254_4533494/4541260/4544259  chr1  4542802  4543187
```


Usage
-----

```
Usage: bash ./05b_extract_recombinants.bash [-s SUBMISSION_FILE] -c CONFIG -o OUTPUT_PREFIX -i INPUT_FILE -b PAIRED_BEDFILE -d FILT_DEPTH -f FILT_FREQ -q FILT_QUAL -a FILT_ALLELES -n FILT_NAME 
  Options:
   -s, --sub SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -o, --output_prefix OUTPUT_PREFIX
             Prefix of the output file (without the file extension)
   -i, --input_file INPUT_FILE
             Input file (must have been created thanks to the script 
             05a_genotype_reads.bash)
   -b, --bed_file PAIRED_BEDFILE
             Paired BED file containing the list of start and stop of each 
             fragment (not of reads). Must have been created with the script 
             prepare_paired_bed.bash
   -d, --depth FILT_DEPTH
             Minimum number of reads (i.e. sequencing depth) supporting a 
             variant for it not to be filtered out
   -f, --freq FILT_FREQ
             Frequency value set so that the variants that are not filtered out 
             have a frequency comprised between 1-FILT_FREQ and FILT_FREQ
   -q, --qual FILT_QUAL
             Minimum phred-score quality required for a genotyped nucleotide 
             not to be filtered out
   -a, --alleles FILT_ALLELES
             Minimum number of alleles of each parent that a given fragment 
             should carry to be marked as a recombinant
   -n, --name FILT_NAME
             Name of the filter (used as a suffix in the output files)
```


Requirements
------------

* GNU Awk 4.2.1
* GNU bash 4.4
* GNU coreutils 8.30
* Python 2.7.13

