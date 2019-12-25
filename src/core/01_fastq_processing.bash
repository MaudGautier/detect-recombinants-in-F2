#!/usr/bin/env bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              PARAMETERS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
		-c|--config|--source)
			config_file="$2"
			shift
			;;
		-i|--fastq_with_adapter_prefix)
			fastq_with_adapter_prefix="$2"
			shift
			;;
		-o|--fastq_no_adapter_prefix)
			fastq_no_adapter_prefix="$2"
			shift
			;;
		-d|--fastqc_dir)
			fastqc_dir="$2"
			shift
			;;
		-a|--adapter)
			adapter="$2"
			shift
			;;
		-s|--sub)
			sub_file="$2"
			shift
			;;
        *)
            # unknown option
            ;;
    esac
    shift # past argument or value
done

echo CONFIG FILE	 = "${config_file}"
echo FASTQ WITH ADAPT= "${fastq_with_adapter_prefix}"
echo FASTQ NO ADAPT  = "${fastq_no_adapter_prefix}"
echo FASTQC DIRECTORY= "${fastqc_dir}"
echo ADAPTER         = "${adapter}"
echo SUBMISSION FILE = "${sub_file}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                                SOURCE                                 ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

source $config_file


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                            REMOVE ADAPTER                             ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

cutadapt -a ${adapter} \
		-A ${adapter} \
		--minimum-length 50 \
		-o ${fastq_no_adapter_prefix}'-R1.no_adapter.fastq.gz' \
		-p ${fastq_no_adapter_prefix}'-R2.no_adapter.fastq.gz' \
		${fastq_with_adapter_prefix}'-R1.fastq.gz' \
		${fastq_with_adapter_prefix}'-R2.fastq.gz'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                         CHECK FASTQC QUALITY                          ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# For reads 1 (first paired-end file)
fastqc -o $fastqc_dir \
	${fastq_no_adapter_prefix}'-R1.no_adapter.fastq.gz'

# For reads 2 (second paired-end file)
fastqc -o $fastqc_dir \
	${fastq_no_adapter_prefix}'-R2.no_adapter.fastq.gz'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                        DELETE SUBMISSION FILE                         ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

if [ ! -z $sub_file ] ; then
	name="${fileID##*/}"
	if [ -s ${fastqc_dir}/$name}-R2.no_adapter_fastqc.html ] ; then
		rm -f $sub_file
	fi
fi


