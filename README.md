# README for ``detect-recombinants-in-F2`` repository

* [Description](#description)
	 * [Overview](#overview)
	 * [Preprocessing](#preprocessing)
	 * [Step 1: Genotyping reads mapped on the first parental genome (Genome 1)](#step-1-genotyping-reads-mapped-on-the-first-parental-genome-genome-1)
	 * [Step 2: Extract all potential recombinants (Genome 1)](#step-2-extract-all-potential-recombinants-genome-1)
	 * [Step 3: Genotyping reads mapped on the second parental genome (Genome 2)](#step-3-genotyping-reads-mapped-on-the-second-parental-genome-genome-2)
	 * [Step 4: Extract all definitive recombinants (Genome 2)](#step-4-extract-all-definitive-recombinants-genome-2)
	 * [Step 5 (optional): Re-write recombinants with coordinates from the first parental genome](#step-5-optional-re-write-recombinants-with-coordinates-from-the-first-parental-genome)
* [Installation](#installation)
	 * [Dependencies](#dependencies)
	 * [Clone the repository](#clone-the-repository)
* [Layout of the repository](#layout-of-the-repository)
* [Usage](#usage)
* [Important notes](#important-notes)
	 * [Memory requirements](#memory-requirements)
	 * [Adaptation to other settings](#adaptation-to-other-settings)
* [Future work](#future-work)


## Description

### Overview

The ``detect-recombinants-in-F1`` workflow is a bioinformatic pipeline allowing to detect recombination events from the targeted sequencing of recombination hotspots in single individuals of a F1 cross.

The identification of recombinants *per se* is subdivided into 4 main steps:
- Step 1: Genotyping all fragments mapped on the first parental genome (Genome 1)
- Step 2: Extracting all potential recombinants, based on results from Step 1 (Genome 1)
- Step 3: Genotyping all fragments mapped on the second parental genome (Genome 2)
- Step 4: Extracting all potential recombinants, based on results from Step 3 (Genome 2)
- (Optional) Step 5: Re-write recombinant records, using the coordinates from the first parental genome



### Preprocessing

The identification of recombinants is based on the genotyping of variants of each sequenced reads. As such, it depends on the identification of variants.

Therefore, prior to running the detection of recombinants, it is necessary to perform mapping and variant-calling.

FASTQ processing (consisting in removing adapters and performing quality check of reads), mapping on the two parental genomes, BAM processing (consisting in filtering out unproper fragments and focusing on regions of interest) and variant-calling (including preprocessing, INDEL local realignment, base quality score recalibration and variant quality score recalibration) are reported in the first four scripts of the [``src/core``](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/core) directory: ``01_fastq_processing.bash``, ``02_mapping.bash``, ``03a_variant_calling.bash`` and ``03b_variant_calling.bash``.
They can be called using the associated configuration files in the [``src/config``](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/config) or [``src/config/slurm``](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/src/config/slurm) directories.

More precise documentation on these processes can be found in the [``docs/core`` folder](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core) for [FASTQ processing](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/01_fastq_processing.md), [mapping](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/02_mapping.md) and the [first](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/03a_variant_calling.md) and [second](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/03b_variant_calling.md) parts of variant-calling.


### Step 1: Genotyping reads mapped on the first parental genome (Genome 1)

The first step consists in genotyping all reads previously mapped on the first parental genome (Genome 1).

Basically, the list of all variants reported in the variant-calling file (VCF) is intersected with all reads from the input BAM file.
Each corresponding variant from every read is then annotated as SNP, insertion or deletion. By comparing the allele of each of these variants with the alleles from the two parental genomes, a genotype is attributed to every variant of every read.
Additionnally, information concerning each variant is reported: the quality of the sequenced base, the VCF filter, the read coverage and the frequency of the reference allele. These can then be used for subsequent filtering.

More precise documentation on this process can be found [here](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/04a_genotype_reads.md).


### Step 2: Extract all potential recombinants (Genome 1)

Step 2 consists in extracting recombinant fragments from the list of genotyped reads obtained in Step 1.
Concretely, it is a filtering process: variants supported by either a too small read coverage, displaying an allelic frequency deviating too much from a 50:50 ratio, or having a base quality score too low are excluded.
After the two reads of each fragment are combined together, all the fragments displaying a strict minimum of 2 variants genotyped `Genome 1` and 2 variants genotyped `Genome 2` are marked as `potential recombinants`. 
Solely these fragments will be considered for the remaining steps.

More precise documentation on this process can be found [here](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/04b_extract_recombinants.md).


### Step 3: Genotyping reads mapped on the second parental genome (Genome 2)

Step 3 consists in re-genotyping all `potential recombinants` obtained after Step 2, using the other parental genome (Genome 2) as a reference.
The procedure is exactly identical to that of Step 1.


### Step 4: Extract all definitive recombinants (Genome 2)

Step 4 consists in extracting recombinant fragments from the list of genotyped reads obtained in Step 3 (i.e. based on the mapping on Genome 2).
The procedure is exactly identical to that of Step 2.


### Step 5 (optional): Re-write recombinants with coordinates from the first parental genome

After Step 4, the positions of recombinant fragments are reported in the genomic coordinates of Genome 2.
If necessary for further analyses, Step 5 allows to re-obtain the positions of these fragments in the genomic coordinates of Genome 1.

More precise documentation on this process can be found [here](https://github.com/MaudGautier/detect-recombinants-in-F1/tree/master/docs/core/04c_rewrite_recombinants.md).



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


