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

; play serial melody: pitch determined by interval series
instr 31
  ivoice = p4
  iamp = p5
  ibasenote = p6
  itempo_bpm = p7
  itempo_bps = itempo_bpm/60
  itempofactor = p8
  itempo = itempo_bps*itempofactor
  iforward = p9

  kindex init 0
  kdelta_time init 0
  knext_event_time init 0
  kduration init 1
  knote init 0
  kpan init 0
  kattack init 0
  kreverb init 0
  ktime timeinsts
  ievent_trig_lag_time = 0.1
  kget_event = (ktime > knext_event_time) ? 1 : 0
  if kget_event > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_serial", "iiffi", ivoice, kindex, itempo, ibasenote, iforward
  endif
  Saddress sprintf "/serial_event_%i", ivoice
  nextmsg:
  kmessage OSClisten gihandle, Saddress, "iffffff",  kindex, kdelta_time, knote, kduration, kpan, kattack, kreverb
  if kmessage == 0 goto done
    kevent_time_delay = (knext_event_time-ktime) + ievent_trig_lag_time
    ;printk2 ktime, ivoice
    if (kevent_time_delay < 0) then
      Swarning sprintfk "Warning : event overflow in voice %i at time %f", ivoice, ktime 
      puts Swarning, ktime
    endif
    event "i", 51, kevent_time_delay, kduration, iamp, knote, kpan, kattack, kreverb
    knext_event_time += kdelta_time
    kgoto nextmsg
  done:
endin


; sine tone instr 
instr 51
  iamp = ampdbfs(p4)
  inote = p5
  ipan = p6
  iattack = p7+0.0001
  ireverb = p8
  aenv madsr iattack*p3, 0.2, 0.2, 0.01
  a1 poscil aenv*iamp, cpsmidinn(inote)
  aL = a1*sqrt(1-ipan)
  aR = a1*sqrt(ipan)
  chnmix aL*ireverb, "reverbL"
  chnmix aR*ireverb, "reverbR"
  chnmix aL*(1-ireverb), "masterL"
  chnmix aR*(1-ireverb), "masterR"
endin

instr 98
  aL chnget "reverbL"
  aR chnget "reverbR"
  chnclear "reverbL"
  chnclear "reverbR"
  idecay = 0.9
  idamping = 6000
  aL, aR reverbsc aL, aR, idecay, idamping
  chnmix aL, "masterL"
  chnmix aR, "masterR"
endin

instr 99
  aL chnget "masterL"
  aR chnget "masterR"
  chnclear "masterL"
  chnclear "masterR"
  outs aL, aR
  ;fout "test.wav", 14, aL, aR
endin

</CsInstruments>
<CsScore>
/*
ivoice = p4
iamp = p5
ibasenote = p6
itempo_bpm = p7
itempo_factor = p8
iforward = p9
*/
#define SCORELEN #60#
i31 0 $SCORELEN 1 -16 60 80 1 1
i31 3.75 $SCORELEN 2 -16 72 80 0.5 1
i31 1 $SCORELEN 3 -16 84 80 0.25 0
i31 8.27 $SCORELEN 4 -16 48 80 1 0
i31 12 $SCORELEN 5 -26 96 80 4 0

i98 0 [$SCORELEN+18]
i99 0 [$SCORELEN+18]
e
</CsScore>
</CsoundSynthesizer>
