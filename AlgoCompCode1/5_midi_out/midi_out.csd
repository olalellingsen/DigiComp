<CsoundSynthesizer>
<CsOptions>
--midioutfile=test.mid
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;*********************************************************************
; generate some instrument events
instr 1
  iamp = p4
  inote = p5
  itempo = p6
  ktrig metro itempo
  idur = 0.1
  ins_num = 31
  iMIDI_instr = 201
  if ktrig == 1 then
    event "i", ins_num, 0, idur, iamp, inote ; generate sine tone instr
    event "i", iMIDI_instr, 0, idur, iamp, inote ; generate midi out
  endif
endin

;***************************************************
; make sound
instr 31
  iamp = ampdbfs(p4) ; amp in dB
  icps = cpsmidinn(p5) ; cps from midi note number

  iAttack = 0.005
  iDecay = 0.3
  iSustain = 0.3
  iRelease = 0.1
  amp madsr iAttack, iDecay, iSustain, iRelease

  a1 oscil3 amp*iamp, icps, giSine

  outch 1, a1, 2, a1

endin

;***************************************************
instr 201
  ; midi output
    ; (if using midi file out: set name for midi outfile on commandline e.g. --midioutfile=test.mid)


    iamp = p4
    idB_range = 70
    ivel = pow((1+(iamp/idB_range)),2) * 127
    print iamp, ivel
    inote = p5
    ichan = 1

    idur = (p3 < 0 ? 999 : p3) ; use very long duration for realtime events, noteondur will create note off when instrument stops
    idur = (p3 < 0.1 ? 0.1 : p3) ; avoid extremely short notes as they won't play

    noteondur ichan, inote, ivel, idur
endin
;***************************************************


</CsInstruments>
<CsScore>
; test midi out
; amp note tempo
i1 0 4 -6 72 1
i1 5 4 -10 60 2

e
</CsScore>
</CsoundSynthesizer>
