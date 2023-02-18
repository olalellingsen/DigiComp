#!/usr/bin/python
# -*- coding: latin-1 -*-

""" 
A simple cellular automata.

See http://mathworld.wolfram.com/CellularAutomaton.html for a description of the cellular automata algorithm.

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import copy

def cellular(input,rule):
    """
    Simple cellular automata.

    @param input: The initial state of the cells.
    @param rule: The CA rule as a binary list.
    """
    output = copy.copy(input)
    for i in range(len(input)):
        # our center cell, for processing the rules
        center = input[i]
        # then, to find the next cell to the left and to the right of the center cell
        if i == 0: left = 0 # cells outside our population is considered to be dead (you could choose to do this differently)
        else: left = input[i-1] # check if the cell to the left is alive or dead
        if i == len(input) -1: right = 0 # cells outside our population is considered to be dead
        else: right = input[i+1] # check if the cell to the right is alive or dead
        # standard rules processing
        if left and right and center: output[i] = rule[0]
        if left and center and not right: output[i] = rule[1]
        if left and right and not center: output[i] = rule[2]
        if left and not right and not center: output[i] = rule[3]
        if right and center and not left: output[i] = rule[4]
        if center and not left and not right: output[i] = rule[5]
        if right and not left and not center: output[i] = rule[6]
        if not left and not right and not center: output[i] = rule[7]
    return output

def to_bin(x, count=8):
    """
    Convert an integer to a binary string.
    
    @param x: The integer to convert.
    @param bits: The number of bits to use for the binary digit (in the format of a string).
    """
    return "".join(map(lambda y:str((x>>y)&1), range(count-1, -1, -1)))
    
def to_list(s):
    """
    Convert a binary string to a list of binary values.
    
    @param s: The string to convert.
    """
    l = list(s)
    for i in range(len(l)):
        l[i] = int(l[i])
    return l

def string_cells(cells):
    """
    Convert a list of cells to a string, use the star (*) character for live cells and space for dead ones. Used only for printing.
    
    @param cells: The list of cells to convert.
    """
    s = ''
    for cell in cells:
        if cell == 1: s += '*'
        else: s += ' '
    return s    

# test
if __name__ == '__main__' :
    # set the axiom, that is the initial state of each cell
    cells = [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0]
    # set the CA rule
    rule_number = 30
    rule = to_list(to_bin(rule_number))
    print('rule', rule)
    print('**CA**', cells, string_cells(cells))
    for i in range(20):
        cells = cellular(cells, rule)
        print ('**CA**', cells, string_cells(cells))

