<Cabbage>
form size(460, 340), caption("PartikkelSynchronizer"), pluginId("psnc")
label bounds(390,15,65,12), text("host subdiv")
nslider bounds(390,25,25,25), channel("subdiv"), range(1,16,4,1,1)

rslider bounds(10, 5, 60, 60), text("graindur"), channel("graindur"), range(0.1, 3, 0.5, 0.5)
rslider bounds(70, 5, 60, 60), text("ad_ratio"), channel("grad_ratio"), range(0.0, 1, 0.05, 1, 0.001)
rslider bounds(130, 5, 60, 60), text("grsustain"), channel("grsustain"), range(0, 1, 0)
rslider bounds(190, 5, 60, 60), text("width"), channel("width"), range(0.0, 1.0, 0.5)
rslider bounds(250, 5, 60, 60), text("amask"), channel("ampmasklen"), range(1, 8, 1, 1, 1)
rslider bounds(310, 5, 60, 60), text("vol"), channel("vol"), range(0.0, 1.0, 0.5)

rslider bounds(10, 75, 60, 60), text("sync_phase"), channel("sync_phase_amt"), range(0, 0.5, 0.04, 0.5, 0.0001)
rslider bounds(70, 75, 60, 60), text("sync_rate"), channel("sync_rate_amt"), range(0, 0.5, 0.07, 0.5, 0.0001)
;rslider bounds(130, 75, 60, 60), text("rate_response"), channel("rate_response"), range(0, 1, 0, 0.5, 0.0001)
button bounds(150, 90, 80, 25), channel("clear_all"), text("clear all"), latched(0), colour:0("green"), colour:1("red")
button bounds(240, 90, 80, 25), channel("disturb"), text("disturb"), latched(0), colour:0("green"), colour:1("red")
nslider bounds(320, 90, 60, 25), channel("disturb_amt"), text("disturb_amt"), range(0.0, 1.0, 0.1)

csoundoutput bounds(5, 140, 450, 200)

</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-dm0 -n -+rtmidi=null -M0 -Q0
</CsOptions>
<CsInstruments>

;***************************************************
; globals
;***************************************************

ksmps = 64
nchnls = 2
0dbfs	= 1
massign -1, 1

;***************************************************
;ftables
;***************************************************

; classic waveforms
giSine ftgen	0, 0, 65537, 10, 1 ; sine wave
giCosine	ftgen	0, 0, 8193, 9, 1, 1, 90 ; cosine wave
giTri ftgen	0, 0, 8193, 7, 0, 2048, 1, 4096, -1, 2048, 0 ; triangle wave

; grain envelope tables
giSigmoRise ftgen	0, 0, 8193, 19, 0.5, 1, 270, 1 ; rising sigmoid
giSigmoFall ftgen	0, 0, 8193, 19, 0.5, 1, 90, 1 ; falling sigmoid
giExpFall	ftgen	0, 0, 8193, 5, 1, 8193, 0.00001 ; exponential decay
giTriangleWin ftgen	0, 0, 8193, 7, 0, 4096, 1, 4096, 0 ; triangular window
giSquareWin ftgen	0, 0, 8193, 7, 1, 8192, 1 ; square window (all on)

giVoices ftgen 0, 0, 127, 2, 0 ; to hold active voices
giVoiceclear ftgen 0, 0, 127, 2, 0 ; empty, to reset active voices
giparticlinstr = 11


;***************************************************

opcode RhythmPLL, kkk, kkkkkkk
  ; PLL for rhythmic synchronization
  ; Oeyvind Brandtsegg 2021 oyvind.brandtsegg@ntnu.no
    ; Licence: Creative commons CC BY (use as you like but you *must* credit)
    ; outputs: pulse, phase (ramp), and frequency
    ; inputs: ext clock pulse, init frequency, freq adjust gain, phase adjust gain
    k1trig, kfq2, kgain, kphasegain, kin2, kosc2, k2trig xin

    ; oscillator
    if kin2 == 0 then
      kfq2 init i(kfq2)
      kosc2 init 0
      kosc2 += (kfq2/kr)
      kosc2 = kosc2 > 1 ? 0 : kosc2
      k2trig trigger kosc2, 0.5, 1
    endif

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

;******************************************************
; control instr
instr 1
  inote notnum
  print inote
  iprevnote chnget "note"
  print inote, iprevnote
  chnset inote, "note"
  itime times
  iprevtime chnget "time"
  print itime, iprevtime
  chnset itime, "time"
  instnum = giparticlinstr+inote*0.001
  if inote == iprevnote then
    if table(inote, giVoices) == 0 then
      idelta = itime - iprevtime
      print idelta
      event_i "i", instnum, 0, -1, inote, inote, 1/idelta
      tablew 1, inote, giVoices
      print table(inote, giVoices)
    endif
  else
    event_i "i", -instnum, 0, .1
    tablew 0, inote, giVoices
    print table(inote, giVoices)
  endif
endin

instr 2
  ; gui control handling
  kclear chnget "clear_all"
  ktrig_clear trigger kclear, 0.5, 0
  if ktrig_clear > 0 then
    turnoff2 giparticlinstr, 0, 1
    tablecopy giVoices, giVoiceclear
  endif
endin

; master metro
instr 4
  kbpm chnget "HOST_BPM"
  kbpm = (kbpm == 0 ? 60 : kbpm)
  ksubdiv chnget "subdiv"
  ksubdiv = (ksubdiv == 0 ? 1 : ksubdiv)
  kpulse metro (kbpm/60)*ksubdiv*0.25
  chnset kpulse, "host"
  ; outch 2, a(kpulse)*0.5
endin

; set chn value
instr 5
  Schn strget p4
  ival = p5
  puts Schn, 1
  print ival
  chnset ival, Schn
endin

; always sync to global metro
; run global metro at kbpm always
; control instr: 2 taps on same note:
;	- get delta, set gr.rate and pitch, trigger event
; same note again: trigger event off
; long fade in, xtratim and fade out, 4 secs?
; p.instr can be started as many times as needed
;


;******************************************************
; partikkel instr
;******************************************************
instr 11
  print p4, p5, p6
  ivoice = p4
  kgrainrate init p6
  ipartikkelid = ivoice

  ; select source waveform 1, (the other 3 waveforms can be set inside the include file partikkel_basic_settings.inc)
  kwaveform1 = giSine	; source audio waveform 1
  kwavekey1 = 1

  kdistribution = 0.0 ; grain random distribution in time
  idisttab ftgentmp 0, 0, 16, 16, 1, 16, -10, 0 ; probability distribution for random grain masking
  ienv_attack = giSigmoRise ; grain attack shape (from table)
  ienv_decay = giSigmoFall ; grain decay shape (from table)
  kenv2amt = 0.0 ; amount of secondary enveloping per grain (e.g. for fof synthesis)
  ksweepshape = 0.5 ; grain wave pitch sweep shape (sweep speed), 0.5 is linear sweep
  iwavfreqstarttab ftgentmp 0, 0, 16, -2, 0, 0, 1	; start freq scalers, per grain
  iwavfreqendtab ftgentmp	0, 0, 16, -2, 0, 0, 1 ; end freq scalers, per grain
  awavfm = 0
  icosine = giCosine ; needs to be a cosine wave to create trainlets
  kTrainCps = 100 ; set trainlet freq
  knumpartials = 7 ; number of partials in trainlet
  kchroma = 3 ; chroma, falloff of partial amplitude towards sr/2
  ; wave mix masking.
  ; Set gain per source waveform per grain,
  ; in groups of 5 amp values, reflecting source1, source2, source3, source4, and the 5th slot is for trainlet amplitude.
  iwaveamptab ftgentmp 0, 0, 32, -2, 0, 0, 1,0,0,0,0

  async = 0
  kext_clock chnget "host"
  kfreq_gain chnget "sync_rate_amt"
  kphase_gain chnget "sync_phase_amt"
  kuse_myclock = 1
  kmypulse init 0
  kmyphase init 0
  kpulse2,kphase2,kgrainrate RhythmPLL kext_clock, kgrainrate, kfreq_gain, kphase_gain, kuse_myclock, kmyphase, kmypulse
  kdisturb chnget "disturb"
  kdisturb_amt chnget "disturb_amt"
  kdisturb_amt /= (kr/4)
  kdev rspline 1-(kdisturb_amt*0.5), 1+kdisturb_amt, kgrainrate*0.5, kgrainrate*2
  kgrainrate = (kdisturb > 0 ? kgrainrate*kdev : kgrainrate)

  kamp = 1
  inum = p5
  kgrainpitch	= 1;chnget "grainpitch"
  kwavfreq = cpsmidinn(inum+12)*kgrainpitch
  krel_dur chnget "graindur"
  kduration divz krel_dur*1000, kgrainrate, 100
  ka_d_ratio chnget "grad_ratio"
  ksustain_amount chnget "grsustain"
  ksamplepos1 = 0
  asamplepos1 upsamp ksamplepos1
  krandommask = 0

  ; gain masking table, amplitude for individual grains
  kampmasklen chnget "ampmasklen"
  kampmasklen = int(kampmasklen)-1
  igainmasks ftgentmp	0, 0, 16, -2, 0, 2, 1, 0.4, 0.7, 0.5, 0.3, 0.5, 0.4, 0.3
  tablew kampmasklen, 1, igainmasks

  ; channel masking table, output routing for individual grains (zero based, a value of 0.0 routes to output 1)
  ichannelmasks	ftgentmp	0, 0, 16, -2, 0, 1, 0, 1

  ;*******

  a1,a2 partikkel \
    kgrainrate, \
    kdistribution, idisttab, async, \
    kenv2amt, -1, ienv_attack, ienv_decay, \
    ksustain_amount, ka_d_ratio, kduration, \
    kamp, \
    igainmasks, \
    kwavfreq, \
    ksweepshape, iwavfreqstarttab, iwavfreqendtab, \
    awavfm, -1, -1, \
    icosine, kTrainCps, knumpartials, kchroma, \
    ichannelmasks, \
    krandommask, \
    kwaveform1, kwaveform1, kwaveform1, kwaveform1, \
    iwaveamptab, \
    asamplepos1, asamplepos1, asamplepos1, asamplepos1, \
    kwavekey1, kwavekey1, kwavekey1, kwavekey1, \
    100, ipartikkelid

  apulse, aphase partikkelsync ipartikkelid
  kSig[] init ksmps
  kSig shiftin apulse
  kmypulse =sumarray(kSig)
  kmyphase downsamp aphase

  iatck = 3
  irel = 3
  aenv madsr iatck, 0.3, 0.7, irel
  kwidth chnget "width"
  kw = 0.5+(kwidth*0.5)
  aL = ((a1*sqrt(kw)) + (a2*sqrt(1-kw)))*aenv
  aR = ((a1*sqrt(1-kw)) + (a2*sqrt(kw)))*aenv
  kvol chnget "vol"
  kvol tonek kvol, 0.2
  outs aL*kvol*0.5, aR*kvol*0.5

endin
;******************************************************

</CsInstruments>
<CsScore>

i2 0 86400 ; gui control handling
i4 0 86400 ; master metro
e
</CsScore>
</CsoundSynthesizer>
