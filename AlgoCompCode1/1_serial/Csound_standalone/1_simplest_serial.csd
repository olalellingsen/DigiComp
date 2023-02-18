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
giNotes1 ftgen 0, 0, 8, -2, 0, 2, 4, 6, 8, 10, 12, 14 ; a series of pitches (as semitones)
giIndices ftgen 0, 0, 128, -2, 0 ; empty series at start of program, we will fill this later
gitempo = 1 ; the master tempo

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

  if kmetro > 0 then ; do this only when the metronome ticks
    knote table kindx % iseq_length, giNotes1 ; get pitch, use modulo (%) to keep the index in the range we want
    kindx += 1 ; increment counter
    event "i", 11, 0, idur, iamp, ibase+knote, ipan ; generate event (play sound generator)
  endif

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
i1 0 10 -7 0.2 72 3 0.1 4 
; now add another voice
i1 4 6 -7 0.8 60 5 0.2 7

</CsScore>
</CsoundSynthesizer>
