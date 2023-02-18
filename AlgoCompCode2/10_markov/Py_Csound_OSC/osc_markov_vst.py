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
input_notes = [60,62,63,65,67,65,63,62,60]
m = markov_melody.Markov()
for note in input_notes:
    m.analyze(note)
print(m.markov_stm)

# message handler
def markov_play(unused_addr, *osc_data):
    voice, index, tempo_bps, note = osc_data
    delta_time = 1/tempo_bps
    duration = 1/tempo_bps
    notenum = m.next_note(note)
    index += 1
    returnmsg = [index, delta_time, notenum, duration]
    address = "/markov_event_{}".format(int(voice))
    osc_io.sendOSC(address, returnmsg)

def markov_record(unused_addr, *osc_data):
    note  = osc_data[0]
    m.analyze(note)
    print(m.markov_stm)

def markov_clear(unused_addr, *osc_data):
    not_used = osc_data
    m.clear()

osc_io.dispatcher.map("/csound_markov", markov_play)
osc_io.dispatcher.map("/markov_record", markov_record)
osc_io.dispatcher.map("/markov_clear", markov_clear)
osc_io.asyncio.run(osc_io.run_osc_server())

