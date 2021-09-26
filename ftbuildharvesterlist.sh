OLDIFS=$IFS
IFS=''
HARVESTERLIST=$(ps -ef | grep -v grep | grep -o [A-Za-z]*_harvester | sed 's/_harvester//' | uniq | sort)
# Verify chia harvester actually running - necessary because of shitforks that didn't rename their processes
CHIAINLIST=$( echo $HARVESTERLIST | grep "^chia$" )
if [[ $CHIAINLIST != '' ]]; then
  CHIAPORTINUSE=$(forkss | grep '"chia_harv' | grep ":8560 " | wc -l | awk '{$1=$1};1')
  if [[ $CHIAPORTINUSE == 0 ]]; then
    HARVESTERLIST=$(echo $HARVESTERLIST | sed '/^chia$/d')
  fi
fi

# Add special handling for obnoxious horribly coded forks that use "chia_harvester" as process names
# I do this under protest.
XCHAPORTINUSE=$(forkss | grep '"chia_harv' | grep ":5160 " | wc -l | awk '{$1=$1};1')
if [[ $XCHAPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nxcha" )
fi  
LUCKYPORTINUSE=$(forkss | grep '"chia_harv' | grep ":16660 " | wc -l | awk '{$1=$1};1')
if [[ $LUCKYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nlucky" )
fi  
NCHAINPORTINUSE=$(forkss | grep '"chia_harv' | grep ":38560 " | wc -l | awk '{$1=$1};1')
if [[ $NCHAINPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nnchain" )
fi  
FISHERYPORTINUSE=$(forkss | grep '"chia_harv' | grep ":4790 " | wc -l | awk '{$1=$1};1')
if [[ $FISHERYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nfishery" )
fi  
ROSEPORTINUSE=$(forkss | grep '"chia_harv' | grep ":8561 " | wc -l | awk '{$1=$1};1')
if [[ $ROSEPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nrose" )
fi  
HARVESTERLIST=$(echo $HARVESTERLIST | sort | uniq )  
IFS=$OLDIFS
HARVESTERCOUNT=$(echo $HARVESTERLIST | wc -w | awk '{$1=$1};1')

