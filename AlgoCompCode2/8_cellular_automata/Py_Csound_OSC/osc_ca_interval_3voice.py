#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Serial melody generator in Python, communicating via OSC to play notes in Csound

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
cells1 = np.zeros(num_cells)
cells_notenum1 = np.zeros(num_cells)
cells1[8] = 1

cells2 = np.zeros(num_cells)
cells_notenum2 = np.zeros(num_cells)
cells2[8] = 1

cells3 = np.zeros(num_cells)
cells_notenum3 = np.zeros(num_cells)
cells3[8] = 1
voice_data = [[cells1, cells_notenum1],[cells2, cells_notenum2],[cells3, cells_notenum3]]

def get_cell_parameters(cells, cell_index, cells_notenum):
    cell_index %= num_cells
    cell_alive = cells[cell_index]
    if cell_alive:
        amp = 0
        cells_notenum[cell_index] += 1
    if not cell_alive:
        amp = -15
    notenum = cells_notenum[cell_index]
    pan = cell_index/(num_cells-1)
    if cell_index == 0: downbeat = 1
    else: downbeat = 0
    return amp, notenum, pan, downbeat, cells_notenum
                         
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
    global voicedata
    voice, index, tempo_bps, basenote = osc_data
    cells, cells_notenum = voice_data[voice-1]
    amp, notenum, pan, downbeat, cells_notenum = get_cell_parameters(cells, index, cells_notenum)
    if index%num_cells == num_cells-1:
        cells = new_ca_generation(cells, rule_number)
        voice_data[voice-1] = cells, cells_notenum
    delta_time = 1/tempo_bps
    duration = 1/tempo_bps
    notenum += basenote
    index += 1
    returnmsg = [index, delta_time, notenum, duration, amp, pan, downbeat]
    address = "/serial_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

# let's see the initial state of the cells before we start running
print("first generation:    ", voice_data[0][0])


osc_io.dispatcher.map("/csound_serial", osc_handler)
osc_io.asyncio.run(osc_io.run_osc_server())

