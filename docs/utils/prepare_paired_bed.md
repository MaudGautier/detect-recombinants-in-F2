README for ``prepare_paired_bed.bash``
======================================

Description
-----------

This script creates paired BED files, i.e. BED files with one line per fragment instead of one line per read, by combining information from the two paired reads of each fragment.

Usage
-----

```
Usage: bash ./prepare_paired_bed.bash -i INPUT_BAM -o OUTPUT_BED
  Parameters:
   -i, --input_bam INPUT_BAM
             Input BAM file 
   -o, --output_bed OUTPUT_BED
             Output paired BED file
```


Requirements
------------

* Bedtools v2.26.0
* GNU Awk 4.2.1
* GNU coreutils 8.30


