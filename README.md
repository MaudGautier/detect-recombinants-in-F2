
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


Credits
=======



Licence
=======


Future work
===========

* Improve the memore requirement limitations by avoiding generating a temporary ``.tsv`` file. Instead, process the ``.bam`` file directly, ideally using Java, given the size of the files to be processed.






