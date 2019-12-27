#!/usr/bin/env bash

ORIGINAL_FILE=$1
SORTED_FILE=$2
COLUMN_SORT=$3
MAX_LINES_PER_CHUNK=$4
CHUNK_FILE_PREFIX=$ORIGINAL_FILE.lines_split.
SORTED_CHUNK_FILES=$CHUNK_FILE_PREFIX*.sorted

usage ()
{
	echo Parallel sort
	echo usage: psort file1 file2
	echo Sorts text file file1 and stores the output in file2
	echo Note: file1 will be split in chunks up to $MAX_LINES_PER_CHUNK lines
	echo  and each chunk will be sorted in parallel
}

# Test if we have two arguments on the command line
if [ $# != 3 ] && [ $# != 4 ]
then
	usage
	exit
fi

# Cleanup any lefover files
rm -f $SORTED_CHUNK_FILES > /dev/null
rm -f $CHUNK_FILE_PREFIX* > /dev/null
rm -f $SORTED_FILE

# Splitting $ORIGINAL_FILE into chunks ...
split -l $MAX_LINES_PER_CHUNK $ORIGINAL_FILE $CHUNK_FILE_PREFIX

for file in $CHUNK_FILE_PREFIX*
do
	sort -k$COLUMN_SORT,$COLUMN_SORT $file > $file.sorted #&
done
wait

# Merging chunks to $SORTED_FILE ...
sort -m -k$COLUMN_SORT,$COLUMN_SORT $SORTED_CHUNK_FILES > $SORTED_FILE

# Cleanup any lefover files
rm -f $SORTED_CHUNK_FILES > /dev/null
rm -f $CHUNK_FILE_PREFIX* > /dev/null
