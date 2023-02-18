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

; generate sine waves, analyze zero crossings
instr 1
  ifreq_rhythm = p4 ; frequency of the rhythm-generating wave
  ifreq_monitor = 56 ; frequency of the corresponding audio monitor wave

  ; automation of amplitudes for the different harmonics
  kamp_h1 oscili 0.5, 0.12, giSine
  kamp_h2 oscili 0.5, 0.22, giSine
  kamp_h3 oscili 0.5, 0.07, giSine
  kamp_h4 oscili 0.5, 0.17, giSine
  kamp_h5 oscili 0.5, 0.04, giSine
  kamp_h1 = kamp_h1 + 0.5
  kamp_h2 = kamp_h2 + 0.5
  kamp_h3 = kamp_h3 + 0.5
  kamp_h4 = kamp_h4 + 0.5
  kamp_h5 = kamp_h5 + 0.5

  ; rhythm generating waves
  adown oscili 1, ifreq_rhythm, giSine
  ar1 oscili kamp_h1, ifreq_rhythm*1, giSine
  ar2 oscili kamp_h2, ifreq_rhythm*2, giSine
  ar3 oscili kamp_h3, ifreq_rhythm*3, giSine
  ar4 oscili kamp_h4, ifreq_rhythm*4, giSine
  ar5 oscili kamp_h5, ifreq_rhythm*5, giSine
  arhythm = (ar1+ar2+ar3+ar4+ar5)

  ; audio monitor waves
  am1 oscili kamp_h1, ifreq_monitor*1, giSine
  am2 oscili kamp_h2, ifreq_monitor*2, giSine
  am3 oscili kamp_h3, ifreq_monitor*3, giSine
  am4 oscili kamp_h4, ifreq_monitor*4, giSine
  am5 oscili kamp_h5, ifreq_monitor*5, giSine
  amonitor = (am1+am2+am3+am4+am5)
  outch 1, arhythm*0.2+amonitor*0.02

  ; find zero crossings
  k1 downsamp arhythm ; harmonic rhythm wave
  ktrig1 trigger k1, 0, 1 ; up-down trig
  kdown downsamp adown ; reference signal (downbeat)
  ktrigdown trigger kdown, 0, 1 ; up-down trig
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
  iamp = iamp

  ipitch = p5

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
; output parameters
i1 0 20 1 110

e
</CsScore>
</CsoundSynthesizer>
