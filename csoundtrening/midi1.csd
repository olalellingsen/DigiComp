<CsoundSynthesizer> 

<CsOptions>             
 -odac
</CsOptions>            

<CsInstruments>         

instr 1

iamp = 5000
ipch = p4
idur = p3
ivar1 = idur/3
ivar2 = 2 * idur/3
ifreq = cpspch(ipch)

kenv linseg 0, ivar1, iamp, ivar2, 0
aLyd oscil kenv, ifreq
out aLyd
endin


</CsInstruments>

<CsScore>
i1 0 1 8.00
i1 1 1 8.04
i1 2 1 8.09
</CsScore>

</CsoundSynthesizer> 
