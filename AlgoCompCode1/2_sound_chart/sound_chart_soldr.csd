<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1
gi1 ftgen 0, 0, 0, 1, "soldr_long.wav", 0, 0, 0
gi2 ftgen 0, 0, 0, 1, "soldr3.wav", 0, 0, 0
gi3 ftgen 0, 0, 0, 1, "soldr4a.wav", 0, 0, 0
gi4 ftgen 0, 0, 0, 1, "soldr5.wav", 0, 0, 0
gi5 ftgen 0, 0, 0, 1, "soldr6.wav", 0, 0, 0
gi6 ftgen 0, 0, 0, 1, "soldr7.wav", 0, 0, 0
gi7 ftgen 0, 0, 0, 1, "soldr8a.wav", 0, 0, 0
gi8 ftgen 0, 0, 0, 1, "soldr9a.wav", 0, 0, 0
gi9 ftgen 0, 0, 0, 1, "soldr10a.wav", 0, 0, 0
gi10 ftgen 0, 0, 0, 1, "soldr11a.wav", 0, 0, 0
gi11 ftgen 0, 0, 0, 1, "soldr12a.wav", 0, 0, 0
gi12 ftgen 0, 0, 0, 1, "soldr13.wav", 0, 0, 0
; collect a reference to all sound files in one table:
giSamples ftgen 0, 0, 16, -2, gi1, gi2, gi3, gi4, gi5, gi6, gi7, gi8, gi9, gi10, gi11, gi12, gi1, gi1, gi1, gi1


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
  ktrig metro ibasetempo*ktempo
  irhythmlen = 8
  kindex = (kindex+ktrig)%irhythmlen
  ktempo table kindex, irhythmtab
  inumsounds = 12
  idur = 1
  inst_num = 61
  ipolyphony = 2
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

  a1,a2 loscil 1, ipitch, isoundtable, 1
  a1 = a1*amp
  a2 = a2*amp
  aLeft = a1*sqrt(1-ipan)
  aRight = a2*sqrt(ipan)
  outch 1, aLeft, 2, aRight

endin

;*********************************************************************

</CsInstruments>
<CsScore>
i1 0 30 1

e
</CsScore>
</CsoundSynthesizer>
