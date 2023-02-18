<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>

<CsInstruments>
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

gihandle OSCinit 9999 ; set the network port number where we will receive OSC data from Python

; play serial melody
instr 31
  ivoice = p4 ; use separate voice numbmers for polyphonic operation
  iamp = p5 ; basic amplitude
  ipan = p6 ; pan position 
  ibasenote = p7 ; the base note number (melody intervals are calculated based on this pitch)
  itempo_bpm = p8 ; the tempo in beats per minute
  itempo_bps = itempo_bpm/60 ; calculate tempo as beats per second
  itempofactor = p9 ; adjust the tempo in relation to the bpm (for example x2, x4, etc)
  itempo = itempo_bps*itempofactor ; calculate the real tempo we will be using
  kindex init 0 ; the index counts the events generated for this voice
  kdelta_time init 0 ; delta time is the relative time until the next event (in seconds)
  knext_event_time init 0 ; absolute time for next event (seconds)
  kduration init 1 ; the duration for the next event
  knote init 0 ; the note nummber for the next event
  ktime timeinsts ; read the system clock (time since start of performance)
  ievent_trig_lag_time = 0.1 ; we add some latency to allow for OSC communication jitter
  kget_event = (ktime > knext_event_time) ? 1 : 0 ; if current time is greater than the time for the next event, then activate
  if kget_event > 0 then
    OSCsend kindex+1, "127.0.0.1",9901, "/csound_serial", "iifi",ivoice, kindex, itempo, ibasenote ; send OSC request to Python, get data for next event
  endif
  Saddress sprintf "/serial_event_%i", ivoice ; we will use separate OSC address for each voice, so we need to format the string with the voice number
  nextmsg: ; this is a label, that allow us to jump here from somewhere else in the instrument

  ; ***
  ; *** THIS  IS WHERE WE GET PARAMETER VALUES FROM PYTHON ***
  kmessage OSClisten gihandle, Saddress, "ifff",  kindex, kdelta_time, knote, kduration ; receive OSC data from Python, the data for the next event
  
  if kmessage == 0 goto done
    kevent_time_delay = (knext_event_time-ktime) + ievent_trig_lag_time ; calculate the delay that will enable accurate sync for this event
    if (kevent_time_delay < 0) then ; if the delay is less than zero, something is wrong, so we will want to be warned
      Swarning sprintfk "Warning : event overflow in voice %i at time %f", ivoice, ktime ; format the warning text string
      puts Swarning, ktime ; print warning string
    endif
    event "i", 51, kevent_time_delay, kduration, iamp, knote, ipan ; trigger the instrument event based on the data we got from Python
    knext_event_time += kdelta_time ; update the next event time, ready for the next event
    kgoto nextmsg ; jump back to the OSC listen line, to see if there are more messages waiting in the network buffer
  done: ; this is a label, that allow us to jump here from somewhere else in the instrument
endin

; sine tone instr 
instr 51
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
  fout "test.wav", 14, aL, aR
endin

</CsInstruments>
<CsScore>
/*
; just a reminder about what the p-fields mean for instr 31
ivoice = p4
iamp = p5
ipan = p6
ibasenote = p7
itempo_bpm = p8
itempo_factor = p9
*/
#define SCORELEN #30# ; a score macro that allow us to use the name of the macro (SCORELEN) as a variable later in the score
;  start  dur         voice   amp     pan    base    tempo   tempofactor 
i31 0     $SCORELEN   1       -16     0      60      60      2
i31 3     $SCORELEN   2       -16     1      72      60      3

i99 0 [$SCORELEN+5]
e
</CsScore>
</CsoundSynthesizer>
