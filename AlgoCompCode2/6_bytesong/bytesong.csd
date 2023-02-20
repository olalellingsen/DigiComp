<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
  sr     = 48000
  ksmps  = 6
  nchnls = 1

;#define PAT #kt*((kt>>12|kt>>8)&63&kt>>4)# ; pattern discovered by viznut
;#define PAT #(kt*(kt>>5|kt>>8))>>(kt>>15)# ;by tejeez
#define PAT #kt*((kt>>9|kt>>13)&25&kt>>6)# ;by visy
;#define PAT #kt*(kt>>11&kt>>8&123&kt>>3)# ;by tejeez
;#define PAT #kt*(kt>>((kt>>9|kt>>8))&63&kt>>4)# ;by visy
;#define PAT #(kt>>6|kt|kt>>(kt>>16))*10+((kt>>11)&7)# ;by viznut
;#define PAT #(av>>1)+(av>>4)+kt*(((kt>>16)|(kt>>6))&(69&(kt>>9)))# ;by pyryp
;#define PAT #kt*5&(kt>>7)|kt*3&(kt*4>>10)# ;by miiro
;#define PAT #(kt>>7|kt|kt>>6)*10+4*(kt&kt>>13|kt>>6)# ;by viznut
;#define PAT #((-kt&4095)*(255*kt*(kt&kt>>13))>>12)+(127&kt*(234&kt>>8&kt>>3)>>(3&kt>>14))# ;by tejeez

instr 1
  kt init 0
  av init 0
  av = $PAT & 255
  asrc = av << 7
  asrc butlp asrc, 3500
  asrc dcblock asrc
  kt = kt+1
  out asrc*0.9
endin

</CsInstruments>
<CsScore>
i1 0 40
</CsScore>
</CsoundSynthesizer>
