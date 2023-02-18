<CsoundSynthesizer> 

<CsOptions>             
 -M0 -odac -b128 -B256 ;Bufferinnstilling: B er vanligvis dobbelt av b
</CsOptions>            

<CsInstruments>         
instr 1
;              chan     ctrl#    min   max
kVal   ctrl7    1,      1,      0,    1000

iCps cpsmidi ;ingen input
iAmp ampmidi 10000

kGliss = iCps + kVal

aSnd oscil iAmp, kGliss

out aSnd

endin

</CsInstruments>

<CsScore>

</CsScore>

</CsoundSynthesizer> 