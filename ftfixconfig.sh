. $FORKTOOLSDIR/ftconfigs/config.forkfixconfig
if [[ -f $FORKTOOLSDIR/ftconfigs/config.forkfixconfig.$FORKNAME ]]; then
  . $FORKTOOLSDIR/ftconfigs/config.forkfixconfig.$FORKNAME
fi

. $FORKTOOLSDIR/ftparseports.sh
. $FORKTOOLSDIR/ftcheckprocs.sh

SECTION='START'
OLDIFS=$IFS
IFS=$'\n'
LINENUMBER=0
while read line; do
   ((LINENUMBER=$LINENUMBER+1))
   PRESERVECOMMENT=$(grep '#' <<< "$line" | sed 's/.*#/#/')
   WORKLINE=$(sed 's/#.*//' <<< "$line" )  # This removes any comments from consideration for alteration
   TESTSECTION=$(grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^pool:' -e '^logging:' <<< "$WORKLINE" )

  if [[ $TESTSECTION != '' && $TESTSECTION != $SECTION ]];
  then 
     SECTION=$TESTSECTION
  fi
  
  if [[ $SETLOGLEVEL != '' && ($SECTION == *logging:* || $SECTION == *farmer:*) && $WORKLINE == *log_level:* ]];
  then
     OLDLOGLEVEL=$(sed 's/log_level: //' <<< "$WORKLINE" | sed 's/"//g' | sed 's/'\''//g' | awk '{$1=$1};1')
     NEWLOGLEVEL=$(sed "s/$OLDLOGLEVEL/$SETLOGLEVEL/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDLOGLEVEL=$line
     continue
  fi
  if [[ $SETMAXLOGROTATION != '' && ($SECTION == *logging:* || $SECTION == *farmer:*) && $WORKLINE == *log_maxfilesrotation:* ]];
  then
     OLDROTATION=$(sed 's/log_maxfilesrotation: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWROTATION=$(sed "s/$OLDROTATION/$SETMAXLOGROTATION/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDROTATION=$line
     continue     
  fi
  if [[ $SETPLOTLOADFREQUENCY != '' && $SECTION == *harvester:* && $WORKLINE == *plot_loading_frequency_seconds:* ]];
  then
     OLDPLOTLOAD=$(sed 's/plot_loading_frequency_seconds: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWPLOTLOAD=$(sed "s/$OLDPLOTLOAD/$SETPLOTLOADFREQUENCY/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDPLOTLOAD=$line
     continue     
  fi
  if [[ $SETPLOTLOADFREQUENCY != '' && $SECTION == *harvester:* && $WORKLINE == *interval_seconds:* ]];
  then
     OLDPLOTLOAD=$(sed 's/interval_seconds: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWPLOTLOAD=$(sed "s/$OLDPLOTLOAD/$SETPLOTLOADFREQUENCY/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDPLOTLOAD=$line
     continue     
  fi
  if [[ $SETBATCHSIZE != '' && $SECTION == *harvester:* && $WORKLINE == *batch_size:* ]];
  then
     OLDBATCHSIZE=$(sed 's/batch_size: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWBATCHSIZE=$(sed "s/$OLDBATCHSIZE/$SETBATCHSIZE/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDBATCHSIZE=$line
     continue     
  fi
  if [[ $SETBATCHSLEEP != '' && $SECTION == *harvester:* && $WORKLINE == *batch_sleep_milliseconds:* ]];
  then
     OLDBATCHSLEEP=$(sed 's/batch_sleep_milliseconds: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWBATCHSLEEP=$(sed "s/$OLDBATCHSLEEP/$SETBATCHSLEEP/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDBATCHSLEEP=$line
     continue     
  fi    
  if [[ $SETFNTARGETPEERCOUNT != '' && $SECTION == *full_node:* && $WORKLINE == *target_peer_count:* ]];
  then
     OLDTGTPEERS=$(sed 's/target_peer_count: //' <<< "$WORKLINE" | awk '{$1=$1};1')
     NEWTGTPEERS=$(sed "s/$OLDTGTPEERS/$SETFNTARGETPEERCOUNT/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDTGTPEERS=$line
     TARGETPEERLINENO=$LINENUMBER
     continue     
  fi
  if [[ $SETFARMERPEER != '' && $SECTION == *harvester:* && $WORKLINE == *host:* ]];
  then
     OLDFARMPEER=$(grep "host: " <<< "$WORKLINE" | sed 's/host: //' | sed 's/"//g' | sed 's/'\''//g' | awk '{$1=$1};1')
     NEWFARMPEER=$(sed "s/$OLDFARMPEER/$SETFARMERPEER/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDFARMPEER=$line
     HARVHOSTLINENO=$LINENUMBER
     continue     
  fi
  if [[ $SETPARALLELREAD != '' && $SECTION == *harvester:* && $WORKLINE == *parallel_read:* ]];
  then
     OLDPARALLELREAD=$(sed 's/parallel_read: //' <<< "$WORKLINE" | sed 's/"//g' | sed 's/'\''//g' | awk '{$1=$1};1')
     NEWPARALLELREAD=$(sed "s/$OLDPARALLELREAD/$SETPARALLELREAD/" <<< "$WORKLINE")$PRESERVECOMMENT
     OLDPARALLELREAD=$line
     continue     
  fi
  
done < $CURRENTCONFIG


SKIPMULTIPROC='No'
if [[ $SETMULTIPROC != '' ]]; then
   IFS=''
   EXISTINGMULTIPROC=$(grep 'multiprocessing_limit' $CURRENTCONFIG)
   if [[ $EXISTINGMULTIPROC = '' ]]; then
      FULLNODESYNCED=''
      if [[ $FULLNODERUNNING == 1 ]]; then
         echo "here3"
         FULLNODESYNCED='No'
         cd $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain
         . ./activate
         BLOCKCHAINSTATE=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_blockchain_state | python -m json.tool)
         echo "here4"         
         FULLNODESYNCED=$(c1grep '"synced":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
      fi   
      if [[ $FULLNODESYNCED != 'true' ]]; then
         echo "Full node is not synced or not running. Not adding 'multiprocessing_limit: $SETMULTIPROC' until sync is verified."
         SKIPMULTIPROC='Yes'
      else 
         OLDMULTIPROC='Synced status confirmed. Prepared to add setting.'
      fi
   else
      OLDMULTIPROC=$EXISTINGMULTIPROC
   fi
   NEWMULTIPROC="multiprocessing_limit: $SETMULTIPROC"   
fi

IFS=$OLDIFS

ANYCHANGES='No'
echo 'Proposed changes to' $CURRENTCONFIG ':'
if [[ $SETLOGLEVEL != '' && $OLDLOGLEVEL != $NEWLOGLEVEL ]]; then
  echo "  Old Log Level: " $OLDLOGLEVEL
  echo "  New Log Level: " $NEWLOGLEVEL
  ANYCHANGES='Yes'
fi
if [[ $SETMAXLOGROTATION != '' && $OLDROTATION != $NEWROTATION ]]; then
  echo "  Old Max Log Rotation: " $OLDROTATION
  echo "  New Max Log Rotation: " $NEWROTATION
  ANYCHANGES='Yes'
fi
if [[ $SETPLOTLOADFREQUENCY != '' && $OLDPLOTLOAD != $NEWPLOTLOAD ]]; then  
  echo "  Old Plot Load Frequency: " $OLDPLOTLOAD
  echo "  New Plot Load Frequency: " $NEWPLOTLOAD
  ANYCHANGES='Yes'  
fi
if [[ $SETBATCHSIZE != '' && $OLDBATCHSIZE != $NEWBATCHSIZE ]]; then  
  echo "  Old Batch Size: " $OLDBATCHSIZE
  echo "  New Batch Size: " $NEWBATCHSIZE
  ANYCHANGES='Yes'
fi
if [[ $SETBATCHSLEEP != '' && $OLDBATCHSLEEP != $NEWBATCHSLEEP ]]; then  
  echo "  Old Batch Sleep: " $OLDBATCHSLEEP
  echo "  New Batch Sleep: " $NEWBATCHSLEEP
  ANYCHANGES='Yes'
fi
if [[ $SETFNTARGETPEERCOUNT != '' && $OLDTGTPEERS != $NEWTGTPEERS ]]; then  
  echo "  Old Target Peer Count: " $OLDTGTPEERS
  echo "  New Target Peer Count: " $NEWTGTPEERS
  ANYCHANGES='Yes'
fi
if [[ $SETFARMERPEER != '' && $OLDFARMPEER != $NEWFARMPEER ]]; then  
  echo "  Old Harvester Farmer_Peer IP: " $OLDFARMPEER
  echo "  New Harvester Farmer_Peer IP: " $NEWFARMPEER
  ANYCHANGES='Yes'
fi
if [[ $SETPARALLELREAD != '' && $OLDPARALLELREAD != $NEWPARALLELREAD ]]; then  
  echo "  Old Harvester Parallel Read: " $OLDFARMPEER
  echo "  New Harvester Parallel Read: " $NEWFARMPEER
  ANYCHANGES='Yes'
fi
if [[ $SETMULTIPROC != '' && $SKIPMULTIPROC == 'No' && $OLDMULTIPROC != $NEWMULTIPROC ]]; then
  echo "  Old Multiprocessing Limit: " $OLDMULTIPROC
  echo "  New Multiprocessing Limit: " $NEWMULTIPROC
  ANYCHANGES='Yes'
fi

# Port section - should only come from fork specific configs (config.forkfixconfig.forkname)

if [[ $SETHARVESTERPORT != '' && $SETHARVESTERPORT != $HARVESTERPORT ]]; then
  echo "  Old Harvester Port: " $HARVESTERPORT
  echo "  New Harvester Port: " $SETHARVESTERPORT
  ANYCHANGES='Yes'
fi
if [[ $SETHARVESTERRPCPORT != '' && $SETHARVESTERRPCPORT != $HARVESTERRPCPORT ]]; then
  echo "  Old Harvester RPC Port: " $HARVESTERRPCPORT
  echo "  New Harvester RPC Port: " $SETHARVESTERRPCPORT
  ANYCHANGES='Yes'
fi
if [[ $SETFARMERPORT != '' && $SETFARMERPORT != $FARMERPORT ]]; then
  echo "  Old Farmer Port: " $FARMERPORT
  echo "  New Farmer Port: " $SETFARMERPORT
  ANYCHANGES='Yes'
fi
if [[ $SETFARMERRPCPORT != '' && $SETFARMERRPCPORT != $FARMERRPCPORT ]]; then
  echo "  Old Farmer RPC Port: " $FARMERRPCPORT
  echo "  New Farmer RPC Port: " $SETFARMERRPCPORT
  ANYCHANGES='Yes'
fi
if [[ $SETWALLETPORT != '' && $SETWALLETPORT != $WALLETPORT ]]; then
  echo "  Old Wallet Port: " $WALLETPORT
  echo "  New Wallet Port: " $SETWALLETPORT
  ANYCHANGES='Yes'
fi
if [[ $SETWALLETRPCPORT != '' && $SETWALLETRPCPORT != $WALLETRPCPORT ]]; then
  echo "  Old Wallet RPC Port: " $WALLETRPCPORT
  echo "  New Wallet RPC Port: " $SETWALLETRPCPORT
  ANYCHANGES='Yes'
fi
if [[ $SETTIMELORDPORT != '' && $SETTIMELORDPORT != $TIMELORDPORT ]]; then
  echo "  Old Timelord Port: " $TIMELORDPORT
  echo "  New Timelord Port: " $SETTIMELORDPORT
  ANYCHANGES='Yes'
fi
if [[ $SETTIMELORDLAUNCHERPORT != '' && $SETTIMELORDLAUNCHERPORT != $TIMELORDLAUNCHERPORT ]]; then
  echo "  Old TimelordLauncher Port: " $TIMELORDLAUNCHERPORT
  echo "  New TimelordLauncher Port: " $SETTIMELORDLAUNCHERPORT
  ANYCHANGES='Yes'
fi
if [[ $SETDAEMONPORT != '' && $SETDAEMONPORT != $DAEMONPORT ]]; then
  echo "  Old Daemon Port   : " $DAEMONPORT
  echo "  New Daemon Port   : " $SETDAEMONPORT
  ANYCHANGES='Yes'
fi
if [[ $SETUIPORT != '' && $SETUIPORT != $UIPORT ]]; then
  echo "  Old UI Port      : " $UIPORT
  echo "  New UI Port      : " $SETUIPORT
  ANYCHANGES='Yes'
fi

# END Port Section

if [[ $APPEND1 != '' ]]; then
  APPEND1EXISTS=$(grep "$APPEND1" "$CURRENTCONFIG" | wc -l | awk '{$1=$1};1')
  if [ $APPEND1EXISTS -gt 0 ]; then
    echo "  Option \"$APPEND1\" already exists in $CURRENTCONFIG, skipping append."
  else 
    echo "  Appending: " $APPEND1
    ANYCHANGES='Yes'
  fi
fi
if [[ $APPEND2 != '' ]]; then
  APPEND2EXISTS=$(grep "$APPEND2" "$CURRENTCONFIG" | wc -l | awk '{$1=$1};1')
  if [ $APPEND2EXISTS -gt 0 ]; then
    echo "  Option \"$APPEND2\" already exists in $CURRENTCONFIG, skipping append."
  else 
    echo "  Appending: " $APPEND2
    ANYCHANGES='Yes'
  fi
fi
if [[ $APPEND3 != '' ]]; then
  APPEND3EXISTS=$(grep "$APPEND3" "$CURRENTCONFIG" | wc -l | awk '{$1=$1};1')
  if [ $APPEND3EXISTS -gt 0 ]; then
    echo "  Option \"$APPEND3\" already exists in $CURRENTCONFIG, skipping append."
  else 
    echo "  Appending: " $APPEND3
    ANYCHANGES='Yes'
  fi
fi


if [[ $ANYCHANGES == 'No' ]]; then
  echo 'No requested changes or all parameters already set to preferred settings.'
  continue
fi
echo "Should you proceed, a backup of your current config.yaml will be made called config.yaml.`date +%F`"
read -p "Are you sure you wish to make these changes? (Y/y)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
   cp $CURRENTCONFIG $CURRENTCONFIG.`date +%F`
   if [[ $SETLOGLEVEL != '' && $OLDLOGLEVEL != $NEWLOGLEVEL ]]; then
      echo "Setting log level..."
      sed -i.bak "s/$OLDLOGLEVEL/$NEWLOGLEVEL/" $CURRENTCONFIG
   fi
   if [[ $SETMAXLOGROTATION != '' && $OLDROTATION != $NEWROTATION ]]; then
      echo "Setting log rotation..."
      sed -i.bak "s/$OLDROTATION/$NEWROTATION/" $CURRENTCONFIG
   fi
   if [[ $SETPLOTLOADFREQUENCY != '' && $OLDPLOTLOAD != $NEWPLOTLOAD ]]; then     
      echo "Setting plot load frequency..."
      sed -i.bak "s/$OLDPLOTLOAD/$NEWPLOTLOAD/" $CURRENTCONFIG
   fi
   if [[ $SETBATCHSIZE != '' && $OLDBATCHSIZE != $NEWBATCHSIZE ]]; then  
      echo "Setting batch size..."
      sed -i.bak "s/$OLDBATCHSIZE/$NEWBATCHSIZE/" $CURRENTCONFIG
   fi
   if [[ $SETBATCHSLEEP != '' && $OLDBATCHSLEEP != $NEWBATCHSLEEP ]]; then  
      echo "Setting batch sleep..."
      sed -i.bak "s/$OLDBATCHSLEEP/$NEWBATCHSLEEP/" $CURRENTCONFIG
   fi
   if [[ $SETFNTARGETPEERCOUNT != '' && $OLDTGTPEERS != $NEWTGTPEERS ]]; then  
      echo "Setting target peer count..."
      sed -i.bak "${TARGETPEERLINENO}s/$OLDTGTPEERS/$NEWTGTPEERS/" $CURRENTCONFIG
   fi
   if [[ $SETFARMERPEER != '' && $OLDFARMPEER != $NEWFARMPEER ]]; then
      echo "Setting farmer peer in harvester section..."
      # Some versions of config have " *self_hostname " as the original value.  sed sees * as wildcard and fails.  This fixes it.
      OLDFARMPEER=$(echo "$OLDFARMPEER" | sed 's/\*/\\\*/' )
      sed -i.bak "${HARVHOSTLINENO}s/$OLDFARMPEER/$NEWFARMPEER/" $CURRENTCONFIG
   fi
   if [[ $SETPARALLELREAD != '' && $OLDPARALLELREAD != $NEWPARALLELREAD ]]; then  
      echo "Setting harvester parallel read..."
      sed -i.bak "s/$OLDPARALLELREAD/$NEWPARALLELREAD/" $CURRENTCONFIG
   fi
   if [[ $SETMULTIPROC != '' && $SKIPMULTIPROC == 'No' && $OLDMULTIPROC != $NEWMULTIPROC ]]; then  
      echo "Adding/replacing multiprocessing limit..."
      if [[ $EXISTINGMULTIPROC != '' ]]; then
        sed -i.bak '/multiprocessing_limit/d' $CURRENTCONFIG
      fi
      echo >> $CURRENTCONFIG
      echo $NEWMULTIPROC >> $CURRENTCONFIG
   fi
   
   if [[ $SETHARVESTERPORT != '' && $SETHARVESTERPORT != $HARVESTERPORT ]]; then
      echo "Setting harvester port..."
      sed -i.bak "s/ ${HARVESTERPORT}$/ ${SETHARVESTERPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETHARVESTERRPCPORT != '' && $SETHARVESTERRPCPORT != $HARVESTERRPCPORT ]]; then
      echo "Setting harvester RPC port..."
      sed -i.bak "s/ ${HARVESTERRPCPORT}$/ ${SETHARVESTERRPCPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETFARMERPORT != '' && $SETFARMERPORT != $FARMERPORT ]]; then
      echo "Setting farmer port..."
      sed -i.bak "s/ ${FARMERPORT}$/ ${SETFARMERPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETFARMERRPCPORT != '' && $SETFARMERRPCPORT != $FARMERRPCPORT ]]; then
      echo "Setting farmer RPC port..."
      sed -i.bak "s/ ${FARMERRPCPORT}$/ ${SETFARMERRPCPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETWALLETPORT != '' && $SETWALLETPORT != $WALLETPORT ]]; then
      echo "Setting wallet port..."
      sed -i.bak "s/ ${WALLETPORT}$/ ${SETWALLETPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETWALLETRPCPORT != '' && $SETWALLETRPCPORT != $WALLETRPCPORT ]]; then
      echo "Setting wallet RPC port..."
      sed -i.bak "s/ ${WALLETRPCPORT}$/ ${SETWALLETRPCPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETTIMELORDPORT != '' && $SETTIMELORDPORT != $TIMELORDPORT ]]; then
      echo "Setting timelord port..."
      sed -i.bak "s/ ${TIMELORDPORT}$/ ${SETTIMELORDPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETTIMELORDLAUNCHERPORT != '' && $SETTIMELORDLAUNCHERPORT != $TIMELORDLAUNCHERPORT ]]; then
      echo "Setting timelord launcher port..."
      sed -i.bak "s/ ${TIMELORDLAUNCHERPORT}$/ ${SETTIMELORDLAUNCHERPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETDAEMONPORT != '' && $SETDAEMONPORT != $DAEMONPORT ]]; then
      echo "Setting daemon port..."
      sed -i.bak "s/ ${DAEMONPORT}$/ ${SETDAEMONPORT}/" $CURRENTCONFIG
   fi
   if [[ $SETUIPORT != '' && $SETUIPORT != $UIPORT ]]; then
      echo "Setting UI port..."
      sed -i.bak "s/ ${UIPORT}$/ ${SETUIPORT}/" $CURRENTCONFIG
   fi
   
   if [[ $APPEND1 != '' && $APPEND1EXISTS == 0 ]]; then
      echo "Appending $APPEND1..."
      echo >> $CURRENTCONFIG
      echo $APPEND1 >> $CURRENTCONFIG
   fi
   if [[ $APPEND2 != '' && $APPEND2EXISTS == 0 ]]; then
      echo "Appending $APPEND2..."
      echo >> $CURRENTCONFIG
      echo $APPEND2 >> $CURRENTCONFIG
   fi
   if [[ $APPEND3 != '' && $APPEND3EXISTS == 0 ]]; then
      echo "Appending $APPEND3..."   
      echo >> $CURRENTCONFIG
      echo $APPEND3 >> $CURRENTCONFIG
   fi
   rm ${CURRENTCONFIG}.bak 2>/dev/null  # This is useless as it has every edit made except the last one, .bak is only created for MacOS X compatibility.
   echo 'Backed up original' $FORKNAME 'config.yaml to config.yaml.'`date +%F`'. ' $CURRENTCONFIG 'has had the proposed changes applied.'   
fi

