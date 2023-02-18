<Cabbage>
form caption("Midi event generator"), size(500, 400), pluginID("mgen")
button latched(1), bounds(5,5,45,15), channel("on"), text("on"), colour:0(90,90,70),  colour:1(14, 142, 0)

label bounds(5,30,45,11), text("Note")
nslider bounds(55,30,45,15), channel("note"), text(""), range(36,96,60,1,1)

label bounds(5,50,45,11), text("Tempo")
nslider bounds(55,50,45,15), channel("tempo"), text(""), range(0.1,50,1,1,0.01)

label bounds(5,70,45,11), text("Amp")
nslider bounds(55,70,45,15), channel("amp"), text(""), range(-96,0,-6,1,0.01)

csoundoutput bounds(5,200,495,195)
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=NULL -Q0 -M0
</CsOptions>
<CsInstruments>

;sr = 48000 ; WE GET THIS FROM HOST
ksmps = 1
nchnls = 2
0dbfs = 1

giSine		ftgen	0, 0, 65536, 10, 1

;*********************************************************************
instr 1
  kbutton chnget "on"
  ktrig_on trigger kbutton, 0.5, 0
  ktrig_off trigger kbutton, 0.5, 1
  if ktrig_on > 0 then
    event "i", 2, 0, -1
  endif
  if ktrig_off > 0 then
    event "i", -2, 0, .1
  endif
endin


instr   2
  knote     chnget "note"
  ktempo    chnget "tempo"
  kamp      chnget "amp"
  ktrig     metro ktempo
  idur      = 0.1
  ins_num   = 31
  iMIDI_instr = 201
  if ktrig == 1 then
    event "i", ins_num, 0, idur, kamp, knote
    event "i", iMIDI_instr, 0, idur, kamp, knote
  endif
endin

;***************************************************
; make sound
instr	31
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)			; cps from midi note number

  iAttack = 0.005
  iDecay = 0.3
  iSustain = 0.3
  iRelease = 0.1
  amp madsr iAttack, iDecay, iSustain, iRelease

  a1 oscil3 amp*iamp, icps, giSine

  outch	1, a1, 2, a1

endin

;***************************************************
instr	201
  ; midi  output

  iamp = p4
  idB_range  = 70
  ivel = pow((1+(iamp/idB_range)),2) * 127
  print iamp, ivel
  inote = p5
  ichan = 1

  idur = (p3 < 0 ? 999 : p3)	; use very long duration for realtime events, noteondur will create note off when instrument stops
  idur = (p3 < 0.1 ? 0.1 : p3)	; avoid extremely short notes as they won't play

  noteondur ichan, inote, ivel, idur
endin
;***************************************************


</CsInstruments>
<CsScore>
i1 0 86400
e
</CsScore>
</CsoundSynthesizer>
