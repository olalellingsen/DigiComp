<CsoundSynthesizer>
<CsOptions>
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 128
nchnls = 2
0dbfs = 1

; this is where we set the L-system rules
gS_output = "A"
gS_rule_A = "CA"
gS_rule_B = "A"
gS_rule_C = "BBC"

; set note values for each of the symbols (A,B,C) 
giRhythm[] fillarray 1,2,0.5

; this opcode will use L-system rules to rewrite a global string variable
; we will use the underscore character ("_") to signify a new generation in the L-system
; the opcode has no inputs or outputs, it will only operate on the global string
opcode LSYS, 0, 0
  puts gS_output, 1 ; print the string, just for reference
  ilast_ strrindex gS_output, "_" ; find the last occurence of the "_" character
  S_input strsub gS_output, ilast_+1, -1 ; our input string is the part ofter the last underscore
  gS_output strcat gS_output, "_" ; then we append an underscore to the global string to show that we are now writing a new generation to the string
  while strlen(S_input) > 0 do ; we will consume the input string one by one character, continue until the string is empty
    S_char strsub S_input, 0, 1 ; get the first character in the string
    S_input strsub S_input, 1, -1 ; the rest of the string (minus the first character)
    if strcmp(S_char,"A") == 0 then ; if the character matches the symbol "A" ...
      gS_output strcat gS_output, gS_rule_A ; ...concatenate the contents of rule A to the global string
    elseif strcmp(S_char,"B") == 0 then ; same as above, for the symbol "B"
      gS_output strcat gS_output, gS_rule_B
    elseif strcmp(S_char,"C") == 0 then ; same as above, for the symbol "C"
      gS_output strcat gS_output, gS_rule_C
    endif
  od
endop

; Lsys string rewriting
instr 1
  ; we want to optionally be able to initialize the global string (when starting the first event, the "root" of the tree")
  if p4 != 0 then ; if p4 contains a symbol, initialize the string, otherwise leave it as it is
    gS_output strget p4
  endif
  igen = p5 ; keep track of which generation we are currently processing
  imaxgen = p6 ; set the maximum number of generations that we will process
LSYS ; call the LSYS user defined opcode, rewriting the global string gS_outout
  igen += 1 ; increment the generation counter
  if igen < imaxgen then ; if we have not yet processed the desired number of generations...
    event_i "i", p1, 0, 1, 0, igen, imaxgen ; ... the instrument calls itself (with the incremented generation counter)
  endif
endin

; read global string and make notes
instr 2
  itempo = p4
  ktempo init 1 ; will be modified by the values from the L-system later
  ktrig metro itempo*ktempo
  knote = p5 
  S_input strcat ".", gS_output ; For arcane reasons, we need to add an extra symbol to the start of the string
  ; This is because the k-rate string opcodes on the next few lines run both at init time and at k-time
  ; .. thus the very first symbol in the string will be eaten at init pass
  kprint_enable init 0 ; this is used to disable printing the "String empty" message at init time
  kspecial = 0 ; special treatment each time we have a new generation
  if ktrig > 0 then ; when the metronome ticks...
  generation_skip_label:
      if strlenk(S_input) > 0 then ; we will consume the input string one by one character, continue until the string is empty
	S_char strsubk S_input, 0, 1 ; get the first character in the string
	S_input strsubk S_input, 1, -1 ; the rest of the string (minus the first character)
	if strcmpk(S_char, "A") == 0 then ; if the character matches the symbol "A" ...
	  ktempo = giRhythm[0] ; read the interval from the global array and modify our note value
	elseif strcmpk(S_char, "B") == 0 then
	  ktempo = giRhythm[1]
	elseif strcmpk(S_char, "C") == 0 then
	  ktempo = giRhythm[2]
	elseif strcmpk(S_char, "_") == 0 then ; if the character matches the symbol "_" ...
	  kgoto generation_skip_label ;here, we just skip to the next character when we encounter the generation underscore
	endif
	kamp = -5
	ipan = 0.5
	kdur = 1/itempo
	event "i", 51, 0, kdur, kamp, knote, ipan ; create note event
      else ; this happens if the string has been completely consumed
	kprint_enable = 1
	S_message = "INFO: String empty, stopping instrument"
	puts S_message, kprint_enable
	event "e", 0, 1, 0 ; add event to tell Csound the score is now over, so we can exit Csound (one second later)
	turnoff2 p1, 4, 0 ; instrument turns off itself
      endif
    endif  
endin

; tone instr
instr 51
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = p6

  iAttack = 0.005
  iDecay = 0.05
  iSustain = 0.3
  iRelease = 0.01
  amp madsr iAttack, iDecay, iSustain, iRelease

  a1 oscili iamp, icps
  aL = a1*sqrt(1-ipan)*amp
  aR = a1*sqrt(ipan)*amp
  outs aL, aR
endin

</CsInstruments>
<CsScore>
; Lsystem generator
; startsymbol first_generation  max_generations
i1 0 1 "A" 1 5

; read the global string and make note events
; p4 = tempo, p5 = start note
i2 1 10 4 60

e
</CsScore>
</CsoundSynthesizer>
