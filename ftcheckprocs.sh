   # Checks what processes are running.  Tricky when forks use chia_process names.
   # If forkname_process isn't found, check for a chia process with the fork's port
   # PREREQUISITES FOR USE OF THIS INCLUDE:
   #   FORKNAME must be set
   #   PROCESSEF=$( getproclist )  #function defined in ftplatformfuncs.sh
   # We don't do the last one here because this include can be called inside a loop, and we only want to run those once for performance reasons
SERVICESRUNNING=''
USINGCHIAPROCESSNAMES=0
for process in daemon full_node farmer harvester wallet; do
   PROCBLOCKCHAINNAME=$( echo "${FORKNAME}-blockchain" )
   PROCPROCESSNAME=$( echo "_${process}" )
   OLDIFS=$IFS
   IFS=''
   PROCCOUNT=$( echo $PROCESSEF | c1grep "${FORKTOOLSBLOCKCHAINDIRS}/${PROCBLOCKCHAINNAME}" | c1grep -c ${PROCPROCESSNAME} )
   CHIAPROCS=$( echo $PROCESSEF | c1grep "${FORKTOOLSBLOCKCHAINDIRS}/${PROCBLOCKCHAINNAME}" | c1grep -c "^chia${PROCPROCESSNAME}" )
   if [[ $CHIAPROCS > 0 ]]; then
      USINGCHIAPROCESSNAMES=1
   fi
   IFS=$OLDIFS
   PROCESSRUNNING=0
   if [[ $PROCCOUNT > 0 ]]; then
      PROCESSRUNNING=1
   fi
   if [[ $PROCCOUNT > 9 ]]; then
      SINGLESERVICE='+'
   else
      SINGLESERVICE=$( echo $PROCCOUNT )      
   fi
   case "$process" in
     "daemon"     ) DAEMONRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
     "full_node"  ) FULLNODERUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
     "farmer"     ) FARMERRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
     "harvester"  ) HARVESTERRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
     "wallet"     ) WALLETRUNNING=$PROCESSRUNNING; SERVICESRUNNING+=$SINGLESERVICE;;
   esac
done

