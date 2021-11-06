cd $FORKTOOLSBLOCKCHAINDIRS
FORKLIST=$( ls -d1 *-blockchain | sed 's/-blockchain//' )
FARMERLIST=$FORKLIST
HARVESTERLIST=$FORKLIST
DAEMONLIST=$FORKLIST

PROCESSEF=$( getproclist )

OLDIFSBRL=$IFS
for FORKNAME in $FORKLIST; do
  IFS=''
  if [[ ! -f $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml ]]; then
     FARMERLIST=$(echo $FARMERLIST | grep -v "^$FORKNAME$" )
     HARVESTERLIST=$(echo $HARVESTERLIST | grep -v "^$FORKNAME$" )
     DAEMONLIST=$(echo $DAEMONLIST | grep -v "^$FORKNAME$" )               
     continue
  else
     CURRENTCONFIG=$FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml
  fi
  . $FORKTOOLSDIR/ftcheckprocs.sh
  if [[ $FARMERRUNNING != 1 ]]; then
     FARMERLIST=$(echo $FARMERLIST | grep -v "^$FORKNAME$" )
  fi
  if [[ $HARVESTERRUNNING != 1 ]]; then
     HARVESTERLIST=$(echo $HARVESTERLIST | grep -v "^$FORKNAME$" )
  fi
  if [[ $DAEMONRUNNING != 1 ]]; then
     DAEMONLIST=$(echo $DAEMONLIST | grep -v "^$FORKNAME$" )
  fi
done

IFS=$'\n'
FARMERCOUNT=$(echo $FARMERLIST | wc -w | awk '{$1=$1};1')
HARVESTERCOUNT=$(echo $HARVESTERLIST | wc -w | awk '{$1=$1};1')
DAEMONCOUNT=$(echo $DAEMONLIST | wc -w | awk '{$1=$1};1')
IFS=$OLDIFSBRL

