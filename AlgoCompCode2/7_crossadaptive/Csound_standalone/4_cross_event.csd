<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1

  giSine    ftgen  0, 0, 65536, 10, 1

; read sound, analyze, apply amp to another sound
instr 1
  ipitch = 1
  itempo = p4
  a1 diskin2 "vokal.wav", ipitch, 0
  ; analyze amp, pitch 
  kamp rms a1
  kamp = kamp * 2  ;scale it as we want
  kpitch,kamp_ pitchamdf a1, 100, 900
  knote = round(12 * (log(kpitch/440)/log(2)) + 69) ; calculate midi note number from frequency
  
  ktrig metro itempo ; rhythm generator
  idur = 0.1
  inst_num = 31
  if ktrig == 1 then
    event "i", inst_num, 0, idur, kamp, knote
  endif

endin

;***************************************************
; make sound
instr 31
  iamp = p4
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


</CsInstruments>
<CsScore>
i1 0 10 15


e
</CsScore>
</CsoundSynthesizer>
