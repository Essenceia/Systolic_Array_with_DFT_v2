#!/bin/bash 

RESET='\033[0m'
BOLD='\033[1m'
CJA='\033[1;32m'      # green
CJB='\033[1;36m'      # cyan
CJC='\033[1;33m'      # yellow
CJXADC='\033[1;35m'   # magenta
PLBL='\033[0;37m'     # light gray
FPIN='\033[1;37m'     # bright white
DIM='\033[2;37m'
SEP='\033[0;90m'

pad() { printf "%-${2}s" "$1"; }

H="═"
V="║"
TL="╔"; TR="╗"; BL="╚"; BR="╝"
LM="╠"; RM="╣"; TM="╦"; BM="╩"; X="╬"
LS="╟"; RS="╢"; XS="╫"

W=14

hline() {
  local lc="$1" mc="$2" jc="$3" rc="$4"
  local bar=""
  bar+="${lc}"
  for i in 1 2 3 4; do
    for j in $(seq 1 $W); do bar+="${H}"; done
    if [ $i -lt 4 ]; then bar+="${jc}"; else bar+="${rc}"; fi
  done
  echo -e "${SEP}${bar}${RESET}"
}

sline() {
  local lc="$1" mc="$2" rc="$3"
  local bar=""
  bar+="${lc}"
  for i in 1 2 3 4; do
    for j in $(seq 1 $W); do bar+="─"; done
    if [ $i -lt 4 ]; then bar+="${mc}"; else bar+="${rc}"; fi
  done
  echo -e "${SEP}${bar}${RESET}"
}

row() {
  local ja="$1" jb="$2" jc="$3" jx="$4"
  local ja_lbl="${ja%%:*}:"; local ja_pin="${ja##*: }"
  local jb_lbl="${jb%%:*}:"; local jb_pin="${jb##*: }"
  local jc_lbl="${jc%%:*}:"; local jc_pin="${jc##*: }"
  local jx_lbl="${jx%%:*}:"; local jx_pin="${jx##*: }"

  printf "${SEP}${V}${RESET}"
  printf " ${CJA}%-6s${RESET}${FPIN}%-$(( W - 8 ))s${RESET} ${SEP}${V}${RESET}" "$ja_lbl" "$ja_pin"
  printf " ${CJB}%-6s${RESET}${FPIN}%-$(( W - 8 ))s${RESET} ${SEP}${V}${RESET}" "$jb_lbl" "$jb_pin"
  printf " ${CJC}%-6s${RESET}${FPIN}%-$(( W - 8 ))s${RESET} ${SEP}${V}${RESET}" "$jc_lbl" "$jc_pin"
  printf " ${CJXADC}%-8s${RESET}${FPIN}%-$(( W - 10 ))s${RESET} ${SEP}${V}${RESET}" "$jx_lbl" "$jx_pin"
  printf "\n"
}

hline "$TL" "$TM" "$TM" "$TR"

printf "${SEP}${V}${RESET}"
printf " ${CJA}${BOLD}%-$(( W - 1 ))s${RESET}${SEP}${V}${RESET}" "Pmod JA"
printf " ${CJB}${BOLD}%-$(( W - 1 ))s${RESET}${SEP}${V}${RESET}" "Pmod JB"
printf " ${CJC}${BOLD}%-$(( W - 1 ))s${RESET}${SEP}${V}${RESET}" "Pmod JC"
printf " ${CJXADC}${BOLD}%-$(( W - 1 ))s${RESET}${SEP}${V}${RESET}" "Pmod JXADC"
printf "\n"


hline "$LM" "$X" "$X" "$RM"


row "JA1: J1"   "JB1: A14"  "JC1: K17"  "JXADC1: J3"
sline "$LS" "$XS" "$RS"
row "JA2: L2"   "JB2: A16"  "JC2: M18"  "JXADC2: L3"
sline "$LS" "$XS" "$RS"
row "JA3: J2"   "JB3: B15"  "JC3: N17"  "JXADC3: M2"
sline "$LS" "$XS" "$RS"
row "JA4: G2"   "JB4: B16"  "JC4: P18"  "JXADC4: N2"

hline "$LM" "$X" "$X" "$RM"

row "JA7: H1"   "JB7: A15"  "JC7: L17"  "JXADC7: K3"
sline "$LS" "$XS" "$RS"
row "JA8: K2"   "JB8: A17"  "JC8: M19"  "JXADC8: M3"
sline "$LS" "$XS" "$RS"
row "JA9: H2"   "JB9: C15"  "JC9: P17"  "JXADC9: M1"
sline "$LS" "$XS" "$RS"
row "JA10: G3"  "JB10: C16" "JC10: R18" "JXADC10: N1"

hline "$BL" "$BM" "$BM" "$BR"

echo -e "  ${CJA}■ Pmod JA${RESET}      ${CJB}■ Pmod JB${RESET}      ${CJC}■ Pmod JC${RESET}      ${CJXADC}■ Pmod JXADC${RESET}"
