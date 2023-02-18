<CsoundSynthesizer>
<CsOptions>
-otest1.wav
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1
gi1 ftgen 0, 0, 0, 1, "808_chh.wav", 0, 0, 0
gi2 ftgen 0, 0, 0, 1, "808_clap.wav", 0, 0, 0
gi3 ftgen 0, 0, 0, 1, "808_sd0050.wav", 0, 0, 0
gi4 ftgen 0, 0, 0, 1, "808_sd7575.wav", 0, 0, 0
gi5 ftgen 0, 0, 0, 1, "808-kick.wav", 0, 0, 0
; collect a reference to all sound files in one table:
giSamples ftgen 0, 0, 8, -2, gi1, gi2, gi3, gi4, gi5, gi1, gi1, gi1



;*********************************************************************
; "sound chart" random sample player
; generate rhythm and map to events

instr 1
  ibasetempo = p4
  iamp = -2
  ipitch = 1
  irhythmtab ftgen 0, 0, 16, -2, 1, 2, 2, 1, 4,4,4,4, 1, 0.5, 1, 3,3,3,1,1
  kindex init -1
  ktempo init 1
  ktrig metro ibasetempo*ktempo*2
  irhythmlen = 16
  kindex = (kindex+ktrig)%irhythmlen
  ktempo table kindex, irhythmtab
  inumsounds = 5
  idur = 1
  inst_num = 61
  ipolyphony = 3
  knum_active active inst_num
  if (ktrig == 1) && (knum_active < ipolyphony) then
    ksound random 0, inumsounds-0.01
    ksoundtable table int(ksound), giSamples
    kpan random 0, 1
    event "i", inst_num, 0, idur, iamp, ipitch, ksoundtable, kpan
  endif
endin

;***************************************************
; make sound
instr 61
  iamp = ampdbfs(p4)
  ipitch = p5
  isoundtable = p6
  ipan = p7
  inumsamp = nsamp(isoundtable)
  p3 = inumsamp/sr
  amp linsegr 0, 0.001, 1, 0.1, 0
  amp = amp * iamp

  a1 loscil 1, ipitch, isoundtable, 1
  a1 = a1*amp
  aLeft = a1*sqrt(1-ipan)
  aRight = a1*sqrt(ipan)
  outch 1, aLeft, 2, aRight

endin

;*********************************************************************

</CsInstruments>
<CsScore>
i1 0 30 1

e
</CsScore>
</CsoundSynthesizer>
