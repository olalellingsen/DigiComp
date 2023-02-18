<CsoundSynthesizer> 

<CsOptions>             

</CsOptions>            

<CsInstruments>         

sr      =   44100   //Sampling rate (default: 44100)
kr      =   4410    //Kontroll rate - for k-rate-variabler (default: 4410)
nchnls  =   2       //Antall kanaler tilgjengelig (ut) (default: 1)  
0dbfs   =   1       //referanseamplitude - (default: 32768)
                    //0dbfs = 1 => Normalisert referanseamplitude

instr 1
iMaxamp = 1
kBi oscil   iMaxamp, 0.25

kUnipolar = (kBi + iMaxamp) * 0.5

printk  0.2, kUnipolar


endin

</CsInstruments>

<CsScore>

</CsScore>

</CsoundSynthesizer> 