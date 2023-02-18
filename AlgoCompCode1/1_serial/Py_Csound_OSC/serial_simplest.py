#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Serial melody generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io # osc server and client (you do not need to look into this module, it should "just work")

# basic settings for the melody generator
notes = [0,2,3,5,7,10] # the notes that we will use for our melody
durations = [1, 0.5, 0.1] # the event durations, a 1.0 means to hold the note until the next note. 0.5 means to hold the note half of the time span until the next note
rhythm = [1,1,0.5,0.5] # the rhythm, meaning the time to wait until we trigger the next note

def serial_lookup(index, values):
    '''A simple list lookup with wrapping for out-of-range indices'''
    value = values[index%len(values)]
    return value

def osc_handler(unused_addr, *osc_data):
    '''Message handler. This is called when we receive an OSC message'''
    voice, index, tempo_bps, basenote = osc_data # unpack the OSC data, must have the same number of variables as we have items in the data
    delta_time = serial_lookup(index, rhythm)/tempo_bps # get delta time (rhythm) and scale according to tempo
    duration = serial_lookup(index, durations)/tempo_bps # get event duration and scale according to tempo
    notenum = serial_lookup(index, notes) # get note number for next event
    notenum += basenote # transpose according to base note
    index += 1 # increment index, ready for next event
    returnmsg = [index, delta_time, notenum, duration] #pack the values that we want to send back to Csound via OSC
    print(returnmsg)
    address = "/serial_event_{}".format(int(voice)) # set the address we want to send to (depend on voice number)
    osc_io.sendOSC(address, returnmsg) # send OSC back to Csound

if __name__ == "__main__": # if we run this module as main we will start the server
    osc_io.dispatcher.map("/csound_serial", osc_handler) # here we assign the function to be called when we receive OSC on this address
    osc_io.asyncio.run(osc_io.run_osc_server()) # run the OSC server and client

