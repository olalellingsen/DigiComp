<Cabbage>
form size(580, 470), caption("Serial composition"), pluginId("scom"), colour(30,35,40)

checkbox bounds(10, 10, 35, 30), channel("Voice1"), colour:0(0,142,0),  colour:1(142, 0, 0)
nslider channel("Amp1"), bounds(50, 10, 50, 25), text("Amp"), range(-96, 0, -8)
nslider channel("Pan1"), bounds(105, 10, 50, 25), text("Pan"), range(0.0, 1.0, 0.5)
nslider channel("Note1"), bounds(160, 10, 50, 25), text("Note"), range(36, 96, 60)
nslider channel("Tempo1"), bounds(215, 10, 50, 25), text("Tempo"), range(0.1, 20, 1)
texteditor channel("Pitches1"), bounds(265, 20, 150, 15), text("1,2,3..."), colour("black"), fontColour("white"), caretColour("white")
label bounds(220, 5, 150, 12), text("Pitches")
texteditor channel("Rhythm1"), bounds(425, 20, 150, 15), text("1,0.5"), colour("black"), fontColour("white"), caretColour("white")
label bounds(425, 5, 150, 12), text("Rhythm")

checkbox bounds(10, 60, 35, 30), channel("Voice2"), colour:0(0,142,0),  colour:1(142, 0, 0)
nslider channel("Amp2"), bounds(50, 60, 50, 25), text("Amp"), range(-96, 0, -8)
nslider channel("Pan2"), bounds(105, 60, 50, 25), text("Pan"), range(0.0, 1.0, 0.5)
nslider channel("Note2"), bounds(160, 60, 50, 25), text("Note"), range(36, 96, 72)
nslider channel("Tempo2"), bounds(215, 60, 50, 25), text("Tempo"), range(0.1, 20, 1)
texteditor channel("Pitches2"), bounds(265, 70, 150, 15), text("1,2,3..."), colour("black"), fontColour("white"), caretColour("white")
label bounds(220, 45, 150, 12), text("Pitches")
texteditor channel("Rhythm2"), bounds(425, 70, 150, 15), text("1,0.5"), colour("black"), fontColour("white"), caretColour("white")
label bounds(425, 45, 150, 12), text("Rhythm")


csoundoutput bounds(10, 200, 380, 150)
</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n
</CsOptions>

<CsInstruments>
ksmps = 32
nchnls = 2
0dbfs = 1

gihandle OSCinit 9999

instr 1
  ivoice = p4
  Svoice sprintf "Voice%i", ivoice
  kactive chnget Svoice
  ktrigon trigger kactive, 0.5, 0
  ktrigoff trigger kactive, 0.5, 1
  igenerator_instrument = 31+(ivoice*0.01)
  if ktrigon > 0 then
    event "i", igenerator_instrument, 0, -1, ivoice
  endif
  if ktrigoff > 0 then
    event "i", -igenerator_instrument, 0, .1, ivoice
  endif
  Spitch_chan sprintf "Pitches%i", ivoice
  Spitches chnget Spitch_chan
  knewpitches changed Spitches
  Srhythm_chan sprintf "Rhythm%i", ivoice
  Srhythm chnget Srhythm_chan
  knewrhythm changed Srhythm
  kseries = 0
  if knewpitches > 0 then
    kseries = 1
    Svalues strcpyk Spitches
  elseif knewrhythm > 0 then
    kseries = 2
    Svalues strcpyk Srhythm
  endif
  if knewrhythm+knewpitches > 0 then
    Scoreline sprintfk {{i 10 0 1 %i %i "%s"}}, kseries, ivoice, Svalues
    scoreline Scoreline, 1
  endif

endin

instr 10
  iseries = p4
  ivoice = p5
  Svalues strget p6
  iArr[] string2array Svalues
  printarray iArr
  OSCsend 1, "127.0.0.1", 9901, "/csound_serial_setseries", "fif", iseries, ivoice, -1 ; clear previous series
  kindex init 0
  while kindex < lenarray(iArr) do
    kval = iArr[kindex]
    OSCsend kindex+1, "127.0.0.1", 9901, "/csound_serial_setseries", "fif", iseries, ivoice, kval
    kindex += 1
  od
endin

; play serial melody
instr 31
  ivoice = p4
  print p1, p4
  Samp sprintf "Amp%i", ivoice
  kamp chnget Samp
  Span sprintf "Pan%i", ivoice
  kpan chnget Span
  Sbasenote sprintf "Note%i", ivoice
  kbasenote chnget Sbasenote
  Stempo sprintf "Tempo%i", ivoice
  ktempofactor chnget Stempo
  khost_bpm chnget "HOST_BPM"
  ktempo_bps = khost_bpm/60
  ktempo = ktempo_bps*ktempofactor
  kindex init 0
  kdelta_time init 0
  knext_event_time init 0
  kduration init 1
  knote init 0
  ktime timeinsts
  ievent_trig_lag_time = 0.1
  kget_event = (ktime > knext_event_time) ? 1 : 0
  if kget_event > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_serial", "iiff",ivoice, kindex, ktempo, kbasenote
  endif
  Saddress sprintf "/serial_event_%i", ivoice
  nextmsg:
  kmessage OSClisten gihandle, Saddress, "ifff",  kindex, kdelta_time, knote, kduration
  if kmessage == 0 goto done
    kevent_time_delay = (knext_event_time-ktime) + ievent_trig_lag_time
    if (kevent_time_delay < 0) then
      Swarning sprintfk "Warning : event overflow in voice %i at time %f", ivoice, ktime 
      puts Swarning, ktime
    endif
    event "i", 51, kevent_time_delay, kduration, kamp, knote, kpan
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

instr 99
  aL chnget "masterL"
  aR chnget "masterR"
  chnclear "masterL"
  chnclear "masterR"
  outs aL, aR
endin

</CsInstruments>
<CsScore>
i1 0 86400 1 ; for voice 1
i1 0 86400 2 ; for voice 2
i99 0 86400 ; master out

</CsScore>
</CsoundSynthesizer>
