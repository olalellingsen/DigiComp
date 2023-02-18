#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Cellular automation generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io
import ca
import numpy as np

# basic settings # basic settings
rule_number = 30
tempo = 4
amp = -3
basenote = 60
num_cells = 16
cells = np.zeros(num_cells)
cells[8] = 1

def get_cell_parameters(cells, cell_index):
    cell_index %= num_cells
    cell_alive = cells[cell_index]
    if cell_alive: amp = 0
    if not cell_alive: amp = -15
    pan = cell_index/(num_cells-1)
    if cell_index == 0: downbeat = 1
    else: downbeat = 0
    return amp, pan, downbeat
                         
# Function to create a new generation of cells.
# Input the old array of cells and a rule number.
# Returns the new array of cells
def new_ca_generation(cells,rule_number):
    rule = ca.to_list(ca.to_bin(rule_number))
    cells = ca.cellular(cells, rule)
    print("generated new cells: ", cells)
    return cells

# message handler
def osc_handler(unused_addr, *osc_data):
    global cells
    voice, index, tempo_bps, basenote = osc_data
    amp, pan, downbeat = get_cell_parameters(cells, index)
    if index%num_cells == num_cells-1:
        cells = new_ca_generation(cells, rule_number)
    delta_time = 1/tempo_bps
    duration = 1/tempo_bps
    notenum = 0
    notenum += basenote
    index += 1
    returnmsg = [index, delta_time, notenum, duration, amp, pan, downbeat]
    address = "/serial_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

# let's see the initial state of the cells before we start running
print("first generation:    ", cells)


osc_io.dispatcher.map("/csound_serial", osc_handler)
osc_io.asyncio.run(osc_io.run_osc_server())

