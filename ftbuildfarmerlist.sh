FARMERCOUNT=$(ps -ef | grep _farmer | grep -v grep | wc -l | awk '{$1=$1};1' )

OLDIFS=$IFS
IFS=''
FARMERLIST=$(ps -ef | grep _farmer | grep -v grep | awk '{print $8}' | sed 's/_farmer//' | grep -v [s]ed | uniq | sort)
# Verify chia farmer actually running - necessary because of shitforks that didn't rename their processes
CHIAPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":8559 " | wc -l | awk '{$1=$1};1')
if [[ $CHIAPORTINUSE == 0 ]]; then
  FARMERLIST=$(echo $FARMERLIST | sed '/^chia$/d')
  FARMERCOUNT=$(echo $(( "$FARMERCOUNT - 1" )) )  
fi

# Add special handling for obnoxious horribly coded forks that use "chia_farmer" as process name
# I do this under protest.
XCHAPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":5159 " | wc -l | awk '{$1=$1};1')
if [[ $XCHAPORTINUSE == 1 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nxcha" )
  FARMERCOUNT=$(echo $(( $FARMERCOUNT + 1 )) )  
fi  
LUCKYPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":16659 " | wc -l | awk '{$1=$1};1')
if [[ $LUCKYPORTINUSE == 1 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nlucky" )
  FARMERCOUNT=$(echo $(( $FARMERCOUNT + 1 )) )    
fi  
NCHAINPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":38559 " | wc -l | awk '{$1=$1};1')
if [[ $NCHAINPORTINUSE == 1 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nnchain" )
  FARMERCOUNT=$(echo $(( $FARMERCOUNT + 1 )) )  
fi  
FISHERYPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":4799 " | wc -l | awk '{$1=$1};1')
if [[ $FISHERYPORTINUSE == 1 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nfishery" )
  FARMERCOUNT=$(echo $(( $FARMERCOUNT + 1 )) )  
fi  
ROSEPORTINUSE=$(ss -atnp 2>/dev/null | grep '"chia_farm' | grep ":8459 " | wc -l | awk '{$1=$1};1')
if [[ $ROSEPORTINUSE == 1 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nrose" )
  FARMERCOUNT=$(echo $(( $FARMERCOUNT + 1 )) )  
fi
FARMERLIST=$(echo $FARMERLIST | sort)  
IFS=$OLDIFS

