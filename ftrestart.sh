FORKSTARTPARAM=''
if [[ $FARMERRUNNING == 1 && $HARVESTERRUNNING == 1 && $WALLETRUNNING == 1 && $FULLNODERUNNING == 1 ]]; then
   FORKSTARTPARAM='-f'
elif [[ $FARMERRUNNING == 1 && $HARVESTERRUNNING == 1 && $WALLETRUNNING == 0 && $FULLNODERUNNING == 1 ]]; then
   FORKSTARTPARAM='-fnw'
elif [[ $FARMERRUNNING == 0 && $HARVESTERRUNNING == 1 && $WALLETRUNNING == 0 && $FULLNODERUNNING == 0 ]]; then
   FORKSTARTPARAM='-h'
elif [[ $FARMERRUNNING == 1 && $HARVESTERRUNNING == 0 && $WALLETRUNNING == 0 && $FULLNODERUNNING == 0 ]]; then
   FORKSTARTPARAM='-fo'         
elif [[ $FARMERRUNNING == 1 && $HARVESTERRUNNING == 1 && $WALLETRUNNING == 0 && $FULLNODERUNNING == 0 ]]; then
   FORKSTARTPARAM='-fh'
fi

if [[ $FORKSTARTPARAM != '' ]]; then
   echo "$FTBASECOMMAND:  Attempting to restart fork with same services."
   $FORKTOOLSDIR/forkstart $FORKNAME $FORKSTARTPARAM
   if [[ $1 = 'all' ]]; then            
      echo "$FTBASECOMMAND:  Sleeping for 30 seconds to allow $FORKNAME restart a moment to process before proceeding."            
      sleep 30
   fi
else 
   echo "$FTBASECOMMAND:  You should now run forkstart -f, -fnw or -h to resume whichever service you prefer for this fork."
fi
