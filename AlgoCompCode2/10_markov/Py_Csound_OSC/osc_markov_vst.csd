<Cabbage>
form size(580, 470), caption("Markov melody"), pluginId("mmel"), colour(30,35,40)

checkbox bounds(10, 10, 60, 25), channel("Voice1"), text("Play"), colour:0(0,142,0),  colour:1(142, 0, 0)
nslider channel("Startnote1"), bounds(110, 10, 50, 25), text("Startnote"), range(36, 96, 60, 1, 1)
button bounds(10, 70, 85, 30), channel("Clear"), text("Clear"), colour:0(0,142,0),  colour:1(142, 0, 0), latched(0)
button bounds(10, 110, 85, 30), channel("Record"), text("Record"), colour:0(0,142,0),  colour:1(142, 0, 0), latched(1)

csoundoutput bounds(10, 200, 380, 150)
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -m0 -+rtmidi=NULL -Q0 -M0
</CsOptions>

<CsInstruments>
ksmps = 32
nchnls = 2
0dbfs = 1

massign -1, 11

gihandle OSCinit 9999

; gui handler
instr 1
  ivoice = 1
  Svoice sprintf "Voice%i", ivoice
  Sstartnote sprintf "Startnote%i", ivoice
  kstartnote chnget Sstartnote
  kactive chnget Svoice
  ktrigon trigger kactive, 0.5, 0
  ktrigoff trigger kactive, 0.5, 1
  igenerator_instrument = 31+(ivoice*0.01)
  if ktrigon > 0 then
    event "i", igenerator_instrument, 0, -1, ivoice, kstartnote
  endif
  if ktrigoff > 0 then
    event "i", -igenerator_instrument, 0, .1, ivoice
  endif
  kclear chnget "Clear"
  OSCsend kclear+1, "127.0.0.1",9901, "/markov_clear", "i", ivoice
   
endin

; record markov melody
instr 11
  inote notnum
  irecord chnget "Record"
  print irecord
  OSCsend irecord, "127.0.0.1",9901, "/markov_record", "i",  inote
endin

; play markov melody
instr 31
  ivoice = p4
  iamp = -7
  istartnote = p5
  knote init istartnote
  itempo_bpm = 120
  itempo_bps = itempo_bpm/60
  itempofactor = 1
  itempo = itempo_bps*itempofactor
  kindex init 0
  kdelta_time init 0
  knext_event_time init 0
  kduration init 1
  ;knote init 0
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
    event "i", 51, kevent_time_delay, kduration, iamp, knote, kpan
    event "i", 201, kevent_time_delay, kduration, iamp, knote
    knext_event_time += kdelta_time
    kgoto nextmsg
  done:
endin

; sine tone instr 
instr 51
  ;print p2
  iamp = ampdbfs(p4)
  inote = p5
  if inote == -1 then
    Swarning = "Warning: Bad note from markov"
    puts Swarning, 1
    turnoff
  endif
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

;***************************************************
instr	201
  ; midi  output

  iamp = p4
  idB_range  = 70
  ivel = pow((1+(iamp/idB_range)),2) * 127
  print iamp, ivel
  inote = p5
  ichan = 1

  idur = (p3 < 0 ? 999 : p3)	; use very long duration for realtime events, noteondur will create note off when instrument stops
  idur = (p3 < 0.1 ? 0.1 : p3)	; avoid extremely short notes as they won't play

  noteondur ichan, inote, ivel, idur
endin

</CsInstruments>
<CsScore>
#define SCORELEN #86400#
i1 0 $SCORELEN ; gui handler
i99 0 $SCORELEN ; reverb
e
</CsScore>
</CsoundSynthesizer>
