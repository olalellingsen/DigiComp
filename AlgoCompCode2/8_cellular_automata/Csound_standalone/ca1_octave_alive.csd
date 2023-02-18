<CsoundSynthesizer>
<CsOptions>
-m0 ; mute all the extra event printing so that our sybols of live and dead cells are more clearly shown
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

; play cellular automation
instr 10
  ktrig metro 8 ; rhythm generator for note events
  kcount init 0 ; index counter
  if ktrig == 1 then
    kcell = giCells[kcount] ; get live/dead status of a cell
    if kcell == 1 then
      knote = 72
    else
      knote = 60
    endif
    if kcount == 0 then ; At the first cell in a generation, we might want to add an accent
      kamp = -6
    else
      kamp = -16
    endif
    event "i", 51, 0, .1, kamp, knote ; create note event
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


; tone instr
instr 51
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = 0.5

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

; maracas
instr 52
  p3 = 1.5
  iatck = 0.014
  iamp = ampdbfs(-11)
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
i10 0 80 ; run automation

</CsScore>
</CsoundSynthesizer>
