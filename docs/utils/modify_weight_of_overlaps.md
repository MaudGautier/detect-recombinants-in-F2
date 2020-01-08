README for ``modify_weight_of_overlaps.py``
===========================================

Description
-----------

This script modifies the weights of variants sequenced twice (once in each read of a given fragments).
If there is an overlap, the weight is no longer 1 but 1.01.


Usage
-----

```
Usage: python ./modify_weight_of_overlaps.py [--skip_header] [--help] -i INPUT_FILE -o OUTPUT_FILE -r REF_GENOME_NAME -a ALT_GENOME_NAME
  Options:
   -s, --skip_header
             Skip header (i.e. do not read the first line) when this option is turned on
   -h, --help
             Print help
  Parameters:
   -i, --input INPUT_FILE
             Path to the input file containing the list of fragments
   -o, --output OUTPUT_FILE
             Path to the output file containing the list of fragments with 
             modified weights
   -r, --ref_name REF_GENOME_NAME
             Name of the genome used as a reference
   -a, --alt_name ALT_GENOME_NAME
             Name of the genome used as an alternative
```


Requirements
------------

* Python 2.7.13


