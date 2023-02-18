#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Markov melody generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io
import markov_melody

# basic settings for the melody generator
input_notes = [0,2,3,5,7,5,3,2,0]
m = markov_melody.Markov()
for note in input_notes:
    m.analyze(note)

# message handler
def osc_handler(unused_addr, *osc_data):
    voice, index, tempo_bps, note = osc_data
    delta_time = 1/tempo_bps
    duration = 1/tempo_bps
    notenum = m.next_note(note)
    index += 1
    returnmsg = [index, delta_time, notenum, duration]
    address = "/markov_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

osc_io.dispatcher.map("/csound_markov", osc_handler)
osc_io.asyncio.run(osc_io.run_osc_server())

