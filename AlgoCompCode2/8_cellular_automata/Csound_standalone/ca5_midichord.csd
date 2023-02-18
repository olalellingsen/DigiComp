<CsoundSynthesizer>
<CsOptions>
-odac -M0 -m0
</CsOptions>
<CsInstruments>

sr 	= 44100
ksmps 	= 10
nchnls 	= 2
0dbfs	= 1

pgmassign 0, 0 ; disable program change
massign 1,21 ; assign midi channel 1 to instr 21
massign 2,21 ; assign midi channel 2 to instr 21
massign 3,21 ; assign midi channel 3 to instr 21
massign 4,21 ; assign midi channel 4 to instr 21


; helper UDOs for Cellular Automata
#include "cellular_utilities.inc"

; set up initial population of cells
gisize = 32
giCells[] init gisize ; the array contining the population of cells
;giCells[16] = 1 ; set one to be alive at start
gkIntervals[] init gisize ; array to hold melodic intervals, updated by cell values
giScale[] fillarray 0, 3, 5, 7, 10 ; a melodic scale to use
giChords[][] init gisize,5 ; two-dimensional array to hold chords for each cell
giNoChord[] init 5 ; empty array, use this to clear previously stored chords
gkcount init 0 ; global counter, running through each cell location in looped sequence
gitimestamp init 0 ; time stamp for incoming notes, to check if we play several notes simultaneously
gichordindex = 0 ; index into the chord array

; make binary rule array
instr 2
  irule = p4
  giRule[] make_binary irule ; make the array containing the rule
endin

; grow next generation of cells
instr 3
  giCells ca_update giCells, giRule ; update the live/dead status of all cells in the population
endin

; print cells
instr 4
  ca_print_cells giCells ; print
endin

; play cellular automation, update intervals according to cell values
instr 10
  ktrig metro p4
  ibasenote = p5
  ipan = p6
  kcount init 0
  gkcount = kcount ; update the global counter (accessed by the midi input instrument later)
  if ktrig == 1 then
    kcell = giCells[kcount] ; get live/dead status of a cell
    gkIntervals[kcount] = gkIntervals[kcount]+kcell ; each time a cell is alive, increment the corresponding value in gkIntervals
    knote = ibasenote+gkIntervals[kcount] ; use the value in gkIntervals as transposition in semitones
    if kcount == 0 then
      kamp = -5
    else
      kamp = -12
    endif
    event "i", 51, 0, 0.1, kamp, knote, ipan ; create note event
    kchordindx = 1
    while giChords[kcount][kchordindx] != 0 do ; if we have any chord notes for this cell, run through them all
      event "i", 51, 0, 1, kamp, knote+giChords[kcount][kchordindx], ipan ; ... and create note events
      kchordindx += 1
    od
    if kcount%8 == 0 then ; rhythmic subdivision, do something at every 8th count
      event "i", 52, 0, 1 ; create percussion event
    endif
    if kcount == gisize-1 then ; when we are at the last count in a generation of cells
      event "i", 3, 0, 1 ; update cells
      event "i", 4, 0, 1 ; print current state of the cells
    endif
  endif
  kcount = (kcount+ktrig)%gisize
endin

instr 21
  ; midi add or delete cell
  inote notnum
  iswitch ctrl7 1,1,0,1 ; we will use midi controller input as a switch between life and death for a cell
  print inote, iswitch
  itime times ; get time time when this note was played
  idelta = itime-gitimestamp ; check if we are playing several notes within a short time span
  gitimestamp = itime ; update the global time stamp with the current time
  ichordthreshold = 0.2 ; the time threshold for what we call "simultaneous" (0.2 seconds here)
  if idelta < ichordthreshold then ; if the time since the previous note is so short we can call them simultaneous
    gichordindex += 1 ; increment the chord index
  else
    gichordindex = 0 ; if notes are not simultaneous, then reset chord index
  endif
  if iswitch == 0 then ; as long as the note is held and the switch is off...
    kchange changed gkcount ; check if the cell counter changes
    if kchange>0 then ; ... and
      reinit killcell ; initiate kill of this cell (reinitialize at label "killcell")
	killcell: ; label, allows goto operations, and also reinitialize operation on a section of the code
	giCells[i(gkcount)] = 0 ; set cell state to zero (dead)
	giChords setrow giNoChord, i(gkcount) ; clear any previously stored chord
	rireturn ; stop the reinitialize operation and return to normal processing
	gkIntervals[gkcount] = 0 ; reset interval counter for this cell
      endif
    else ; if the switch is ON, ...
      giCells[i(gkcount)] = 1 ; then give life to the cell at the current global counter position...
      gkIntervals[gkcount] = inote-60 ; ... and set an initial value for the interval counter for this cell
      giChords[i(gkcount)][gichordindex] = inote-60 ; set the current note as a member of the chord for this cell
      iTest[] getrow giChords, i(gkcount) ; this is just for printing...
      printarray iTest ; print the currently stored chord
    endif
endin


; tone instr
instr 51
  iamp = ampdbfs(p4)
  inote = p5
  ipan = p6
  p3 = 1
  aenv expon 1, 0.5, 0.01
  a1 poscil aenv*iamp, cpsmidinn(inote)
  aL = a1*sqrt(1-ipan)
  aR = a1*sqrt(ipan)
  outs aL, aR
endin

; maracas
instr 52
  p3 = 1.5
  iatck = 0.014
  iamp = ampdbfs(-10)
  kenv expseg 0.4, iatck, 1, p3-iatck, 0.001
  kdens expseg 600, iatck, 3000, p3-iatck, 1
  anoise dust2 kenv, kdens
  anoise buthp, anoise, 6000
  anoise butbp anoise, 6000, 2000
  anoise *= iamp
  outs anoise, anoise
endin

</CsInstruments>
<CsScore>
i2 0 1 30 ; make rule array
i4 0 1 ; print cells before we start running anything
;           tempo  note pan
i10 0 86400 6      60   0.5 ; run automation
</CsScore>

</CsoundSynthesizer>
