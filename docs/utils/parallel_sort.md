README for ``parallel_sort.bash``
=================================

Description
-----------

This script allows to parallelise the sorting of files by splitting them into subfiles with fewer lines.


Usage
-----

```
Usage: bash ./parallel_sort.bash INPUT_FILE SORTED_FILE COLUMN MAX_LINES_PER_CHUNK
  Parameters:
   INPUT_FILE
             Input file that needs to be sorted
   SORTED_FILE
             Output sorted file
   COLUMN    Column to sort
   MAX_LINES_PER_CHUNK
             Maximum number of lines in each subset file
```


Requirements
------------

* GNU coreutils 8.30


