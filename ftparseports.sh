
   OLDIFS=$IFS
   IFS=''
   # Get all ports.  Uses c1grep function instead of grep so as to not trigger ERROR trap code 1 (no line found) which is intended
   MEMORYCONFIG=$(cat $CURRENTCONFIG | c1grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^logging:' -e 'port: ' -e '_peer:' -e 'vdf_server:' ) 
   SECTION=''
   TESTSECTION=''
   while read line; do
     WORKLINE=$(sed 's/#.*//' <<< "$line" )  # This removes any comments from consideration for alteration
     if [[ $WORKLINE == *default_full_node_port* || $WORKLINE == *log_syslog_port* ]]; then
        continue
     fi
   TESTSECTION=$(c1grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^logging:' <<< "$WORKLINE" )
     if [[ $TESTSECTION != '' && $TESTSECTION != $SECTION ]]; then 
       SECTION=$TESTSECTION 
     fi
     if [[ $LASTLINE == *_peer:* || $LASTLINE == *vdf_server:* ]]; then
        LASTLINE=$WORKLINE
        continue
     fi
     LASTLINE=$WORKLINE  
     if [[ $SECTION == *full_node:* && $WORKLINE == *rpc_port:* ]]; then 
       FULLNODERPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *full_node:* && $WORKLINE == *port:* ]]; then 
       FULLNODEPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *farmer:* && $WORKLINE == *rpc_port:* ]]; then 
       FARMERRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1')
       continue 
     fi
     if [[ $SECTION == *farmer:* && $WORKLINE == *port:* ]]; then 
       FARMERPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1')
       continue 
     fi
     if [[ $SECTION == *harvester:* && $WORKLINE == *rpc_port:* ]]; then 
       HARVESTERRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi  
     if [[ $SECTION == *harvester:* && $WORKLINE == *port:* ]]; then 
       HARVESTERPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *wallet:* && $WORKLINE == *rpc_port:* ]]; then 
       WALLETRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi  
     if [[ $SECTION == *wallet:* && $WORKLINE == *port:* ]]; then 
       WALLETPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *ui:* && $WORKLINE == *rpc_port:* ]]; then 
       UIRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi  
     if [[ $SECTION == *ui:* && $WORKLINE == *port:* && $WORKLINE != *daemon_port:* ]]; then 
       UIPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *timelord_launcher:* && $WORKLINE == *port:* ]]; then 
       TIMELORDLAUNCHERPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
     if [[ $SECTION == *timelord:* && $WORKLINE == *port:* ]]; then 
       TIMELORDPORT=$(sed 's/port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi  
     if [[ $SECTION != *ui:* && $WORKLINE == *daemon_port:* ]]; then 
       DAEMONPORT=$(sed 's/daemon_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
       continue
     fi
   done < <(printf '%s\n' "$MEMORYCONFIG")
   IFS=$OLDIFS
   PORTPARSINGDONE=1


