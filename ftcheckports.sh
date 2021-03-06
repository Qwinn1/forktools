
   # Checks what processes are running.  Tricky when forks use chia_process names.
   # If forkname_process isn't found, check for a chia process with the fork's port
   # PREREQUISITES FOR USE OF THIS INCLUDE:
   #   FORKNAME must be set
   #   PROCESSEF=$(ps -ef | grep -e 'full_node' -e 'farmer' -e 'harvester' -e 'wallet' -e '_daemon' | grep -v grep | awk '{ print $8 } ' | sort | uniq )
   #   CHIAPROCS=$(forkss | grep "\"chia" )
   # We don't do the last two here because this include can be called inside a loop, and we only want to run those once for performance reasons

   PROPERPROCESSNAMES=0
   CURRENTCONFIG=$FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml
   USINGCHIAPROCESSNAMES=0
   SERVICESRUNNING=''
   for process in daemon full_node farmer harvester wallet; do
   
      PROCESSRUNNING=1 # Assume it's running, then set it to 0 if we can't find supporting evidence
      PROCESSNAME=$( echo "${FORKNAME}_${process}" )
      CHECKRUNNING=$( echo $PROCESSEF | c1grep -c -e $PROCESSNAME )
      if [[ $CHECKRUNNING > 0 && $FORKNAME != 'chia' ]]; then
         PROPERPROCESSNAMES=1  # It found a process - probabaly daemon - named correctly and running
      fi
      if [[ $CHECKRUNNING == 0 || $FORKNAME == 'chia' ]]; then
         if [[ $PROPERPROCESSNAMES == 1 && $CHECKRUNNING == 0 ]]; then # So any we don't find really aren't running
            PROCESSRUNNING=0
         else
            if [[ $PORTPARSINGDONE != 1 ]]; then
               . $FORKTOOLSDIR/ftparseports.sh
            fi
            case "$process" in
               "daemon"     ) PORTTOSEARCH=$DAEMONPORT;;
               "full_node"  ) PORTTOSEARCH=$FULLNODEPORT;;
               "farmer"     ) PORTTOSEARCH=$FARMERRPCPORT;;
               "harvester"  ) PORTTOSEARCH=$HARVESTERRPCPORT;;
               "wallet"     ) PORTTOSEARCH=$WALLETRPCPORT;;
            esac
            OLDIFS=$IFS
            IFS=''
            FORKPORTINUSE=$(echo $CHIAPROCS | grep "\"chia_$process" | grep -c ":${PORTTOSEARCH} " )
            IFS=$OLDIFS
            if [[ $FORKPORTINUSE == 0 ]]; then
               PROCESSRUNNING=0
            else
               USINGCHIAPROCESSNAMES=1
            fi
         fi
      fi
      SINGLESERVICE='N'
      if [[ $PROCESSRUNNING = 1 ]]; then
         SINGLESERVICE='Y'
      fi
      case "$process" in
         "daemon"     ) DAEMONRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
         "full_node"  ) FULLNODERUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
         "farmer"     ) FARMERRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
         "harvester"  ) HARVESTERRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
         "wallet"     ) WALLETRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
      esac                        
   done
   # echo $DAEMONRUNNING $FULLNODERUNNING $FARMERRUNNING $HARVESTERRUNNING $WALLETRUNNING