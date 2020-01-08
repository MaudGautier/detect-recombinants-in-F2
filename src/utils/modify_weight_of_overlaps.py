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
    parser = argparse.ArgumentParser(description='Modifies weight of variants \
            sequenced twice (once for each read of a pair).')
    
    # Required arguments
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('-i', '--input', dest='input_file', 
            metavar='input_file', type=str, required=True,
            help="""The path to the input file containing the list of 
            fragments.""")
    requiredNamed.add_argument('-o', '--output', dest='output_file', 
            metavar='output_file', type=str, required=True,
            help="""The path to the output file containing the list of 
            fragments with modified weights.""")
    requiredNamed.add_argument('-r', '--ref_name', dest='ref_name', 
            metavar='ref_name', type=str, required=True,
            help="""Name of the genome used as a reference.""")
    requiredNamed.add_argument('-a', '--alt_name', dest='alt_name', 
            metavar='alt_name', type=str, required=True,
            help="""Name of the genome used as an alternative.""")

    # Optional arguments
    parser.add_argument('-s', '--skip_header', dest='skip_header', 
            action='store_true',
            help="""Whether or not the input file contains a header that must be
            skipped. Default: False (No header).""")
    
    return parser.parse_args()



def get_list_replacements_for_disconcordant_genotypes(positions_list, genotypes_list):
    """ For all positions that are the same (i.e. read twice by two overlapping
    fragments), check that the genotyping was the same. Else, keep in mind the
    indexes that are discordant.
    
    Inputs:
    - positions_list: The list of positions (int).
    - genotypes_list: The list of genotypes (string).

    Output:
    - list_replacements: The list of indexes for which the genotypes are 
                         discordant (int).
    """
    
    # 1. Check that positions and field_to_change are of the same length.
    if len(positions_list) != len(genotypes_list):
        sys.exit("ERROR in function 'get_list_replacements_for_disconcordant_genotypes': Lengths of positions_list and the genotypes_list differ.")
    
    # 2. Read positions and define which positions should be kept
    #    (non-redundant ones).
    list_keeps = []
    for pos_index in xrange(len(positions_list) - 1):
        if positions_list[pos_index] != positions_list[pos_index + 1]:
            list_keeps.append(pos_index)
    list_keeps.append(len(positions_list) - 1)
    
    # 3. Define list of replacements.
    genotype_values = []
    list_replacements = []
    nb_index_read = 0
    for pos_index in xrange(len(positions_list)):
        # For every new index, append the new genotype
        genotype_values.append(genotypes_list[pos_index])
        # If in keeps
        if pos_index in list_keeps:
            if len(set(genotype_values)) > 1: # Check that genotypes are concordant
                list_replacements.append(nb_index_read)
            # Reinitialise list of genotype values before new pos_index
            genotype_values = []
            nb_index_read += 1
    
    # 4. Return
    return list_replacements



def redefine_field_from_positions(positions_list, original_field, 
        list_replacements = [], replacement_value = "NA"):
    """ Redefines the field that is to be changed, based on the list of 
    positions.

    Inputs:
    - positions_list   : The list of positions (int).
    - original_field   : The list of values (int or string) from the field to 
                         change.
    - list_replacements: The list of indexes corresponding to positions with
                         discordant genotypes (between the two reads).
    - replacement_value: The value for the replacement of discordant reads 
                         (string).

    Outputs:
    - output_field     : The list of new values from the original field to
                         change.
    """

    # 1. Check that positions and field_to_change are of the same length
    if len(positions_list) != len(original_field):
        sys.exit("ERROR in function 'redefine_field_from_positions': Lengths of positions_list and the original_field to change differ.")

    # 2. Read positions and define which positions should be removed
    list_keeps = []
    for pos_index in xrange(len(positions_list) - 1):
        if positions_list[pos_index] != positions_list[pos_index + 1]:
            list_keeps.append(pos_index)
    list_keeps.append(len(positions) - 1)
    
    # 3. Add keeps to output vector
    output_field = []
    for pos_index in list_keeps:
        output_field.append(original_field[pos_index])

    # 4. Replace output_field with replacements
    for repl_index in list_replacements:
        output_field[repl_index] = replacement_value

    # 5. Return
    return output_field



def add_fields_to_output_file(fileout, prefix, list_fields, 
                                         sep = '\t', opening = 'a'):
    """ Adds a line containing the 'prefix' variable followed by all fields 
    from a list 'list_fields' to the output file 'fileout'. 
    
    Arguments:
    - fileout    : The name of the output file in which to write.
    - line       : The element to write before the fields.
    - list_fields: The fields to add at the end of the line (must be a tuple).
    - sep        : The separator used between columns.
    - opening    : - 'a' if the line should be appended to the 'fileout'.
                   - 'w' if the 'fileout' should be overwritten.
    """
    
    # 1. Concatenate in a string the pieces of information to add
    adds = ''
    for field in list_fields[:-1]:
        adds += str(field) + sep
    adds += str(list_fields[-1]) + '\n'
    
    # 2. Add the information to the output file.
    with open(fileout, opening) as fo:
        fo.write(prefix + sep + adds)



def turn_list_to_str(list_values, sep = ";"):
    """ Transforms a list to a string.
    
    Arguments:
    - list_values: The original list of values (int or string).
    - sep        : The field separator in the output string (string).
    
    Outputs:
    - output_str : The output string (string).
    """

    output_str = ""
    for value in list_values[:-1]:
        output_str = output_str + str(value) + sep
    output_str = output_str + str(list_values[-1])
    return output_str



def count_occurrences_in_list(list_values, searched_value):
    """ Counts occurrences of a searched value in a given list.
    
    Arguments:
    - list_values   : The original list of values (int or string).
    - searched_value: The searched value (int or string).
    
    Output:
    - nb_occur      : The number of occurrences in the list.
    """
    
    nb_occur = 0
    for value in list_values:
        if value == searched_value:
            nb_occur += 1
    return nb_occur



def get_list_keeps(positions_list):
    """ Get the list of keeps (i.e. indexes that must be kept).
    
    Arguments:
    - positions_list: The list of positions (int).
    
    Output:
    - list_keeps    : The list of indexes that must be kept (int).
    """
    list_keeps = []
    for pos_index in xrange(len(positions) - 1):
        # Keep an index only if the positions if different from the next one
        if positions_list[pos_index] != positions_list[pos_index + 1]:
            list_keeps.append(pos_index)
    list_keeps.append(len(positions_list) - 1)
    return list_keeps



def count_nb_redundant_SNPs(positions_list):
    """ Counts the number of redundant variants.
    
    Arguments:
    - positions_list: The list of positions (int).
    
    """
    
    # 1. Read positions and define which positions should be removed
    list_keeps = []
    for pos_index in xrange(len(positions) - 1):
        if positions[pos_index] != positions[pos_index + 1]:
            list_keeps.append(pos_index)
    list_keeps.append(len(positions) - 1)
    
    nb_SNPs = []
    start_pos = -1 
    for kept_pos_index in xrange(len(list_keeps)):
        nb_SNPs_on_pos = list_keeps[kept_pos_index] - start_pos
        if nb_SNPs_on_pos == 2:
            nb_SNPs_on_pos = 1.01
        nb_SNPs.append(nb_SNPs_on_pos)
        start_pos = list_keeps[kept_pos_index]
    return nb_SNPs



def count_with_weight(list_values, searched_value, list_weights):
    """ Sums up values, considering the attributed weigths.
    
    Arguments:
    - list_values   : The list of values from a given field (int or string).
    - searched_value: The searched_value (int or string).
    - list_weights  : The list of weights associated to each value.
    
    Outputs:
    - count         : The total count (taking into account the weight).
    """
    
    count = 0
    for pos_index in xrange(len(list_values)):
        value = list_values[pos_index]
        if value == searched_value:
            count += list_weights[pos_index]
    return count




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
####                              MAIN SCRIPT                              ####
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

## PROCEDURE FOLLOWED IN THIS SCRIPT:
# 1. Read the input fragments file line by line
# 2. For each line, check that all SNP positions are different from the previous
#   a. If so: rewrite the line as it was
#   b. If not: rewrite the proper pieces of information.

if __name__ == '__main__':
    
    # 0.   Get arguments
    args = create_parser()
    
    # 0.a. Files
    input_file = args.input_file
    output_file = args.output_file
    
    # 0.b. Parameters
    skip_header = args.skip_header
    ref_name = args.ref_name
    alt_name = args.alt_name
    
    # 0.c. Remind user of their chosen parameters
    print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    print "SCRIPT: add_weight_to_overlapping_fragments.py"
    print "PARAMETERS:\n"
    print "Input file:", input_file
    print "Output file:", output_file
    print "Ref name:", ref_name
    print "Alt name:", alt_name
    print "Skip header ?", skip_header
    print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
    
    # 0.d. Additional parameters (not chosen by the user): column numbers
    # (Column numbers are given in the base-1 referential)
    col_positions = 6
    col_geno = 7
    col_mut_types = 8
    col_qual = 9
    col_alle = 10
    col_ref1 = 11
    col_ref2 = 12
    col_filt = 13
    col_covr = 14
    col_freq = 15

    # Non-to-be-modified
    col_ID = 1
    col_nb = 2
    col_nb_P1 = 3
    col_nb_P2 = 4
    col_chrm = 5 
    col_targ = 16

    # 1.   Read and process each line of the file
    with open(output_file, 'w') as filout:
        filout.write("#READ_ID\tNB_VARIANTS\tNB_GENOT_REF\tNB_GENOT_ALT\tCHR\tPOS\tGENOTYPES\tVARIANT_TYPES\tQUALITIES\tALLELES\tALLELES_REF\tALLELES_ALT\tNB_OVERLAP\tVCF_FILTER\tVCF_DEPTH\tVCF_FREQ\tTARGET\n")
        
        with open(input_file, 'r') as filin:
            
            # 1.a. Skip header if needed
            if skip_header:
                next(filin)
            
            # 1.b. Extract the necessary pieces of information 
            for line in filin:
                
                # A. Fields
                fields = line.split("\t")
                
                # B. Lists of information
                positions = list(fields[col_positions - 1].split(";"))
                geno_list = list(fields[col_geno - 1].split(";"))
                mut_types = list(fields[col_mut_types - 1].split(";"))
                qual_list = list(fields[col_qual - 1].split(";"))
                alle_list = list(fields[col_alle - 1].split(";"))
                ref1_list = list(fields[col_ref1 - 1].split(";"))
                ref2_list = list(fields[col_ref2 - 1].split(";"))
                filt_list = list(fields[col_filt - 1].split(";"))
                covr_list = list(fields[col_covr - 1].split(";"))
                freq_list = list(fields[col_freq - 1].split(";"))

                # C. Parameter-dependent pieces of information
                repl_val = "DISCORDANT"
                list_keeps = get_list_keeps(positions)
                list_repl = get_list_replacements_for_disconcordant_genotypes(positions, alle_list)
                positions_2 = redefine_field_from_positions(positions, positions)
                geno_list_2 = redefine_field_from_positions(positions, geno_list, list_repl, repl_val)
                mut_types_2 = redefine_field_from_positions(positions, mut_types, list_repl, repl_val)
                qual_list_2 = redefine_field_from_positions(positions, qual_list, list_repl, repl_val)
                alle_list_2 = redefine_field_from_positions(positions, alle_list, list_repl, repl_val)
                ref1_list_2 = redefine_field_from_positions(positions, ref1_list)
                ref2_list_2 = redefine_field_from_positions(positions, ref2_list)
                filt_list_2 = redefine_field_from_positions(positions, filt_list)
                covr_list_2 = redefine_field_from_positions(positions, covr_list)
                freq_list_2 = redefine_field_from_positions(positions, freq_list)

                # D. Modify the counts
                count_SNP_2 = count_nb_redundant_SNPs(positions)
                nb_P1 = str(count_with_weight(geno_list_2, ref_name, list_weights = count_SNP_2))
                nb_P2 = str(count_with_weight(geno_list_2, alt_name, list_weights = count_SNP_2))
                nb = str(len(geno_list))

                # E. Turn to strings
                posi_str = turn_list_to_str(positions_2)
                geno_str = turn_list_to_str(geno_list_2)
                muta_str = turn_list_to_str(mut_types_2)
                qual_str = turn_list_to_str(qual_list_2)
                alle_str = turn_list_to_str(alle_list_2)
                ref1_str = turn_list_to_str(ref1_list_2)
                ref2_str = turn_list_to_str(ref2_list_2)
                filt_str = turn_list_to_str(filt_list_2)
                covr_str = turn_list_to_str(covr_list_2)
                freq_str = turn_list_to_str(freq_list_2)
                SNPs_str = turn_list_to_str(count_SNP_2)

                # F. Other non-modified strings
                readID = fields[col_ID - 1]
                target = fields[col_targ - 1]
                chrm = fields[col_chrm - 1]

                line = readID + '\t' + \
                        nb + '\t' + \
                        nb_P1 + '\t' + \
                        nb_P2 + '\t' + \
                        chrm + '\t' + \
                        posi_str + '\t' + \
                        geno_str + '\t' + \
                        muta_str + '\t' + \
                        qual_str + '\t' + \
                        alle_str + '\t' + \
                        ref1_str + '\t' + \
                        ref2_str + '\t' + \
                        SNPs_str + '\t' + \
                        filt_str + '\t' + \
                        covr_str + '\t' + \
                        freq_str + '\t' + \
                        target

                # Write line to output file
                filout.write(line)

