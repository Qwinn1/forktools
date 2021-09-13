HARVESTERCOUNT=$(ps -ef | grep _harvester | grep -v grep | wc -l | awk '{$1=$1};1')

OLDIFS=$IFS
IFS=''
HARVESTERLIST=$(ps -ef | grep _harvester | grep -v grep | awk '{print $8}' | sed 's/_harvester//' | grep -v [s]ed | uniq | sort)
CHIAPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":8560 " | wc -l | awk '{$1=$1};1')
if [[ $CHIAPORTINUSE == 0 ]]; then
  HARVESTERLIST=$(echo $HARVESTERLIST | sed '/^chia$/d')
  HARVESTERCOUNT=$(echo (( $HARVESTERCOUNT - 1 )) )    
fi

# Add special handling for obnoxious horribly coded forks that use "chia_harvester" as process names
# I do this under protest.
XCHAPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":5160 " | wc -l | awk '{$1=$1};1')
if [[ $XCHAPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nxcha" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )
fi  
LUCKYPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":16660 " | wc -l | awk '{$1=$1};1')
if [[ $LUCKYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nlucky" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
NCHAINPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":38560 " | wc -l | awk '{$1=$1};1')
if [[ $NCHAINPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nnchain" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
FISHERYPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":4790 " | wc -l | awk '{$1=$1};1')
if [[ $FISHERYPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nfishery" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
ROSEPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_harv' | grep ":8561 " | wc -l | awk '{$1=$1};1')
if [[ $ROSEPORTINUSE == 1 ]]; then 
  HARVESTERLIST=$(echo -e $HARVESTERLIST"\nrose" )
  HARVESTERCOUNT=$(echo $(( $HARVESTERCOUNT + 1 )) )  
fi  
HARVESTERLIST=$(echo $HARVESTERLIST | sort)  
IFS=$OLDIFS


