#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Serial melody generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io
import time

# basic settings for the melody generator
# one liste per voice, initial example preparing 2 voices
notes = [[0,2,3,5,7,10],
         [0,2,3,5,7,10]]
durations = [[1, 0.5, 0.1],
             [1, 0.5, 0.1]]
rhythm = [[1,1,0.5,0.5],
          [1,1,0.5,0.5]]

def serial_lookup(index, values):
    value = values[index%len(values)]
    return value

# message handler
def osc_handler(unused_addr, *osc_data):
    voice, index, tempo_bps, basenote = osc_data
    delta_time = serial_lookup(index, rhythm[voice-1])/tempo_bps
    duration = serial_lookup(index, durations[voice-1])/tempo_bps
    notenum = serial_lookup(index, notes[voice-1])
    notenum += basenote
    index += 1
    returnmsg = [index, delta_time, notenum, duration]
    address = "/serial_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

def set_series(unused_addr, *osc_data):
    print('set_series', osc_data)
    serie_select, voice, value = osc_data
    if serie_select == 1:
        global notes
        if value == -1:
            notes[voice-1] =[]
        else:
            notes[voice-1].append(value)
    if serie_select == 2:
        global rhythm
        if value == -1:
            rhythm[voice-1] = []
        else:
            rhythm[voice-1].append(value)

    
osc_io.dispatcher.map("/csound_serial", osc_handler)
osc_io.dispatcher.map("/csound_serial_setseries", set_series)
osc_io.asyncio.run(osc_io.run_osc_server())

