<CsoundSynthesizer> 

<CsOptions>             
-M0 -odac -b128 -B256 ;Bufferinnstilling: B er vanligvis dobbelt av b
</CsOptions>            

<CsInstruments>         

//Header 
0dbfs   =   1       //referanseamplitude - (default: 32768)
                    //0dbfs = 1 => Normalisert referanseamplitude

instr 1

iAmp ampmidi 0.2
iCps cpsmidi

iLFOAmp     =   iCps * 0.05
iLFOFrek    =   5


kLFO    oscil   iLFOAmp, iLFOFrek
kVib    =       iCps + kLFO

aLyd    oscil   iAmp, kVib

out     aLyd

endin

</CsInstruments>

<CsScore>
</CsScore>
</CsoundSynthesizer> 