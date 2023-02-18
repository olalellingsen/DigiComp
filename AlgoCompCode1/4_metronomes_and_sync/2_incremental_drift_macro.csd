<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;*********************************************************************
; incremental drift
; generate metronome pulses and map to events

; generate N instances of instrument 2
instr 1
  inum_voices = p4
  ibase_tempo = p5
  iamp = p6
  ihigh_note = p7

  icount = 0
  while icount < inum_voices do
    icount += 1
    itempo = ibase_tempo*(icount/inum_voices)
    inote = ihigh_note-icount
    event_i "i", 2, 0, p3, itempo, iamp, inote
  od

endin

; instrument 2 generate events for instr 31
instr 2
  itempo = p4
  iamp = p5
  inote = p6
  ktrig metro itempo
  idur = 0.1
  instr_num = 31
  if ktrig == 1 then
    event "i", instr_num, 0, idur, iamp, inote
  endif
endin

;***************************************************
; make sound
instr 31
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)

  iAttack = 0.005
  iDecay = 0.05
  iSustain = 0.3
  iRelease = 0.01
  amp madsr iAttack, iDecay, iSustain, iRelease
  amp = amp * iamp

  a1 oscili iamp, icps, giSine

  outch 1, a1*amp, 2, a1*amp

endin

;*********************************************************************

</CsInstruments>
<CsScore>
; generate pulses and map to events
; num_voices base_tempo amp high_note
i1 0 8 4 1 -6 84
i1 9 100 100 1 -14 120
e
</CsScore>
</CsoundSynthesizer>
