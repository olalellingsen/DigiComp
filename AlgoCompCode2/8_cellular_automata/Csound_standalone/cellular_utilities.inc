; opcodes for cellular automata
; Oeyvind Brandtsegg 2017, 2023

opcode ca_update, i[], i[]i[]
  ; process one generation of the Cellular Automation
  iCells[], iRule[] xin
  iOutput[] init lenarray(iCells)
  icount = 0
  while icount < lenarray(iCells) do
    icell = iCells[icount]
    ileft = iCells[wrap((icount-1),0,lenarray(iCells))]
    iright = iCells[wrap((icount+1),0,lenarray(iCells))]
    if (ileft == 1) && (icell == 1) && (iright == 1) then
      iOutput[icount] = iRule[0]
    elseif (ileft == 1) && (icell == 1) && (iright == 0)  then
      iOutput[icount] = iRule[1]
    elseif (ileft == 1) && (icell == 0) && (iright == 1) then
      iOutput[icount] = iRule[2]
    elseif (ileft == 1) && (icell == 0) && (iright == 0) then
      iOutput[icount] = iRule[3]
    elseif (ileft == 0) && (icell == 1) && (iright == 1) then
      iOutput[icount] = iRule[4]
    elseif (ileft == 0) && (icell == 1) && (iright == 0) then
      iOutput[icount] = iRule[5]
    elseif (ileft == 0) && (icell == 0) && (iright == 1) then
      iOutput[icount] = iRule[6]
    elseif (ileft == 0) && (icell == 0) && (iright == 0) then
      iOutput[icount] = iRule[7]
    endif
    icount += 1
  od
  xout iOutput
endop

opcode ca_print_cells, 0, i[]
  ; print one generation of the Cellular Automation
  iCells[] xin
  icount = 0
  while icount < lenarray(iCells) do
    icell = iCells[icount]
    if icell == 1 then
      Scell = "* "
    else
      Scell = ". "
    endif
    prints(Scell)
    icount += 1
  od
  prints("\n")
endop

opcode make_binary, i[], i
  ; make binary
  irule xin
  iRule[] fillarray (irule >> 7) & 1, (irule >> 6) & 1,
  (irule >> 5) & 1, (irule >> 4) & 1,
  (irule >> 3) & 1, (irule >> 2) & 1,
  (irule >> 1) & 1, irule & 1
  prints("Rule %d: \n", irule)
  printarray iRule, "%d"
  prints("\n")
  xout iRule
endop


