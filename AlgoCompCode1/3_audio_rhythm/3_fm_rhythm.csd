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
  ifreq_monitor = p5 ; frequency of the corresponding audio monitor wave
  kmod_ratio = p6
  kmod_freq_r = ifreq_rhythm*kmod_ratio ; mod freq for rhythm
  kmod_freq_m = ifreq_monitor*kmod_ratio ; mod freq for audio monitor
  index_start = p7
  index_end = p8
  kmod_index linseg index_start, p3, index_end
  i2pi = 6.283186
  kmod_index = kmod_index/i2pi ; mod index scaling for phase modulation
  imod_phase = p9 ; initial phase of the modulator wave (creates different rhythm patterns)

  ; rhythm generating wave
  aphase_r phasor ifreq_rhythm
  amod_r poscil3 kmod_index, kmod_freq_r, giSine, imod_phase
  arhythm tablei aphase_r+amod_r, giSine, 1, 0.5, 1

  ; audio monitor wave
  aphase_m phasor ifreq_monitor
  amod_m poscil3 kmod_index, kmod_freq_m, giSine, imod_phase
  amonitor tablei aphase_m+amod_m, giSine, 1, 0.5, 1
  outch 1, arhythm*0.6+amonitor*0.05

  ; find zero crossings
  k1 downsamp arhythm ; rhythm generator
  ktrig1 trigger k1, 0, 1 ; up-down trig
  kdown downsamp aphase_r ; reference pulse (unmodulated)
  ktrigdown trigger kdown, 0.5, 1 ; up-down trig
  kamp1 init 0
  kamp1 max kamp1, k1 ; get absolute max in this period

  ; each zero crossing
  if ktrig1 == 1 then
    kdur = 0.1
    kpitch = 1
    event "i", 51, 0, kdur, kamp1, kpitch
    kamp1 = 0
  endif

  ; downbeat  
  if ktrigdown == 1 then
    kdown_amp = 1
    kdur = 0.1
    kpitch = 0.5
    event "i", 51, 0, kdur, kdown_amp, kpitch
  endif

endin


;***************************************************
; make sound
instr 51
  iamp = p4
  iamp = iamp*3 ; empirical adjustment

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
; output tempo cps ratio index1 index2 phase
i1 0 30 1 55 3 0 5 0.0


e
</CsScore>
</CsoundSynthesizer>
