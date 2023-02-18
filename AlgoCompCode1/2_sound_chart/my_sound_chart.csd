<CsoundSynthesizer>
<CsOptions>
; -odac
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;trp samples
gi1 ftgen 0, 0, 0, 1, "samples/trp_1.wav", 0, 0, 0
gi2 ftgen 0, 0, 0, 1, "samples/trp_2.wav", 0, 0, 0
gi3 ftgen 0, 0, 0, 1, "samples/trp_3.wav", 0, 0, 0
gi4 ftgen 0, 0, 0, 1, "samples/trp_4.wav", 0, 0, 0
gi5 ftgen 0, 0, 0, 1, "samples/trp_5.wav", 0, 0, 0
gi6 ftgen 0, 0, 0, 1, "samples/trp_B.wav", 0, 0, 0


; gi2 ftgen 0, 0, 0, 1, "samples/trp_Db.wav", 0, 0, 0
; gi1 ftgen 0, 0, 0, 1, "samples/trp_GbG.wav", 0, 0, 0
; gi3 ftgen 0, 0, 0, 1, "samples/trp_lick.wav", 0, 0, 0
; gi5 ftgen 0, 0, 0, 1, "samples/trp_lick2.wav", 0, 0, 0
; gi4 ftgen 0, 0, 0, 1, "samples/trp_trill.wav", 0, 0, 0

;drum samples
; gi13 ftgen 0, 0, 0, 1, "samples/808_sd7575.wav", 0, 0, 0
; gi10 ftgen 0, 0, 0, 1, "samples/808_sd0050.wav", 0, 0, 0
; gi11 ftgen 0, 0, 0, 1, "samples/808-kick.wav", 0, 0, 0
; gi12 ftgen 0, 0, 0, 1, "samples/808_chh.wav", 0, 0, 0
; gi14 ftgen 0, 0, 0, 1, "samples/808_clap.wav", 0, 0, 0

;trp percussive samples
gi12 ftgen 0, 0, 0, 1, "samples/t10.aif", 0, 0, 0
gi10 ftgen 0, 0, 0, 1, "samples/t11.aif", 0, 0, 0
gi13 ftgen 0, 0, 0, 1, "samples/t7.aif", 0, 0, 0
gi11 ftgen 0, 0, 0, 1, "samples/t2.aif", 0, 0, 0
gi14 ftgen 0, 0, 0, 1, "samples/t3.aif", 0, 0, 0

; collect a reference to all sound files in one table:
giTrpSamples ftgen 0, 0, 8, -2, gi1, gi2, gi3, gi4, gi6, gi3

giDrumSamples ftgen 0, 0, 8, -2, gi10, gi11, gi12, gi13, gi14

; seed 0 ;sets the first input in the randomized generator to a different number each time


;*********************************************************************
; "sound chart" random sample player
; generate rhythm and map to events

instr 1
  ibasetempo = p4
  iamp = -10
  ipitch = 1
  irhythmtab ftgen 0, 0, 16, -2, 1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,1,1 ;2, 2, 1, 4,4,4,4, 1, 0.5, 1, 3,3,3,1,1
  kindex init -1
  ktempo init 1
  ktrig metro ibasetempo*ktempo*2
  irhythmlen = 16
  kindex = (kindex+ktrig)%irhythmlen
  ktempo table kindex, irhythmtab
  inumsounds = 6
  idur = 1
  inst_num = 61
  ipolyphony = 3
  knum_active active inst_num
  if (ktrig == 1) && (knum_active < ipolyphony) then
    ksound random 0, inumsounds-0.01
    ksoundtable table int(ksound), giTrpSamples
    kpan random 0, 1
    event "i", inst_num, 0, idur, iamp, ipitch, ksoundtable, kpan
  endif
endin


instr 2
  ibasetempo = p4
  iamp = -2
  ipitch = 1
  irhythmtab ftgen 0, 0, 16, -2, 1,4,2,4, 1,4,4,4, 4,2,4,2, 2,2,4,4
  kindex init -1
  ktempo init 1
  ktrig metro ibasetempo*ktempo*6
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
    ksoundtable table int(ksound), giDrumSamples
    kpan random 0, 1
    event "i", inst_num, 0, idur, iamp, ipitch, ksoundtable, kpan
  endif

endin


instr 3
  itempo = p4
  iamp = p5
  inote = p6
  ktrig metro itempo*2
  idur = 0.1
  inst_num = 31
  if ktrig == 1 then
    event "i", inst_num, 0, idur, iamp, inote
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

instr 31
  iamp = ampdbfs(p4)
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

;*********************************************************************

</CsInstruments>
<CsScore>

;trumpet
; i1 0 40 1

; i3 0 20 [1/4] -8 100
; i3 0 . [1] . 70 ; 1 = pulse

; i3 0 10 [9/4] . 80
; i3 10 10 [11/4] . 80


;chords polyrhythm
; i3 0 10 [1/10] -10 90
; i3 0 . [3/10] . 70
; i3 0 . [3/10] . 85
; i3 0 . [3/10] . 100
; i3 0 . [6/10] . 75
; i3 0 . [6/10] . 80
; i3 0 . [9/10] . 60
; s


; i2 0 20 1

i2 0 20 [1/10] -20 
i2 0 . [3/10] .

;trp polyrhythm..
; i1 0 40 [1/10] -10 90
; i1 0 . [3/10] . 70
; i1 0 . [3/10] . 85
; i1 0 . [3/10] . 100
; i1 0 . [6/10] . 75
; i1 0 . [6/10] . 80
; i1 0 . [9/10] . 60
; s

; i3 0 20 [1/10] -10 90
; i3 0 . [4/10] . 70
; i3 0 . [4/10] . 85
; i3 0 . [4/10] . 100
; i3 0 . [6/10] . 75
; i3 0 . [6/10] . 80
; i3 0 . [9/10] . 60
; s



;some chords
; i3 0 3 [1] -10 70
; i3 . . [1] . 73
; i3 . . [1] . 77
; i3 . . [1] . 80
; i3 . . [1] . 84

; i3 3 3 [1] . 75
; i3 . . [1] . 79
; i3 . . [1] . 82
; i3 . . [1] . 85
; i3 . . [1] . 88

; i3 6 3 [1] -10 65
; i3 . . [1] . 69
; i3 . . [1] . 72
; i3 . . [1] . 76
; i3 . . [1] . 79



</CsScore>
</CsoundSynthesizer>
