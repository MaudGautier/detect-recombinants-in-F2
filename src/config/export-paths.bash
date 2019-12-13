#!/usr/bin/env bash


# Aliases for java tools
PICARD=/beegfs/home/gautier/4_Tools/picard-tools-1.98/
GATK=/beegfs/data/gautier/3_Working_directory/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/


# Paths for tools installed in my personal space
TOOLS=/beegfs/home/gautier/4_Tools
export PATH=$TOOLS/htslib/bin:$PATH
export PATH=$TOOLS/meme/bin:$PATH
export PATH=$TOOLS/bedtools2/bin:$PATH
export PATH=$TOOLS/bin:$PATH


# Paths for tools installed on the LBBE cluster
export PATH=/beegfs/data/soft/samtools-1.9/bin:$PATH
export PATH=/beegfs/data/soft/R-3.5.2/bin/:$PATH


# Necessary for tool sam2tsv to work properly (LBBE cluster installation of java)
export PATH=/usr/local/jre1.8.0_202/bin:$PATH
export JAVA_HOME=/usr/local/jre1.8.0_202


