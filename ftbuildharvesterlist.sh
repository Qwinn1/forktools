HARVESTERCOUNT=$(ps -ef | grep _harvester | grep -v grep | wc -l | awk '{$1=$1};1')

OLDIFS=$IFS
IFS=''
HARVESTERLIST=$(ps -ef | grep -v grep | grep -o [A-Za-z]*_harvester | sed 's/_harvester//' | uniq | sort)
# Verify chia harvester actually running - necessary because of shitforks that didn't rename their processes
CHIAINLIST=$( echo $HARVESTERLIST | grep "^chia$" )
if [[ $CHIAINLIST != '' ]]; then
  CHIAPORTINUSE=$(forkss | grep '"chia_harv' | grep ":8560 " | wc -l | awk '{$1=$1};1')
  if [[ $CHIAPORTINUSE == 0 ]]; then
    HARVESTERLIST=$(echo $HARVESTERLIST | sed '/^chia$/d')
    HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT - 1 )) )    
  fi
fi

# Add special handling for obnoxious horribly coded forks that use "chia_harvester" as process names
# I do this under protest.
XCHAPORTINUSE=$(forkss | grep '"chia_harv' | grep ":5160 " | wc -l | awk '{$1=$1};1')
if [[ $XCHAPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nxcha" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )
fi  
LUCKYPORTINUSE=$(forkss | grep '"chia_harv' | grep ":16660 " | wc -l | awk '{$1=$1};1')
if [[ $LUCKYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nlucky" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
NCHAINPORTINUSE=$(forkss | grep '"chia_harv' | grep ":38560 " | wc -l | awk '{$1=$1};1')
if [[ $NCHAINPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nnchain" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
FISHERYPORTINUSE=$(forkss | grep '"chia_harv' | grep ":4790 " | wc -l | awk '{$1=$1};1')
if [[ $FISHERYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nfishery" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
ROSEPORTINUSE=$(forkss | grep '"chia_harv' | grep ":8561 " | wc -l | awk '{$1=$1};1')
if [[ $ROSEPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nrose" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
HARVESTERLIST=$(echo $HARVESTERLIST | sort | uniq)  
IFS=$OLDIFS


