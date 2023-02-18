; Example serial composition: "Self Reference" (Oeyvind Brandtsegg, 2013)
; Originally written for a sound installation with infinite duration

<CsoundSynthesizer>
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
giNotes1 ftgen 0, 0, 8, -2, 0, 2, 4, 5, 7, 9, 11, 12 ; a series of pitches (as semitones)
giNotes2 ftgen 0, 0, 8, -2, 0, -1, -3, -5, -7, -8, -10, -12 ; another pitch series
giNotes ftgen 0, 0, 8, -2, giNotes1, giNotes2 ; table to select between the two pitch series
gitempo = 0.3 ; the master tempo

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

  ivoice = p4 ; polyphinic voice separation so different voices each can follow individual series
  iamp = p5 ; amplitude
  ipan = p6 ; panning
  ibase = p7 ; base pitch
  itempo = p8*gitempo ; tempo
  idur = p9 ; duration for each event ...
  idur = (1/itempo)*idur ; ... relative to tempo
  iseq_length = p10 ; how many of the values (from giNotes1 and giRhythm1) we want to use
  inoteserie = p11
  iNotetab table inoteserie, giNotes ; point to the table where pitches are stored
  ktempo init 1 ; initialize the variable rhythm tempo
  kmetro metro itempo/ktempo ; metronome for event generation, uses variable tempo that we get from rhythm values
  kpitch_indx init 0 ; pitch index counter

  if kmetro > 0 then ; do this only when the metronome ticks
    kpindex wrapping kpitch_indx, iseq_length ; use wrapping to keep the index in the range we want
    knote table kpindex, iNotetab ; get pitch
    kpitch_indx += 1 ; increment pitch counter
    event "i", 11, 0, idur, iamp, ibase+knote, ipan ; generate event (play sound generator)
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
  iattack = 0.2
  idecay = 0.2
  isustain = 0.4
  irelease = 0.3
  ireverbsend = 0.5

  aenv linsegr 0, iattack, 1, idecay, isustain, 1, isustain, irelease, 0
  a1 oscil3 aenv*iamp, icps, giSine

  ; master amp and panning
  aleft = a1 * iamp * sqrt(1-ipan) ; (square root) equal power panning
  aright = a1 * iamp * sqrt(ipan) ; (square root) equal power panning

    ; send dry signal to master
  chnmix aleft, "masteraudioleft"
  chnmix aright, "masteraudioright"

  ; effect send
  chnmix aleft * ireverbsend, "reverbsendleft"
  chnmix aright * ireverbsend, "reverbsendright"

endin

;***************************************************
; simple reverb
;***************************************************
instr 99

  ; audio input
  ainl chnget "reverbsendleft"
  ainr chnget "reverbsendright"
  inlevel = 0.8
  ainl = ainl * inlevel
  ainr = ainr * inlevel

  ; reverb effect
  kfblvl = 0.85 ; reverb feedback, affects reverb time
  kfco = 7000 ; cutoff freq for internal lowpass filter in reverbsc
  aleft, aright reverbsc ainl, ainr, kfblvl, kfco

  ; send signal to master
  chnmix aleft, "masteraudioleft"
  chnmix aright, "masteraudioright"

  ; clear chn channels used for mixing
  aclear = 0
  chnset aclear, "reverbsendleft"
  chnset aclear, "reverbsendright"

endin
;***************************************************

;***************************************************
; master audio out
;***************************************************
instr 101

  ; audio input
  a1 chnget "masteraudioleft"
  a2 chnget "masteraudioright"

  outch 1, a1, 2, a2

  ; clear chn channels used for mixing
  aclear = 0
  chnset aclear, "masteraudioleft"
  chnset aclear, "masteraudioright"
endin

;***************************************************

</CsInstruments>
<CsScore>

#define SCORELEN # 200 # ; macro to set total score duration

; in the following score, some p-fields are in square brackets like this [1/4]
; items in square brackets are mathematical expressions, so [1/4] equals 0.25

; start dur voice amp pan base tempo dur seqlen noteserie
i1 0 $SCORELEN 1 -6 0 72 1 0.8 4 0
i1 0 $SCORELEN 2 -6 1 72 [1/4] 0.8 3 1
i1 3 $SCORELEN 3 -9 1 84 [2/3] 0.8 5 1
i1 5 $SCORELEN 4 -9 0 84 [4/3] 0.8 7 0
i1 5 $SCORELEN 5 -11 1 96 [3/4] 0.8 6 1
i1 1 $SCORELEN 6 -13 0 60 [3/5] 0.8 8 1

i 99 0 [$SCORELEN+10] ; reverb
i 101 0 [$SCORELEN+10] ; master out


</CsScore>
</CsoundSynthesizer>
