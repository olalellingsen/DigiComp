<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1

; read sound, analyze, apply amp to another sound
instr 1
  ipitch = 1
  a1 diskin2 "vokal.wav", ipitch, 0
  ; analyze amp, pitch 
  kpitch,kamp_ pitchamdf a1, 100, 900
  kamp rms a1

  a2 diskin2 "movpluckloop1.wav", 1, 0, 1
  ; shape the amp even more
  kamp pow kamp, 2
  ; and scale it as we want
  kamp = kamp * 15
  ; appy amp to other sound
  a2 = a2 * kamp
  ; filter the sound, using pitch from the first sound to control the filter
  kresonance = 0.7
  kdist = 0.5
  a2 lpf18 a2, kpitch*2, kresonance, kdist

  outs a1, a2
endin

</CsInstruments>
<CsScore>
i1 0 10 


e
</CsScore>
</CsoundSynthesizer>
