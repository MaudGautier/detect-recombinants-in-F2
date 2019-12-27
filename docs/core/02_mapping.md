README for ``02_mapping.bash``
==============================

Description
-----------

This script maps paired-end reads onto a reference genome, sorts and indexes the alignment, marks duplicates, filter reads to keep only the proper fragments and remove those that are unmapped or mapped as secondary (see SAMTools flag specifications) and subset the reads to those mapped on the regions reported in the BED file given as parameter.


Usage
-----

```
Usage: bash ./02_mapping.bash [-s SUBMISSION_FILE] [-t THREADS] -c CONFIG -f1 FASTQ_READ1 -f2 FASTQ_READ2 -o PREFIX_OUTPUT_BAM -g GENOME -b BEDFILE 
  Options:
   -s, --sub SUBMISSION_FILE
             File containing the settings to submit the job on a cluster
   -t, --threads THREADS
             Number of threads
  Parameters:
   -c, --config, --source CONFIG
             File containing the settings of the sample processed
   -f1, --fastq1 FASTQ_READ1
             One of the two FASTQ files (paired-end reads)
   -f2, --fastq2 FASTQ_READ2
             One of the two FASTQ files (paired-end reads)
   -o, --output_prefix PREFIX_OUTPUT_BAM
             Prefix of the output BAM file (without the file extension)
   -g, --genome GENOME_FASTA
             FASTA file of the genome to map onto. The FASTA file must have 
             been indexed beforehand with bwa index
   -b, --bedfile BEDFILE
             BED file containing a list of intervals
```


Requirements
------------

* bwa 0.7.17
* samtools 1.9
* PicardTools 1.98
* Bedtools v2.26.0



