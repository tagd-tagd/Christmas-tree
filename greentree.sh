#!/bin/bash
declare copyright="HAPPY NEW BASHDAYS! (c) Tagd-Tagd 2024"
declare -i STAR_PERCENT=2 #stars
declare -i LAMP_PERCENT=20
declare -a COLORS=("\033[01;31m" "\033[01;34m" "\033[01;35m" \
                  "\033[01;36m" "\033[38;5;209m" "\033[01;37m" \
                  "\033[01;93m" "\033[01;95m" "\033[01;32m")
declare -i CLR_NUM=${#COLORS[@]}
declare -ia LINE_LEN
declare -ia LINE_X
declare -i LINES=$(tput lines)
declare -i COLS=$(tput cols)
declare -i STAR_NUM=LINES*COLS*STAR_PERCENT/100
declare -i TREE_CHAR_SIZE=0
declare -iA LAMPS
declare BODY=#
declare -i x y l i
declare -i OFFSETX=(COLS-45)/2
declare -i kx=COLS/LINES
declare a

[[ $COLS -lt 45 || $LINES -lt 24 ]] && {
  echo Minimal terminal size 45x24
  exit 1 ; }

tcLtG="\033[00;37m"    # LIGHT GRAY
tcDkG="\033[01;30m"    # DARK GRAY
tcLtR="\033[01;31m"    # LIGHT RED
tcLtGRN="\033[01;32m"  # LIGHT GREEN
tcLtBL="\033[01;34m"   # LIGHT BLUE
tcLtP="\033[01;35m"    # LIGHT PURPLE
tcLtC="\033[01;36m"    # LIGHT CYAN
tcW="\033[01;37m"      # WHITE
tcRESET="\033[0m"
tcORANGE="\033[38;5;209m"
function quit(){
  read -st0.05 -n8
  echo -e  $tcRESET >&2
  clear
  tput cnorm
  exit
}
trap 'quit' SIGINT SIGTERM SIGHUP
clear
tput civis
i=$STAR_NUM
while ((i--));do #draw stars
  tput cup $(($SRANDOM % $LINES)) $(($SRANDOM % $COLS))
  printf '.'
done

printf -v BODY '%*s' $COLS;BODY=${BODY// /#}

for y in {0..22};do #tree math
  if [[ y -lt 7 ]];then x=y
  elif [[ y -lt 14 ]];then x=(y-7)*2+3
  elif [[ y -lt 21 ]];then x=(y-14)*3+4
  elif [[ y -lt 23 ]];then x=1
  fi;
  LINE_X[y]=22-$x+OFFSETX
  LINE_LEN[y]=$((i=x*2+1,TREE_CHAR_SIZE+=x,i))
done

echo -ne $tcLtGRN >&2
for y in {0..22};do #draw green tree
  tput cup $y ${LINE_X[y]}
  printf  ${BODY::${LINE_LEN[y]}}
done 
echo -e $tcW >&2
printf '%*s' $(((COLS-${#copyright})/2))
echo -n "$copyright"
for y in {0..22};do #set lamp pos
  i=${LINE_LEN[y]}
  while ((i--));do
    if [[ $(($SRANDOM%100)) -le $LAMP_PERCENT ]];then
      x=${LINE_X[y]}+i
      LAMPS[${y}_${x}]=$y
    fi
  done
done

for a in ${!LAMPS[@]};do #draw lamps
  x=${a#*_}
  y=${LAMPS[$a]}
  tput cup $y $x
  i=$(($SRANDOM % CLR_NUM))
  echo -n -e ${COLORS[$i]}
  printf 0
done

while :;do
  for a in ${!LAMPS[@]};do #blink lamps
    x=${a#*_}
    y=${LAMPS[$a]}
    i=$(($SRANDOM % CLR_NUM))
    tput cup $y $x
    echo -n -e ${COLORS[$i]}
    printf 0
    read -st0.05 -n1 #delay and check exit
    [[ $REPLY ]] && break 2
  done
done
quit
