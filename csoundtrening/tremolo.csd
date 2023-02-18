<CsoundSynthesizer> 

<CsOptions>             
-M0 -odac -b128 -B256 ;Bufferinnstilling: B er vanligvis dobbelt av b
</CsOptions>            

<CsInstruments>         

//Header 
0dbfs   =   1       //referanseamplitude - (default: 32768)
                    //0dbfs = 1 => Normalisert referanseamplitude

instr 1

iAmp ampmidi    0.2
iFrek cpsmidi

iLFOAmp     =       iAmp * 0.8
iLFOFrek    =       3
kLFO        lfo     iLFOAmp, iLFOFrek
kTrem       =       iAmp + kLFO

aLyd    oscil   kTrem, iFrek

out     aLyd

endin

</CsInstruments>

<CsScore>
</CsScore>
</CsoundSynthesizer>  