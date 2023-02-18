<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 1
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;*********************************************************************
; generate data

; read sound, analyze
instr 1
  Sfile = "vokal.wav"
  ispeed = p4
  iskiptime = p5
  iwrap = 1
  a1 diskin2 Sfile, ispeed, iskiptime, iwrap

  ; audio playback, original pitch, but time scaled to the playback rate of the rhythm generator
  giSound ftgen 0, 0, 0, -1, Sfile, 0, 0, 0
  ipitch_corr = ftsr(giSound)/sr
  atimpnt line 0, p3, p3*ispeed
  amonitor mincer atimpnt*ipitch_corr, 0.15, ipitch_corr, giSound, 0, 4096, 8
  outch 1, amonitor*3 ; output, empirical amplitude adjustment

  ; find zero crossings, and amplitude in this period
  k1 downsamp a1
  ktrig1 trigger k1, 0, 1 ; up-down trig
  kamp1 init 0
  kamp1 max kamp1, k1 ; get absolute max in this period

  if ktrig1 == 1 then
    kdur = 0.1
    kpitch = 1
    event "i", 51, 0, kdur, kamp1, kpitch
    kamp1 = 0 ; reset max on each trig
  endif

endin


;***************************************************
; make sound
instr 51
  iamp = p4
  iamp = iamp*4 ; empirical adjustment
  ipitch = 1

  iAttack = 0.005
  iDecay = 0.3
  iSustain = 0.3
  iRelease = 0.1
  amp madsr iAttack, iDecay, iSustain, iRelease
  amp = amp * iamp

  a1,a2 diskin2 "Rock11.wav", ipitch

  outch 2, a2*amp

endin

;*********************************************************************

</CsInstruments>
<CsScore>
; generate data
; set playbackspeed, skiptime
i1 0 150 0.02 0.0

e
</CsScore>
</CsoundSynthesizer>
