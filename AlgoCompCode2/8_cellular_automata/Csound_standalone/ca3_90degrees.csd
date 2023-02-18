<CsoundSynthesizer>
<CsOptions>
-m0
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 10
nchnls = 2
0dbfs	= 1

; helper UDOs for Cellular Automata
#include "cellular_utilities.inc"

; set up initial population of cells
gisize = 32
giCells[] init gisize ; the array contining the population of cells
giCells[16] = 1 ; set one to be alive at start
giScale[] fillarray 0, 3, 5, 7, 10 ; a melodic scale to use

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
  iamp = p5
  ibasenote = p6
  ipan = p7
  idur = 1/p4 ; duration relative to tempo
  if ktrig == 1 then
    kcount = 0
    while kcount < lenarray(giCells) do ; do this FOR ALL CELLS in a generation in one go
      kcell = giCells[kcount] ; get live/dead status of a cell
      if kcell > 0 then ; play only of the cell is alive
	; use the cell number (kcount) as an index into a meldic scale, so each cell has its own pitch,
	; .. and change the octave (add 12 semitones) when we try to index past the end (size of) of the scale
	knote = ibasenote + giScale[kcount%lenarray(giScale)] +	int(kcount/lenarray(giScale))*12
	event "i", 51, 0, idur, iamp, knote, ipan ; create note event
      endif
      if kcount == lenarray(giCells)-1 then ; when we are at the last count in a generation of cells
	event "i", 3, 0, 1 ; update cells
	event "i", 4, 0, 1 ; print current state of the cells
      endif
      kcount += 1
    od
  endif
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
;        tempo amp note pan
i10 0 12 6    -20  40  0.5 ; run automation

</CsScore>

</CsoundSynthesizer>
