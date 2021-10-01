OLDIFS=$IFS
IFS=''
FARMERLIST=$(ps -ef | grep -v grep | grep -o [A-Za-z]*_farmer | sed 's/_farmer//' | uniq | sort)

# Verify chia farmer actually running - necessary because of shitforks that didn't rename their processes
CHIAINLIST=$( echo $FARMERLIST | grep "^chia$" )
if [[ $CHIAINLIST != '' ]]; then
  CHIAPORTINUSE=$(forkss | grep '"chia_farm' | grep ":8559 " | wc -l | awk '{$1=$1};1')
  if [[ $CHIAPORTINUSE == 0 ]]; then
    FARMERLIST=$(echo $FARMERLIST | sed '/^chia$/d')
  fi
fi

# Add special handling for obnoxious horribly coded forks that use "chia_farmer" as process name
# I do this under protest.
XCHAPORTINUSE=$(forkss | grep '"chia_farm' | grep ":5159 " | wc -l | awk '{$1=$1};1')
if [[ $XCHAPORTINUSE > 0 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nxcha" )
fi  
LUCKYPORTINUSE=$(forkss | grep '"chia_farm' | grep ":16659 " | wc -l | awk '{$1=$1};1')
if [[ $LUCKYPORTINUSE > 0 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nlucky" )
fi  
NCHAINPORTINUSE=$(forkss | grep '"chia_farm' | grep ":38559 " | wc -l | awk '{$1=$1};1')
if [[ $NCHAINPORTINUSE > 0 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nnchain" )
fi  
FISHERYPORTINUSE=$(forkss | grep '"chia_farm' | grep ":4799 " | wc -l | awk '{$1=$1};1')
if [[ $FISHERYPORTINUSE > 0 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nfishery" )
fi  
ROSEPORTINUSE=$(forkss | grep '"chia_farm' | grep ":8459 " | wc -l | awk '{$1=$1};1')
if [[ $ROSEPORTINUSE > 0 ]]; then 
  FARMERLIST=$(echo -e $FARMERLIST"\nrose" )
fi
FARMERLIST=$(echo $FARMERLIST | sort | uniq)  

# Verify the blockchain and hidden directories are actually accessible.  Dockers, for example, have the processes but nothing else accessible.
FARMERLISTCHECK=$FARMERLIST
IFS=$'\n' 
for fork in $FARMERLISTCHECK; do
  if [[ ! -d $FORKTOOLSHIDDENDIRS/.$fork/mainnet/log || ! -d $FORKTOOLSBLOCKCHAINDIRS/$fork-blockchain ]]; then
     IFS=''
     FARMERLIST=$(echo $FARMERLIST | grep -v "^$fork$" )
  fi
done  

FARMERCOUNT=$(echo $FARMERLIST | wc -w | awk '{$1=$1};1')
IFS=$OLDIFS

