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
gS_rule_A = "CAB"
gS_rule_B = "AB"
gS_rule_C = "BC"

; set note values for each of the symbols (A,B,C) 
giNotes[] fillarray 0, 3, 5

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

; read global string and start another instrument that will make notes for each generation layer
instr 2
  ibase_duration = p3 ; duration of the whole layered "generation tree"
  iamp = p4 ; amplitude for each event
  ibase_note = p5 ; the starting note of the first generation
  igeneration_offset = p6 ; pitch offset (semitones) per generation
  igeneration = 1 ; initial generation
  ionce_per_gen = 1 ; a switch that allows us to do something once per generation
  ipopulation_size = 0 ; the size of the population (number of items) in each generation (updated below)
  ievent_counter = 0 ; keep track of where we are, when we iterate over each generation
  S_input = gS_output ; get the string containing all generations, the whole tree
  while strlen(S_input) > 0 do ; we will consume the input string one by one character, continue until the string is empty
    if ionce_per_gen > 0 then ; when reading the first item of a generation...
      ipopulation_size strindex S_input, "_" ; ... check how many items we have in this generation
      if ipopulation_size == -1 then
	ipopulation_size strlen S_input ; the last generation does not have an underscore at the end, so we just check size of string
      endif
      ievent_counter = 0 ; reset event counter each time we start processing a new generation
      ionce_per_gen = 0 ; reset, so we do these operations only once per generation
    endif
    iskip_this_event = 0 ; normally, we will not skip (only at the underscore character, see below)
    S_char strsub S_input, 0, 1 ; get the first character in the string
    S_input strsub S_input, 1, -1 ; the rest of the string (minus the first character)
    if strcmp(S_char, "A") == 0 then ; if the character matches the symbol "A" ...
      inote = giNotes[0] ; read the note number from the global array
    elseif strcmp(S_char, "B") == 0 then
      inote = giNotes[1]
    elseif strcmp(S_char, "C") == 0 then
      inote = giNotes[2]
    elseif strcmp(S_char, "_") == 0 then ; if the character matches the symbol "_" ...
      iskip_this_event = 1 ;we can do something special with the underscore, here we just skip creating an event for it
      igeneration += 1 ; increment generation counter when we encounter the underscore
      ionce_per_gen = 1 ; set the "once per generation" flag 
    endif
    if iskip_this_event == 0 then ; do this for all items, except the underscore (see above)
      ; generate events, where each generation is layered on top of each other
      ; The nummber of items in a generation determines the duration and start time (rhythm)
      idur = ibase_duration / ipopulation_size ; duration for each event in a generation depends on how many events are in this generation
      istart_time = (ievent_counter/ipopulation_size) * ibase_duration ; increment the start time, so that each event is evenly distributed over the base duration
      inotenum = ibase_note + inote + ((igeneration-1)*igeneration_offset) ; offset pitch for each generation
      iamp_gen = iamp - (igeneration*2) ; each new generation gets a slightly lower amplitude here
      ipan = 0.5
      event_i "i", 51, istart_time, idur, iamp_gen, inotenum, ipan ; create note event
      ievent_counter += 1
    endif
    od
  S_message = "INFO: String empty, all events dispersed"
  puts S_message, 1  
endin
  
; tone instr
instr 51
  iamp = ampdbfs(p4)
  icps = cpsmidinn(p5)
  ipan = p6

  iAttack = 0.005
  iDecay = p3*0.3
  iSustain = 0.7
  iRelease = 0.01
  amp madsr iAttack, iDecay, iSustain, iRelease

  a1,a2 diskin "PMMH_Snare_Thick.wav", icps/440 ; play sample at pitch relative to (440 Hz) base pitch
  aL = a1*sqrt(1-ipan)*amp*iamp
  aR = a2*sqrt(ipan)*amp*iamp
  outs aL, aR
endin

</CsInstruments>
<CsScore>
; Lsystem generator
; startsymbol first_generation  max_generations
i1 0 1 "A" 1 7

; read the global string and make note events
; p3 = duration of the whole pitch "tree"
; p4 = amplitude scaling
; p5 = base pitch for the "root" of the tree
; p6 = pitch offset for each new generation
i2 1 10 -10 36 7

; same thing again, just starting from the root symbol "B"
i1 11 1 "B" 1 7
i2 12 10 -10 36 7

; same thing again, just starting from the root symbol "C"
i1 22 1 "C" 1 7
i2 23 10 -10 36 7

e
</CsScore>
</CsoundSynthesizer>
