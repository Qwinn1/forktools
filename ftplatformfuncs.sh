# platform-specific function definitions
if [[ $OSTYPE == 'darwin'* ]]; then
    function getlocale () {
      echo 'en_US.UTF-8'
    }
    function DateOffset () {
      if [ $# -eq 1 ] ; then
          date -j -v${1}d +"%Y-%m-%d"
      else
          date -j -f "%Y-%m-%d" -v${1}d $2 +"%Y-%m-%d"
      fi
    }
    function MonthOffset () {
      if [ $# -eq 1 ] ; then
          date -j -v${1}m +"%Y-%m"
      else
          date -j -f "%Y-%m" -v${1}m $2 +"%Y-%m"
      fi
    }
    function forkss () {
      join <(ps x -o pid,comm | awk '{print $1 " \"" $2 "\""}' | sort) <(lsof -i4 -i TCP -n -P | grep LISTEN | awk '{print $2 " " $9 " :"}' | sort)
    }
    function forkssoutput () {
      OLDIFS=$IFS
      IFS=''
      CONFLICTS=$( echo $FORKSS | grep :$port[^0-9] | grep -v '"'${PROCESSNAME}_ )
      if [[ $CONFLICTS != '' ]]; then
         if [[ $SCANNEDMSG == 0 ]]; then
            printf "Scanned %-15.15s - Conflicts Found!\n" $fork
            SCANNEDMSG=1
         fi
         echo "$fork port $port in use by:  $CONFLICTS"
      fi
      IFS=$OLDIFS      
      return 0
    }
    function platformpwdx () {
       PROCPID=$1
       echo `lsof -a -d cwd -p $PROCPID -n -Fn | awk '/^n/ {print substr($0,2)}'`
    }

    # The next two get a process list with pid and directory process was launched from
    function getsymlinklist () {
       OLDIFS=$IFS
       IFS=''
       SYMLINKLIST=$( find $FORKTOOLSBLOCKCHAINDIRS -maxdepth 1 -type l -ls | grep "blockchain" ) 
       IFS=$'\n'
       for link in $SYMLINKLIST; do
          FROMLINK=$(echo $link | awk {'print$13'} | sed 's|.*/||g' )
          TOLINK=$(echo $link | awk {'print$11'} | sed 's|.*/||g' )
          echo $FROMLINK $TOLINK
       done
       IFS=$OLDIFS
    }
    function getproclist () {
       OLDIFS=$IFS
       SYMLINKLIST=$( getsymlinklist )
       IFS=$'\n'
       for i in `ps -ef | c1grep -e 'full_node' -e 'farmer' -e 'harvester' -e 'wallet' -e '_daemon' | grep -v grep | awk {'print $8 " " $2'}` ; do
          PROCFORKNAME=$( echo $i | awk {'print$1'} | sed 's/_.*//' )
          PROCPID=$( echo $i | awk {'print$2'} )
          if [[ $PROCFORKNAME = 'chia' ]]; then
             PROCCWD=$( platformpwdx $PROCPID | sed 's|.*/||g' )
             for link in $SYMLINKLIST; do
                FROMLINK=$( echo $link | awk {'print$1'} )
                if [[ $FROMLINK = $PROCCWD ]]; then
                   PROCCWD=$( echo $link | awk {'print$2'} )
                   break
                fi
             done
          else
             PROCCWD=$( echo "${PROCFORKNAME}-blockchain" )
          fi
          printf '%s %s\n' $i $PROCCWD
          if [[ "$i" != *"_daemon"* ]]; then
             for childpid in $(pgrep -P $PROCPID) ; do
                printf '%s %s %s\n' $(echo $i | awk {'print$1'}) $childpid $PROCCWD
             done
          fi
       done
       IFS=$OLDIFS
    }

    function forkmemory () {
      # ps -x -o rss= -p $(pgrep ^${fork}_) | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
      OLDIFS=$IFS
      IFS=''
      MEMPIDLIST=$( echo $PROCESSEF | grep " ${fork}-blockchain" | awk {'print$2'} )
      IFS=$'\n'      
      ps -x -o rss= -p $(echo $MEMPIDLIST) | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
      IFS=$OLDIFS
    }
    function DateToEpoch () {
      xargs -I {} date -j -f "%Y-%m-%dT%H:%M:%S" "{}" "+%s" | awk '{$1=$1};1'
    }
    function EpochToDate () {
      xargs -I {} date -j -f "@%s" "{}" "+%Y-%m-%dT%H:%M:%S" | awk '{$1=$1};1'
    }
else
    function getlocale () {
      echo 'C.UTF-8'
    }
    function DateOffset () {
      date -d $2"${1} day" +"%Y-%m-%d"
    }
    function MonthOffset () {
      date -d $2"${1} month" +"%Y-%m"
    }    
    function forkss () {
      LOCALIPS=$( ip address | grep 'inet ' | awk '{ print $2 }'  | sed 's|/.*||' )
      # We do two passes of ss -atnp output, collecting matches of local ips on column 4 first (local), then on column 5 (peers), then concatenate
      BUILDEXPR=$(echo 'ss -atnp 2>/dev/null | ')
      BUILDEXPR=$(echo $BUILDEXPR " awk '{ printf \"%s %s %s\n\", " )
      BUILDEXPR4=$(echo $BUILDEXPR ' $1, $4, $6 }')
      BUILDEXPR5=$(echo $BUILDEXPR ' $1, $5, $6 }')
      BUILDEXPR4=$(echo $BUILDEXPR4 "' | grep -e '\[::\]' -e '0.0.0.0' " )
      BUILDEXPR5=$(echo $BUILDEXPR5 "' | grep -e '\[::\]' -e '0.0.0.0' " )      
      OLDIFS=$IFS
      IFS=$'\n'
      for localip in $LOCALIPS; do
        BUILDEXPR4=$(printf "%s -e '%s'" $BUILDEXPR4 $localip )
        BUILDEXPR5=$(printf "%s -e '%s'" $BUILDEXPR5 $localip )        
      done
      FULLLIST=$( eval $BUILDEXPR4 && eval $BUILDEXPR5 )
      IFS=''
      echo $FULLLIST      
      IFS=$OLDIFS      
    }
    function forkssoutput () {
      OLDIFS=$IFS
      IFS=''
      CONFLICTS=$( echo $FORKSS | grep :$port[^0-9] | grep -v '"'${PROCESSNAME}'"' | grep -v '"'${PROCESSNAME}_ | sed 's/((//' | grep -Eo '.*users:"[^"]*["]' | sed 's/users://' )
      if [[ $CONFLICTS != '' ]]; then
         if [[ $SCANNEDMSG == 0 ]]; then
            printf "Scanned %-15.15s - Conflicts Found!\n" $fork
            TITLES=$( ss -atnp | head -1 | awk '{$1=$1};1' )
            TITLES=$( awk    '{ printf ("                                       %-8.8s %-5.5s %-19.19s %-50s\n", $1, $4, $5, $8 ); }' <<< "$TITLES" )
            echo $TITLES
            SCANNEDMSG=1
         fi
         CONFDESC=$(echo "$fork port $port in use by:" )
         CONFLICTS=$( awk -v confdesc="$CONFDESC" '{ printf ("%-38.38s %-8.8s %-25.25s %-50s\n", confdesc, $1, $2, $3 ); }' <<< "$CONFLICTS" )
         echo $CONFLICTS         
      fi
      IFS=$OLDIFS      
    }
    function platformpwdx () {
       PROCPID=$1
       echo `pwdx $PROCPID 2>/dev/null | awk {'print$2'}`
    }

    # The next two get a process list with pid and directory process was launched from
    function getsymlinklist () {
       OLDIFS=$IFS
       IFS=''
       SYMLINKLIST=$( find $FORKTOOLSBLOCKCHAINDIRS -maxdepth 1 -type l -ls | grep "blockchain" ) 
       IFS=$'\n'
       for link in $SYMLINKLIST; do
          FROMLINK=$(echo $link | awk {'print$13'} | sed 's|.*/||g' )
          TOLINK=$(echo $link | awk {'print$11'} | sed 's|.*/||g' )
          echo $FROMLINK $TOLINK
       done
       IFS=$OLDIFS
    }
    function getproclist () {
       OLDIFS=$IFS
       SYMLINKLIST=$( getsymlinklist )
       IFS=$'\n'
       for i in `ps -ef | c1grep -e 'full_node' -e 'farmer' -e 'harvester' -e 'wallet' -e '_daemon' | grep -v grep | awk {'print $8 " " $2'}` ; do
          PROCFORKNAME=$( echo $i | awk {'print$1'} | sed 's/_.*//' )
          PROCPID=$( echo $i | awk {'print$2'} )
          if [[ $PROCFORKNAME = 'chia' ]]; then
             PROCCWD=$( platformpwdx $PROCPID | sed 's|.*/||g' )
             for link in $SYMLINKLIST; do
                FROMLINK=$( echo $link | awk {'print$1'} )
                if [[ $FROMLINK = $PROCCWD ]]; then
                   PROCCWD=$( echo $link | awk {'print$2'} )
                   break
                fi
             done
          else
             PROCCWD=$( echo "${PROCFORKNAME}-blockchain" )
          fi
          printf '%s %s\n' $i $PROCCWD
       done
       IFS=$OLDIFS
    }
    function forkmemory () {
       OLDIFS=$IFS
       IFS=''
       MEMPIDLIST=$( echo $PROCESSEF | grep " ${fork}-blockchain" | awk {'print$2'} )
       IFS=$'\n'      
       for pid in $MEMPIDLIST; do 
          awk '/Pss:/{ sum += $2 } END { print sum }' /proc/${pid}/smaps 
       done | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
       IFS=$OLDIFS
    }
    function DateToEpoch () {
      date -f - +%s | awk '{$1=$1};1'
    }
    function EpochToDate () {
      date -f - +%Y-%m-%dT%H:%M:%S
    }
fi

