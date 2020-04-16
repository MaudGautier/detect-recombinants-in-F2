# README for ``detect-recombinants-in-F2`` repository

* [Description](#description)
	 * [Specificities of F2 individuals](#specificities-of-F2-individuals)
	 * [Overview](#overview)
* [Installation](#installation)
	 * [Dependencies](#dependencies)
	 * [Clone the repository](#clone-the-repository)
* [Layout of the repository](#layout-of-the-repository)
* [Usage](#usage)
* [Important notes](#important-notes)
	 * [Memory requirements](#memory-requirements)


## Description

The ``detect-recombinants-in-F2`` workflow is a bioinformatic pipeline allowing to detect recombination events from the targeted sequencing of recombination hotspots in single individuals of a F2 cross.

This workflow is designed in a similar fashion as [that to detect recombination events in single individuals of F1 crosses](https://github.com/MaudGautier/detect-recombinants-in-F1), but required adaptations that are described hereunder.


## Specificities for F2 individuals

F2 individuals arise from the cross between two parents, one of which consisting of 100% of parental genome 1 (CAST) and the other being majoritarily made of parental genome 2 (B6) with a (small) fraction of an introgressed genome (DBA2).

Since the reference genomes are known for B6 and CAST but not for DBA2 (and thus, that reads were mapped on both the B6 and CAST but not on the DBA2 genome), it is necessary to create an approach to genotype hotspots.
Otherwise, markers that come from the introgressed genome (DBA2) will be mistakenly genotyped as the alternative genome ([when genotyping reads](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/master/docs/core/05a_genotype_reads.md)), no matter if the reads are mapped on the CAST or on the B6 genome. This will lead to errors in the genotyping of reads and thus, to many false positives when calling recombinants.

To avoid these errors, our approach consisted in identifying the genetic background of all hotspots prior to genotyping reads.
The practical implementation of hotspot genotyping is fully described in [this document](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/adapt-F1-to-F2/docs/utils/genotype_hotspot.md)

The genotype of hotspots is then used to 1) focus exclusively on hotspots that are heteroygous for the sample and 2) select variants that correspond to DOM/CAST variants (excluding the B6/DBA2 variants which are irrelevant for the identification of recombination events in the F2 cross between DOM and CAST).





### Overview

All in all thus, the workflow includes all of these steps:

1. Process `FASTQ` files to remove sequencing adapters ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/master/docs/core/01_fastq_processing.md)) <br/>
2. Map reads to the two reference genomes ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/master/docs/core/02_mapping.md)) <br/>
3. Joint variant-calling <br/>
3.a. Identify variants in all samples ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/master/docs/core/03a_variant_calling.md)) <br/>
3.b. Merge variant-calling information from all samples and perform variant quality score recalibration ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/master/docs/core/03b_variant_calling.md)) <br/>
4. Genotype hotspots ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/adapt-F1-to-F2/docs/core/04a_genotype_hotspots.md)) <br/>
5. Genotype reads ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/adapt-F1-to-F2/docs/core/05a_genotype_reads.md)) and extract recombination events ([implementation detailed here](https://github.com/MaudGautier/detect-recombinants-in-F2/blob/adapt-F1-to-F2/docs/core/05b_extract_recombinants.md)) <br/>



## Installation

### Dependencies

Hereunder is the list of dependencies that are necessary for this workflow to function as it is:

* BWA 0.7.17
* Bedtools v2.26.0
* Cutadapt 1.15
* FastQC v0.11.5
* GATK 3.8
* GNU awk 4.2.1
* GNU bash 4.4
* GNU coreutils 8.30
* GNU grep 3.1
* Java 1.8
* PicardTools 1.98
* Python 2.7.13
* Sam2tsv 91b443a14fe47871dc35efdf58c38729fec9d5a9
* Samtools 1.9


### Clone the repository

To clone the repository, use this command line:

```
git clone https://github.com/MaudGautier/detect-recombinants-in-F2.git
```



## Layout of the repository

```
.
├── LICENSE
├── README.md
├── TODO.md
├── docs
│   ├── core
│   │   ├── 01_fastq_processing.md
│   │   ├── 02_mapping.md
│   │   ├── 03a_variant_calling.md
│   │   ├── 03b_variant_calling.md
│   │   ├── 04a_genotype_reads.md
│   │   └── 04b_extract_recombinants.md
│   └── utils
│       ├── filter_genotypes.md
│       ├── genotype_variants.md
│       ├── modify_weight_of_overlaps.md
│       ├── parallel_sort.md
│       ├── prepare_freq_vcf_file.md
│       ├── prepare_paired_bed.md
│       ├── reannotate_INDELs_in_tsv.md
│       └── reconstitute_fragments.md
└── src
    ├── config
    │   ├── 01_fastq_processing.config
    │   ├── 02_mapping.config
    │   ├── 03a_variant_calling.config
    │   ├── 03b_variant_calling.config
    │   ├── 04a_genotype_reads.config
    │   ├── 04b_extract_recombinants.config
    │   ├── 04c_pass_second_genome.config
    │   ├── example-project-F2.config
    │   ├── export-paths.config
    │   └── slurm
    │       ├── 01_fastq_processing.config
    │       ├── 02_mapping.config
    │       ├── 03a_variant_calling.config
    │       ├── 03b_variant_calling.config
    │       ├── 04a_genotype_reads.config
    │       ├── 04b_extract_recombinants.config
    │       └── 04c_pass_second_genome.config
    ├── core
    │   ├── 01_fastq_processing.bash
    │   ├── 02_mapping.bash
    │   ├── 03a_variant_calling.bash
    │   ├── 03b_variant_calling.bash
    │   ├── 04a_genotype_reads.bash
    │   └── 04b_extract_recombinants.bash
    └── utils
        ├── filter_genotypes.awk
        ├── genotype_variants.awk
        ├── modify_weight_of_overlaps.py
        ├── parallel_sort.bash
        ├── prepare_freq_vcf_file.bash
        ├── prepare_paired_bed.bash
        ├── reannotate_INDELs_in_tsv.awk
        └── reconstitute_fragments.awk
```

## Usage

The [``src/config`` folder](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/config) contains scripts allowing to run the detection of recombinants.

``src/config/export-paths.config`` gives the path to the dependencies using the LBBE cluster and the tools I installed in my personal space. 
If the path exportation to the dependencies have not already been provided in your ``~/.bash_profile`` or ``~/.profile`` file, indicate your own paths in this file and source this file (command: ``source src/config/export-paths.config``) prior to launching any other configuration file.

``src/config/example-project-F2.config`` is the configuration file of a given project. This file must be adapted to each new project and sourced before running any part of the workflow.

The config files located in the [``src/config`` directory](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/config) can then be run directly after adapting the parameters to your project.
If you want to run these processes on a SLURM cluster, you can use the configuration files located in the [``src/config/slurm`` directory](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/config/slurm).


Once a configuration file ``src/config/file.config`` is configured, it can be run using this command line:
```bash
bash src/config/file.config
```
or copy-psting its content directly in the terminal.

For instance, to run the FASTQ processing step, use this command line:
```bash
bash src/config/01_fastq_processing.config
```



## Important notes

### Memory requirements

The genotyping step requires the creation of temporary ``.tsv`` files (from the [sam2tsv](http://lindenb.github.io/jvarkit/Sam2Tsv.html) tool of the [jvarkit](http://lindenb.github.io/jvarkit/) utility). 

To get a rough estimate of the size of these files, I computed the ``.tsv`` file associated to a ``.bam`` file containing 15,000,000 reads of 250 bp long for a total of 1.4 GB (``.sam`` file: 9.6 GB), the size of the corresponding ``.tsv`` file was 280 GB, i.e. 200 times as big as the ``.bam`` file. 
Results were similar for a 103-MB ``.bam`` file and a 344-MB ``.bam`` file containing 100-bp long reads: the sizes of the corresponding ``.tsv`` files were 22 GB and 87 GB respectively, i.e. 215 and 250 times bigger than the ``.bam`` files.
 
Therefore, as a rough estimate, you would need to ensure that you have a space disk 250 times as big as the size of the ``.bam`` files.
Alternatively in case the space disk is not sufficient, you can subdivide the ``.bam`` file and run the process on chunks successively.


