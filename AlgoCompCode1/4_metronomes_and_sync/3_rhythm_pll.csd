<CsoundSynthesizer>
<CsOptions>

</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 100
nchnls = 2
0dbfs = 1

opcode RhythmPLL, kkk, kikk
  ; PLL for rhythmic synchronization
  ; Oeyvind Brandtsegg 2021 oyvind.brandtsegg@ntnu.no
    ; Licence: Creative commons CC BY (use as you like but you *must* credit)
    ; outputs: pulse, phase (ramp), and frequency
    ; inputs: ext clock pulse, init frequency, freq adjust gain, phase adjust gain
    k1trig, ifq2, kgain, kphasegain xin

    ; oscillator
    kfq2 init ifq2
    kosc2 init 0
    kosc2 += (kfq2/kr) ; increment ramp value
    kosc2 = kosc2 > 1 ? 0 : kosc2 ; wrap around
    k2trig trigger kosc2, 0.5, 1 ; downwards trigger when wrapping

    ; phase difference detector
    kcount init 0
    k2_prevphase init 0
    kdiff init 0
    kdifflag init 0
    kdiff_old init 0
    kskip init 1
    if k1trig > 0 then
      if kskip == 0 then
	kdiff = (kosc2+kcount)-k2_prevphase ; get phase difference
	kdifflag = (kdiff <= 0 ? kdiff : 0)
	kdiff = (kdiff <= 0.1 ? kdiff+1 : kdiff) ; if clocks tick at exactly the same time, the counter will be late
	kphasecorr = wrap(kosc2,-0.5,0.5)*-1
      endif
      kskip = 0
      kcount = kdifflag != 0 ? -1 : 0 ; recap after the "synchronous tick"-saving trick above
      k2_prevphase = kosc2
    endif
    if k2trig > 0 then
      kcount += 1
    endif

    ; calculate the error correction values
    kfact = divz(1,kdiff,1) ; the tempo adjustment factor
    kerr = ((kfact-1)*kgain*k1trig)+1
    kphaserr = kfq2*kphasecorr*k1trig*kphasegain
    kfq2 = (kfq2*kerr)+kphaserr
    xout k2trig, kosc2, kfq2
endop

instr 1
  ; start the "master" rhythm generator, the one we will sync to
  kfq1 = p4
  k1trig metro kfq1
  chnset k1trig, "clock_input"
endin

instr 2
  ; run the "slave" rhythm generator (at another tempo), and slowly synchronize to the external pulse
  k1trig chnget "clock_input"
  ifq2 = p4
  kfqgain = 0.02 ; adjust this according to how fast we want the clocks to synchronize
  kphasegain = 0.005 ; adjust this according to how strong we want the phase synchronization to be
  k2trig, kphase, kfq2 RhythmPLL k1trig, ifq2, kfqgain, kphasegain
  if k1trig == 1 then
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
