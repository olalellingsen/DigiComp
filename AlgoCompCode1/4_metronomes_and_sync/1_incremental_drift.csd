<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giSine ftgen 0, 0, 65536, 10, 1

;*********************************************************************
; incremental drift
; generate metronome pulses and map to events

instr 1
  itempo = p4
  iamp = p5
  inote = p6
  ktrig metro itempo
  idur = 0.1
  inst_num = 31
  if ktrig == 1 then
    event "i", inst_num, 0, idur, iamp, inote
  endif
endin

;***************************************************
; make sound
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
; generate pulses and map to events
i1 0 8 [1/4] -6 100
i1 0 8 [3/4] . 80
s
i1 0 8 [1/4] -8 100
i1 0 . [2/4] . 90
i1 0 . [3/4] . 80
i1 0 . [4/4] . 70
s
; tempo amp note
i1 0 20 [1/10] -10 100
i1 0 . [2/10] . 97
i1 0 . [3/10] . 94
i1 0 . [4/10] . 91
i1 0 . [5/10] . 88
i1 0 . [6/10] . 85
i1 0 . [7/10] . 82
i1 0 . [8/10] . 79
i1 0 . [9/10] . 76
i1 0 . [10/10] . 73
s
; tempo amp note
i1 0 60 [1/30] -12 100
i1 0 . [2/30] . 99
i1 0 . [3/30] . 98
i1 0 . [4/30] . 97
i1 0 . [5/30] . 96
i1 0 . [6/30] . 95
i1 0 . [7/30] . 94
i1 0 . [8/30] . 93
i1 0 . [9/30] . 92
i1 0 . [10/30] . 91
i1 0 . [11/30] . 90
i1 0 . [12/30] . 89
i1 0 . [13/30] . 88
i1 0 . [14/30] . 87
i1 0 . [15/30] . 86
i1 0 . [16/30] . 85
i1 0 . [17/30] . 84
i1 0 . [18/30] . 83
i1 0 . [19/30] . 82
i1 0 . [20/30] . 81
i1 0 . [21/30] . 80
i1 0 . [22/30] . 79
i1 0 . [23/30] . 78
i1 0 . [24/30] . 77
i1 0 . [25/30] . 76
i1 0 . [26/30] . 75
i1 0 . [27/30] . 74
i1 0 . [28/30] . 73
i1 0 . [29/30] . 72
i1 0 . [30/30] . 71
e
</CsScore>
</CsoundSynthesizer>
