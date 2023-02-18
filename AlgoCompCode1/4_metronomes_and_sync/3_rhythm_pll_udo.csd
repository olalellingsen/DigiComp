<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 100
nchnls = 2
0dbfs = 1

; include the code for the Rhythm Phase Locked Loop UDO
#include "rhythm_pll_udo.inc"

instr 1
  ; start the "master" rhythm generator, the one we will sync to
  kfq1 = p4
  ktrig metro kfq1
  chnset ktrig, "clock_input"
endin

instr 2
  ; run the "slave" rhythm generator (at another tempo), and slowly synchronize to the external pulse
  krig chnget "clock_input"
  ifq2 = p4 ; the frequency of our slave rhythm generator
  kfqgain = 0.02 ; adjust this according to how fast we want the clocks to synchronize
  kphasegain = 0.005 ; adjust this according to how strong we want the phase synchronization to be
  k2trig, kphase, kfq2 RhythmPLL ktrig, ifq2, kfqgain, kphasegain
  if ktrig == 1 then
    event "i", 31, 0, 0.1, -5, 60, 0
  endif
  if k2trig == 1 then
    event "i", 31, 0, 0.1, -7, 72, 1
  endif

endin

;***************************************************
; make sound
instr 31
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = p6
  iAttack = 0.001
  iDecay = 0.05
  iSustain = 0.1
  iRelease = 0.01
  amp madsr iAttack, iDecay, iSustain, iRelease
  amp = amp * iamp
  a1 oscili iamp, icps

  outch 1, a1*amp*(1-ipan), 2, a1*amp*ipan

endin

</CsInstruments>
<CsScore>
; init tempo
i1 0 70 6
i2 0 70 2
</CsScore>
</CsoundSynthesizer>
