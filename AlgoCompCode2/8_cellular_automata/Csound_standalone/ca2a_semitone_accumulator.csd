<CsoundSynthesizer>
<CsOptions>
-m0
</CsOptions>
<CsInstruments>

sr 	= 48000
ksmps 	= 10
nchnls 	= 2
0dbfs	= 1

; helper UDOs for Cellular Automata
#include "cellular_utilities.inc"

; set up initial population of cells
gisize = 32
giCells[] init gisize ; the array contining the population of cells
giCells[16] = 1 ; set one to be alive at start
gkIntervals[] init gisize ; array to hold melodic intervals, updated by cell values

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
    if kcount == gisize-1 then ; when we are at the last count in a generation of cells
      event "i", 3, 0, 1 ; update cells
      event "i", 4, 0, 1 ; print current state of the cells
    endif
  endif
  kcount = (kcount+ktrig)%gisize
endin


; tone instr
instr 51
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = p6

  iAttack = 0.005
  iDecay = 0.05
  iSustain = 0.3
  iRelease = 0.01
  amp madsr iAttack, iDecay, iSustain, iRelease

  a1 oscili iamp, icps
  aL = a1*sqrt(1-ipan)*amp
  aR = a1*sqrt(ipan)*amp
  outs aL, aR
endin

</CsInstruments>
<CsScore>
i2 0 1 30 ; make rule array
i4 0 1 ; print cells before we start running anything
;        tempo  note pan
i10 0 120 8     60 0.5 ; run automation
</CsScore>

</CsoundSynthesizer>
