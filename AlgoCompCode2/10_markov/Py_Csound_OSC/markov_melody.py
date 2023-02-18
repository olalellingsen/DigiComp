#!/usr/bin/python
# -*- coding: latin-1 -*-

""" 
A simple markov chain generator.

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import random

class Markov:

    def __init__(self): # this method is called when the class is instantiated
        self.markov_stm = {}
        self.previous_note = None # used only when analyzing

    def analyze(self, note):
        print('Markov analyze', note)
        if self.previous_note == None: # first note received is treated differently
            self.previous_note = note
            return
        else: # all next notes are analyzed, stored as possible successors to the previous note
            self.markov_stm.setdefault(self.previous_note, []).append(note)
            self.previous_note = note

    def next_note(self, previous=None):
        print('next_note', previous)
        # as we are live recording melodies for analysis, dead ends are likely, and needs to be dealt with
        if previous and (previous not in self.markov_stm.keys()):
            print('Markov: dead end')
            return -1.0
        if len(self.markov_stm.keys()) == 0:
            print('Empty Markov sequence')
            return -1.0
        # for the very first note, we do not have any previous note, so let's choose one randomly
        if not previous:
            previous = random.choice(list(self.markov_stm.keys()))
        alternatives = self.markov_stm[previous] # get a list of possible next notes
        new_note = random.choice(alternatives) # and choose one of them
        return new_note
    
    def clear(self):
        self.markov_stm = {}
        self.previous_note = None 
        

# test
if __name__ == '__main__' :
    m = Markov()
    input_melody = ['C', 'D', 'E', 'F', 'G', 'E', 'F', 'D', 'C', 'stop']
    #analyze
    for note in input_melody:
        m.analyze(note)
    print(m.markov_stm)
    print('**** **** done analyzing **** ****')
    #generate
    new_notes = []
    next_note = None
    i = 0
    while i < 15:
        if not next_note == 'stop':
            next_note = m.next_note(next_note)
            print('the next note is ', next_note)
            new_notes.append(next_note)
        i += 1
    print('generated {} notes'.format(len(new_notes)-1))
    print('notes', new_notes)
          
    
