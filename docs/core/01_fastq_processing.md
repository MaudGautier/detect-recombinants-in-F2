README for ``01_fastq_processing.bash``
=======================================

Description
-----------

This script removes a given adapter from paired-end FASTQ files using the ``cutadapt`` tool and performs the quality check process using ``fastqc``.


Usage
-----

```
Usage: bash ./01_fastq_processing.bash [-s SUBMISSION_FILE] -c CONFIG -i PREFIX_INPUT_FASTQ -o PREFIX_OUTPUT_FASTQ -d FASTQC_DIRECTORY -a ADAPTER 
  Options:
   -s, --sub SUBMISSION_FILE
             Path to the submission file
  Parameters:
   -c, --config, --source CONFIG
             Path to the configuration file
   -i, --fastq_with_adapter_prefix PREFIX_INPUT_FASTQ
             Prefix of the input FASTQ file, without including the read1 or 
             read2 label. Input files must be compressed (using gzip). The 
             extension for read1 files must be `-R1.fastq.gz`. The extension 
             for read2 files must be `-R2.fastq.gz`
   -o, --fastq_no_adapter_prefix PREFIX_OUTPUT_FASTQ
             Prefix of the output FASTQ file (without the adapter), without 
             including the read1 or read2 label
   -d, --fastqc_dir FASTQC_DIRECTORY
             Path to the output directory that will contain the fastq check 
             outputs
   -a, --adapter ADAPTER
             Sequence of the adapter to remove
```


Requirements
------------

* cutadapt 1.15
* FastQC v0.11.5
* Python 2.7.13

