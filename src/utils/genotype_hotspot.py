#!/usr/bin/env python
# -*- coding: utf-8 -*-


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              IMPORTATIONS                             ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

from __future__ import division
import argparse
import sys


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                               FUNCTIONS                               ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

def create_parser():
    """ Creates the parser for arguments. 
    """
    parser = argparse.ArgumentParser(description='Creates a BGC table \
            according to the requirements asked in the input parameters.')
    
    # Required arguments
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('-v', '--vcf_file', dest='vcf_file', 
            metavar='vcf_file', type=str, required=True,
            help="""The path to the vcf file for one hotspot.""")
    requiredNamed.add_argument('-o', '--output_file_genotypes_hotspots', 
            dest='output_file_genotypes_hotspots', 
            metavar='output_file_genotypes_hotspots', type=str, required=True,
            help="""The path to the output_file of hotspot genotypes.""")
    requiredNamed.add_argument('-l', '--output_origin_SNPs', default="NA",
            dest='output_origin_SNPs', metavar='output_origin_SNPs', type=str,
            help="""The path to the (optional) output_file of SNP origins.""")
    requiredNamed.add_argument('-f', '--filter_coverage', required=True,
            dest='filter_coverage', metavar='filter_coverage', type=float,
            help="""The minimum read depth for a SNP to be retained.""")
    requiredNamed.add_argument('-p', '--perc_genot', default = 0.90,
            dest='perc_genot', metavar='perc_genot', type=float,
            help="""The minimum percentage of SNPs in one hotspot that 
            should have the same genotype to infer that of the hotspot.""")
    requiredNamed.add_argument('-n', '--name_hotspot', dest='name_hotspot',
            metavar='name_hotspot', type=str, required=True,
            help="""Name of the hotspot.""")
    requiredNamed.add_argument('-s', '--samples', dest='samples',
            metavar='samples', type=str, required=True,
            help="""The names of all samples (separated by comas).""") 
    requiredNamed.add_argument('--PG1', dest='PG1', 
            metavar='PG1', type=str, required=True,
            help="""Name of parental genome 1 (no introgression).""")
    requiredNamed.add_argument('--PG2', dest='PG2', 
            metavar='PG2', type=str, required=True,
            help="""Name of parental genome 2 (global name).""")
    requiredNamed.add_argument('--PG2_main', dest='PG2_main', 
            metavar='PG2_main', type=str, required=True,
            help="""Name of genome receiver in parental genome 2.""")
    requiredNamed.add_argument('--PG2_introgressed', dest='PG2_introgressed', 
            metavar='PG2_introgressed', type=str, required=True,
            help="""Name of genome introgressed into parental genome 2.""")
   
    return parser.parse_args()



def increment_dict_counts(dict_counts, VCF_info, filt_cov = 500):
    """ Increments dictionary of counts (dict_counts) if read coverage is 
    greater than filt_cov.
    
    Arguments:
    - dict_counts: Dictionary of counts.
    - VCF_info   : Information related to the genotype on the VCF.
    - filt_cov   : Minimum read coverage to retain SNP.
    """
    VCF_fields = VCF_info.split(":")
    coverages = VCF_fields[1].split(",")
    if int(coverages[0]) + int(coverages[1]) >= filt_cov:
        dict_counts[VCF_fields[0]] += 1



def genotype_hotspot(dict_PG1_PG2, dict_MAIN_INTRO, PG1, PG2, min_perc_genot = 0.90):
    """ Returns the inferred genotype of the hotspot. The inferrence is based 
    on counts of genotypes in dict_PG1_PG2 and dict_MAIN_INTRO.

    Arguments:
    - dict_PG1_PG2   : Dictionary of counts of genotypes for SNP whose alleles
                       differ between PG1 and PG2.
    - dict_MAIN_INTRO: Dictionary of counts of genotypes for SNP whose alleles
                       differ between PG2_main and PG2_intro.
    - min_perc_genot : Minimum percentage of SNPs with a given genotype to 
                       assign that genotype to the hotspot.
    - PG1            : Name of PG1.
    - PG2            : Name of PG2.
    """

    nb_SNPs = dict_PG1_PG2["0/0"] + dict_PG1_PG2["0/1"] + dict_PG1_PG2["1/1"]

    if nb_SNPs ==0:
        return "NOCOV"
    if dict_PG1_PG2["0/1"]/nb_SNPs >= min_perc_genot:
        return "HET"
    if dict_PG1_PG2["1/1"]/nb_SNPs >= min_perc_genot:
        return str(PG2)
    return "NA"
   


def detect_0_0_genotype(list_VCF_genot):
    """ Returns True if at least one sample has VCF_genot == 0/0.

    Arguments:
    - list_VCF_genot: list of genotypes from VCF file.
    """

    for genot in list_VCF_genot:
        if genot == "0/0":
            return True
    return False



def init_dict_counts(max_nb_alleles = 10):
    """ Initialise dictionary of VCF_genotype counts.
    
    Arguments:
    - max_nb_alleles: Maximum number of alleles found by GATK.

    Outputs:
    - dict_genots   : Dictionary of VCF_genotype counts.     
    """

    dict_genots = {}
    dict_genots["./."] = 0
    for allele_nb1 in xrange(0,max_nb_alleles + 1):
        for allele_nb2 in xrange(allele_nb1,max_nb_alleles + 1):
            dict_genots[str(allele_nb1) + "/" + str(allele_nb2)] = 0
    
    return dict_genots




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              MAIN SCRIPT                              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

## PROCEDURE FOLLOWED IN THIS SCRIPT:
# 1. Objective = select SNPs for which allele_PG2_MAIN == allele_PG2_INTRO
#    --> For each SNP: 
#        if at least 1 sample has VCF_genotype = 0/0 => exclude it
# 2. Objective = genotype remaining SNPs
#    --> if VCF_genotype = 0/1 => genotype = PG1/PG2
#    --> if VCF_genotype = 1/1 => genotype = PG2/PG2
# 3. Objective = genotype hotspot
#    --> if majority of SNPs have genotype = PG1/PG2 => hotspot_genot = HET
#    --> if majority of SNPs have genotype = PG2/PG2 => hotspot_genot = PG2


if __name__ == '__main__':
    
    # 0.   Get arguments
    args = create_parser()
    
    # 0.a. Files
    vcf_file = args.vcf_file
    output_origin_SNPs = args.output_origin_SNPs
    output_file_genotypes_hotspots = args.output_file_genotypes_hotspots
    
    # 0.b. Parameters
    sep = "\t"
    filter_coverage = args.filter_coverage
    hotspot_name = args.name_hotspot
    samples = args.samples.split(",")
    PG1 = args.PG1
    PG2 = args.PG2
    PG2_main = args.PG2_main
    PG2_intro = args.PG2_introgressed
    min_perc_genot = args.perc_genot

    # 1. Count SNPs genotyped PG1/PG2 and PG2_main/PG2_intro
    # 1.a. Initialise dictionaries of counts
    sample_dict_PG1_PG2 = {}
    sample_dict_MAIN_INTRO = {}
    for sample in samples:
        sample_dict_PG1_PG2[sample] = init_dict_counts()
        sample_dict_MAIN_INTRO[sample] = init_dict_counts()

    # 1.b. Select SNPs for which allele_PG2_main == allele_PG2_intro
    with open(vcf_file, 'r') as filin:
        
        for line in filin:
            
            # Get all genotypes reported on VCF and their associated info
            fields = line[:-1].split(sep)
            VCF_fields={}
            VCF_genotype={}
            for key,sample in enumerate(samples):
                VCF_fields[sample]=fields[9 + key]
                VCF_genotype[sample]=fields[9 + key].split(":")[0]
            
            # Decide if marker must be excluded (i.e. 0/0 in one sample)
            exclude_marker = detect_0_0_genotype(list(VCF_genotype.values()))
            
            # Write output list of origins (Optional)
            if output_origin_SNPs != "NA":
                with open(output_origin_SNPs, 'a') as filout_output_origin_SNPs:
                    if exclude_marker:
                        marker_origin = str(PG2_main) + "/" + str(PG2_intro)
                    else:
                        marker_origin = str(PG2) + "/" + str(PG1)
                    filout_output_origin_SNPs.write(hotspot_name + \
                            fields[0] + sep + fields[1] + sep + fields[3] + sep + \
                            fields[4] + sep + marker_origin + "\n")

            # 2. Genotype remaining SNPs
            # Exclude insertions and deletions 
            if len(fields[3]) > 1 or len(fields[4]) > 1:
                continue
            
            # Count nb of SNPs of each genotype
            if exclude_marker:
                for sample in samples:
                    increment_dict_counts(sample_dict_MAIN_INTRO[sample], 
                            VCF_fields[sample], filter_coverage)
            else:
                for sample in samples:
                    increment_dict_counts(sample_dict_PG1_PG2[sample],
                            VCF_fields[sample], filter_coverage)

    # 3. Genotype hotspot
    hotspot_genot = {}
    for sample in samples:
        hotspot_genot[sample] = genotype_hotspot(sample_dict_PG1_PG2[sample], sample_dict_MAIN_INTRO[sample], PG1, PG2, min_perc_genot = min_perc_genot)

    # Write output list of hotspot genotypes
    with open(output_file_genotypes_hotspots, 'a') as filout:
        lineout = hotspot_name + "\t"
        sep_fields="-"
        for sample in samples:
            lineout += hotspot_genot[sample] + sep_fields
        lineout = lineout[:-1] + "\n"
        filout.write(lineout)

