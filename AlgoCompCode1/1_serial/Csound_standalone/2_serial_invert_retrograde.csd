|<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

;***************************************************
; globals
;***************************************************

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

;***************************************************
;ftables
;***************************************************

; classic waveforms
giSine ftgen 0, 0, 65537, 10, 1 ; sine wave
giNotes1 ftgen 0, 0, 8, -2, 0, 3, 5, 7, 10, 12, 15, 17 ; a series of pitches (as semitones)
gitempo = 1 ; the master tempo

; utility UDO 
opcode wrapping, k, kk
  ; this works like the opcode wrap, but with correct wrapping of negative values
  ; Oyvind Brandtsegg 2023
  kval, khigh xin
  if kval>=0 then
    kwrap = kval%khigh
  elseif kval%khigh==0 then
    kwrap = 0
  else
    kwrap = khigh+kval%khigh
  endif
  xout kwrap
endop

;***************************************************
; event generator
instr 1

  iamp = p4 ; amplitude
  ipan = p5 ; panning
  ibase = p6 ; base pitch
  itempo = p7*gitempo ; tempo
  idur = p8 ; duration for each event ...
  idur = (1/itempo)*idur ; ... relative to tempo
  iseq_length = p9 ; how many of the notes (from giNotes1) we want to use
  kmetro metro itempo ; metronome for event generation
  kindx init 0 ; index counter
  kdirection chnget "direction" ; forward or backward reading of the melody notes (1 or -1)
  kinversion chnget "inversion" ; normal or inverted melody  (1 or -1)
  
  if kmetro > 0 then ; do this only when the metronome ticks
    kpindex wrapping kindx, iseq_length ; use wrapping to keep the index in the range we want
    knote table kpindex, giNotes1 ; get pitch, use modulo (%) to keep the index in the range we want
    kindx += 1*kdirection ; increment or decrement counter
    event "i", 11, 0, idur, iamp, ibase+(knote*kinversion), ipan ; generate event (play sound generator)
  endif

endin

; modify the direction parameter
instr 3
  Sname strget p4 ; set channel name ("direction" or "inversion")
  ivalue = p5 ;  1 or -1
  chnset ivalue, Sname
endin


;***************************************************
; sound generator
instr 11

  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = p6
  iattack = 0.001
  idecay = 0.2
  isustain = 0.4
  irelease = 0.1

  aenv linsegr 0, iattack, 1, idecay, isustain, 1, isustain, irelease, 0
  a1 oscil3 aenv*iamp, icps, giSine

  ; master amp and panning
  aleft = a1 * iamp * sqrt(1-ipan) ; (square root) equal power panning
  aright = a1 * iamp * sqrt(ipan) ; (square root) equal power panning

  outs aleft, aright
endin


</CsInstruments>
<CsScore>

; start dur amp pan base tempo dur seq_length
i1 0 20 -7 0.4 72 4 0.1 4

; set direction (forwards/backwards)
i3 0 1 "inversion" 1 ; normal melody MUST BE SET AT START
i3 0 1 "direction" 1 ; forward MUST BE SET AT START

; modifications to direction and inversion
i3 4 1 "direction" -1 ; backward

i3 8 1 "direction" 1 ; forward...
i3 8 1 "inversion" -1 ; ...and inverted

i3 12 1 "direction" -1 ; backward (and inverted)

i3 16 1 "inversion" 1 ; back to normal ...
i3 16 1 "direction" 1 ; ... in the forward direction


</CsScore>
</CsoundSynthesizer>
