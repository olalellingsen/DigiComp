<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>

<CsInstruments>
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

gihandle OSCinit 9999

; play markov melody
instr 31
  ivoice = p4
  iamp = p5
  ibasenote = p6
  itempo_bpm = p7
  itempo_bps = itempo_bpm/60
  itempofactor = p8
  itempo = itempo_bps*itempofactor
  kindex init 0
  kdelta_time init 0
  knext_event_time init 0
  kduration init 1
  knote init 0
  ktime timeinsts
  ievent_trig_lag_time = 0.1
  kget_event = (ktime > knext_event_time) ? 1 : 0
  if kget_event > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_markov", "iiff",ivoice, kindex, itempo, knote
  endif
  Saddress sprintf "/markov_event_%i", ivoice
  nextmsg:
  kmessage OSClisten gihandle, Saddress, "ifff",  kindex, kdelta_time, knote, kduration
  if kmessage == 0 goto done
    kpan = ivoice/4
    kevent_time_delay = (knext_event_time-ktime) + ievent_trig_lag_time
    if (kevent_time_delay < 0) then
      Swarning sprintfk "Warning : event overflow in voice %i at time %f", ivoice, ktime 
      puts Swarning, ktime
    endif
    event "i", 51, kevent_time_delay, kduration, iamp, knote+ibasenote, kpan
    knext_event_time += kdelta_time
    kgoto nextmsg
  done:
endin

; sine tone instr 
instr 51
  ;print p2
  iamp = ampdbfs(p4)
  inote = p5
  ipan = p6
  aenv madsr 0.001, 0.2, 0.2, 0.01
  a1 poscil aenv*iamp, cpsmidinn(inote)
  aL = a1*sqrt(1-ipan)
  aR = a1*sqrt(ipan)
  chnmix aL, "masterL"
  chnmix aR, "masterR"
endin

; maracas
instr 52
  p3 = 1.5
  iatck = 0.014
  iamp = ampdbfs(-10)
  kenv expseg 0.4, iatck, 1, p3-iatck, 0.001
  kdens expseg 600, iatck, 3000, p3-iatck, 1
  anoise dust2 kenv, kdens
  anoise buthp, anoise, 6000
  anoise butbp anoise, 6000, 2000
  anoise *= iamp
  chnmix anoise, "masterL"
  chnmix anoise, "masterR"
endin

instr 99
  aL chnget "masterL"
  aR chnget "masterR"
  chnclear "masterL"
  chnclear "masterR"
  outs aL, aR
  fout "test.wav", 14, aL, aR
endin

</CsInstruments>
<CsScore>
/*
ivoice = p4
iamp = p5
ibasenote = p6
itempo_bpm = p7
itempo_factor = p8
*/
#define SCORELEN #30#
i31 0 $SCORELEN 1 -16 60 60 2
i31 8 $SCORELEN 2 -16 72 60 3

i99 0 [$SCORELEN+5]
e
</CsScore>
</CsoundSynthesizer>
