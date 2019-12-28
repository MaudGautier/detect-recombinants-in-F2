
Description
===========

Table of contents
=================

* [Description](#description)
* [Table of contents](#table-of-contents)
* [Installation](#installation)
	* [Dependencies](#dependencies)
	* [Clone the repository](#clone-the-repository)
* [Layout of the repository](#layout-of-the-repository)
* [Usage](#usage)
* [Important notes](#important-notes)
	* [Memory requirements](#memory-requirements)
* [Credits](#credits)
* [Licence](#licence)
* [Future work](#future-work)


Installation
============

Dependencies
------------

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


Clone the repository
--------------------

To clone the repository, use this command line:

```
git clone git@github.com:MaudGautier/detect-recombinants-in-F1.git
```



Layout of the repository
========================



Usage
=====

The ``config`` folder contains scripts allowing to perform the detection of recombinants.

``export-paths.bash`` gives the path to the dependencies using the LBBE cluster and the tools I installed in my personal space. 
If the path exportation to the dependencies have not already been provided in your ``~/.bash_profile`` or ``~/.profile`` file, indicate your own paths in this file and source this file (command: ```source src/config/export-paths.bash```) prior to launching any other configuration file.



Important notes
===============

Memory requirements
-------------------

The genotyping step requires the creation of temporary ``.tsv`` files (from the [sam2tsv](http://lindenb.github.io/jvarkit/Sam2Tsv.html) tool of the [jvarkit](http://lindenb.github.io/jvarkit/) utility). 

To get a rough estimate of the size of these files, I computed the ``.tsv`` file associated to a ``.bam`` file containing 15,000,000 reads of 250 bp long for a total of 1.4 GB (``.sam`` file: 9.6 GB), the size of the corresponding ``.tsv`` file was 280 GB, i.e. 200 times as big as the ``.bam`` file. 
Results were similar for a 103-MB ``.bam`` file and a 344-MB ``.bam`` file containing 100-bp long reads: the sizes of the corresponding ``.tsv`` files were 22 GB and 87 GB respectively, i.e. 215 and 250 times bigger than the ``.bam`` files.
 
Therefore, as a rough estimate, you would need to ensure that you have a space disk 250 times as big as the size of the ``.bam`` files.
Alternatively in case the space disk is not sufficient, you can subdivide the ``.bam`` file and run the process on chunks successively.


Adaptation to other settings
----------------------------

Originally, this workflow has been implemented to detect recombination events among 250-bp illumina paired-end reads from fragments of 350 bp on average, captured in 1-kb long regions displaying an average of 1 SNP every 150 bp (i.e. a 0.8% divergence) and corresponding to recombination hotspots of a F1 cross between two mouse strains (C57BL/6J hereafter called B6 and CAST/EiJ hereafter called CAST) that present a genome-wide recombination rate of 0.5 cM/Mb. 

Nonetheless, the pipeline is coded in a way that should allow its use for other designs, provided that the values of the parameters are modified. 
In particular, the appropriate values for the parameters that matter in steps 2 and 4 (extraction of recombinants by filtering on read depth, allele frequency, base quality score and minimum number of genotyped variants per genome) depend on the sequencing parameters (read length, sequencing error rate, fragment size, …), the variant density in the targeted regions	and the recombination rate of the F1 studied.

In addition, the workflow in this repository is adapted to F1 individuals, i.e. individuals for which all targeted regions are in a heterozygous background.
Note that this approach was adapted to another setting with F2 individuals for which some of the targeted regions are *not* in a heterozygous background by adding a step consisting in genotyping the genetic background of each region to focus on heterozygous backgrounds exclusively. This implementation is provided in the ``detect-recombinants-in-F2`` repository available [here](https://github.com/MaudGautier/detect-recombinants-in-F2).


Licence
=======


Future work
===========

* Improve the memore requirement limitations by avoiding generating a temporary ``.tsv`` file. Instead, process the ``.bam`` file directly, ideally using Java, given the size of the files to be processed.






