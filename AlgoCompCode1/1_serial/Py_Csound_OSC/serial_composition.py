#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Serial melody generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io

# basic settings for the melody generator
notes = [0, 2, 4, 5, 7]
durations = [0.5,0.5,1]
rhythm = [1,1,1,1,0.5,0.5,1,2]
pans = [0,1,0,1,0.5]
attacks = [0,0,0.5]
reverbs = [0,0,0,1]


def serial_lookup(index, values):
    value = values[index%len(values)]
    return value

# message handler
def osc_handler(unused_addr, *osc_data):
    global notenums
    voice, index, tempo_bps, basenote, forward = osc_data
    delta_time = serial_lookup(index, rhythm)/tempo_bps
    duration = serial_lookup(index, durations)/tempo_bps
    notenum = serial_lookup(index, notes)
    notenum += basenote
    pan = serial_lookup(index, pans)
    attack = serial_lookup(index, attacks)
    reverb = serial_lookup(index, reverbs)
    if forward == 1:
        index += 1
    else:
        index -= 1
    returnmsg = [index, delta_time, notenum, duration, pan, attack, reverb]
    address = "/serial_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

if __name__ == "__main__": 
    osc_io.dispatcher.map("/csound_serial", osc_handler)
    osc_io.asyncio.run(osc_io.run_osc_server())

