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
giRhythm1 ftgen 0, 0, 8, -2, 3, 2, 2, 1, 1, 1, 1, 4 ; rhythm series, smaller values means faster rhythm
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

  ivoice = p4 ; polyphinic voice separation so different voices each can follow individual series
  iamp = p5 ; amplitude
  ipan = p6 ; panning
  ibase = p7 ; base pitch
  itempo = p8*gitempo ; tempo
  idur = p9 ; duration for each event ...
  idur = (1/itempo)*idur ; ... relative to tempo
  iseq_length = p10 ; how many of the values (from giNotes1 and giRhythm1) we want to use
  ktempo init 1 ; initialize the variable rhythm tempo
  kmetro metro itempo/ktempo ; metronome for event generation, uses variable tempo that we get from rhythm values
  kpitch_indx init 0 ; pitch index counter
  krhythm_indx init 0 ; pitch index counter
  Sdirection sprintf "direction_voice%i", ivoice
  Sinversion sprintf "inversion_voice%i", ivoice
  puts Sinversion, 1
  kdirection chnget Sdirection ; forward or backward reading of the melody notes (1 or -1)
  kinversion chnget Sinversion ; normal or inverted melody  (1 or -1)

  if kmetro > 0 then ; do this only when the metronome ticks
    kpindex wrapping kpitch_indx, iseq_length ; use wrapping to keep the index in the range we want
    printk2 kpindex
    
    knote table kpindex, giNotes1 ; get pitch
    kpitch_indx += 1*kdirection ; increment or decrement pitch counter
    krindex wrapping krhythm_indx, iseq_length ; use wrap to keep the index in the range we want
    ktempo table krindex, giRhythm1 ; get pitch
    krhythm_indx += 1*kdirection ; increment or decrement rhythm counter
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

; start dur voice amp pan base tempo dur seq_length
i1 0 24 1 -7 0.3 72 4 0.1 4
i1 4 20 2 -7 0.8 60 4 0.1 4


; set direction (forwards/backwards)
i3 0 1 "inversion_voice1" 1 ; normal melody MUST BE SET AT START
i3 0 1 "direction_voice1" 1 ; forward MUST BE SET AT START
i3 0 1 "inversion_voice2" 1 ; normal melody MUST BE SET AT START
i3 0 1 "direction_voice2" 1 ; forward MUST BE SET AT START

; modify
i3 8 1 "direction_voice1" -1 ; backward
i3 12 1 "inversion_voice1" -1 ; inverted pitches
i3 16 1 "direction_voice1" 1 ; forward
i3 20 1 "inversion_voice1" 1 ; back to normal
*/

</CsScore>
</CsoundSynthesizer>
