<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 10
nchnls = 2
0dbfs	= 1

; helper UDOs for Cellular Automata
#include "cellular_utilities.inc"

; set up initial population of cells
gisize = 10
giCells[] init gisize ; the array contining the population of cells
giCells[5] = 1 ; set one to be alive at start

giScaleMelodi[] fillarray 23, 26, 30 ; a melodic scale to use
giScaleKomp[] fillarray 0, 7, 14, 16 ; a melodic scale to use

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

; komp
instr 10
  ktrig metro p4*3
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
	knote = ibasenote + giScaleKomp[kcount%lenarray(giScaleKomp)] +	int(kcount/lenarray(giScaleKomp))*12
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

;melodi
instr 11
  ktrig metro p4*3
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
	knote = ibasenote + giScaleMelodi[kcount%lenarray(giScaleMelodi)] +	int(kcount/lenarray(giScaleMelodi))*12
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

;            tempo amp note pan

;A
i10 0  20  1     -25  45  0.5 
i11 5  5   1     -30  45  0.9
i11 15 5   1     -30  45  0.1

i10 20 20  1     -20  45  0.5 
i11 25 5  [4/5]  -25  45  0.9
i11 35 7  [5/4]  -25  48  0.1


;B
i10 40 20 [5/4]  -18  48  0.5 
i11 45 5  [5/5]  -25  48  0.9
i11 55 7  [6/5]  -25  49  0.1

i10 60 20 [6/5]  -20  49  0.5 
i11 65 5  [6/3]  -25  49  0.9
i11 75 3  [6/4]  -25  49  0.1
i11 78 5  [6/4]  -28  46  0.5

i10 80 30 [8/3]  -15  46  0.5 
i11 90 5  [8/5]  -25  46  0.1
i11 102 5 [8/4]  -25  46  0.9
i11 107 8  3     -25  45 0.9

;A
i10 110 20 3     -20  45  0.5 
i11 115 5  3     -20  45  0.5
i11 125 5 [10/3] -20  45  0.5


</CsScore>

</CsoundSynthesizer>
