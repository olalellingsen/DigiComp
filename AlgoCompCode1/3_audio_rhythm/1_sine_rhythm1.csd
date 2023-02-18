<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 1 ; MUST be 1 in this orchestra
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;*********************************************************************
; generate data

; generate sine waves, analyze zero crossings
instr 1
  ifreq_rhythm = p4 ; frequency of the rhythm-generating wave
  ifreq_monitor = p5 ; frequency of the corresponding audio monitor wave

  ; automation of amplitudes for the different harmonics
  kamp_h1 oscili 0.5, 0.12, giSine
  kamp_h1 = kamp_h1 + 0.5

  ; rhythm generating waves
  arhythm oscili kamp_h1, ifreq_rhythm, giSine

  ; audio monitor waves
  amonitor oscili kamp_h1, ifreq_monitor, giSine
  outch 1, arhythm*0.6+amonitor*0.1

  ; find zero crossings
  krhythm downsamp arhythm
  ktrig1 trigger krhythm, 0, 1 ; trig on zero cross in downward direction
  kamp1 init 0
  kamp1 max kamp1, krhythm ; get absolute max in this period

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
  iamp = iamp*3 ; adjust to taste...

  ipitch = p5

  iAttack = 0.005
  iDecay = 0.3
  iSustain = 0.3
  iRelease = 0.1
  amp madsr iAttack, iDecay, iSustain, iRelease
  amp = amp * iamp

  a1,a2 diskin2 "Rock11.wav", ipitch

  outch 2, a2*amp ; for testing purposes, use just one of the audio channels

endin

;*********************************************************************

</CsInstruments>
<CsScore>
; generate data
; tempo pitch
i1 0 50 1 220

e
</CsScore>
</CsoundSynthesizer>
