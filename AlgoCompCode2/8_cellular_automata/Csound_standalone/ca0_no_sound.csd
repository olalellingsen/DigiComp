<CsoundSynthesizer>
<CsOptions>
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

; run cellular automation, print cells
instr 10
  ktrig metro 1
  if ktrig == 1 then
    event "i", 3, 0, 1 ; update cells
    event "i", 4, 0, 1 ; print current state of the cells
  endif
endin


</CsInstruments>
<CsScore>
i2 0 1 30 ; make rule array
i4 0 1 ; print cells before we start running anything
i10 0 10 ; run automation

</CsScore>

</CsoundSynthesizer>
