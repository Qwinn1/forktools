# platform-specific function definitions
if [[ $OSTYPE == 'darwin'* ]]; then
    function DateOffset () {
      if [ $# -eq 1 ] ; then
          date -j -v${1}d +"%Y-%m-%d"
      else
          date -j -f "%Y-%m-%d" -v${1}d $2 +"%Y-%m-%d"
      fi
    }
    function forkss () {
      join <(ps x -o pid,comm | awk '{print $1 " \"" $2 "\""}' | sort) <(lsof -i4 -i TCP -n -P | grep LISTEN | awk '{print $2 " " $9 " :"}' | sort)
    }
    function forkssoutput () {
      CONFLICTS=$( forkss | grep :$port[^0-9] | grep -v '"'${FORKNAME}_ )
      if [[ $CONFLICTS != '' ]]; then
         if [[ $SCANNEDMSG == 0 ]]; then
            printf "Scanned %-15.15s - Conflicts Found!\n" $fork
            SCANNEDMSG=1
         fi
         echo "$fork port $port in use by:  $CONFLICTS"
      fi
      return 0
    }
    function forkmemory () {
      ps -x -o rss= -p $(pgrep ^${fork}_) | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
    }
    function DateToEpoch () {
      xargs -I {} date -j -f "%Y-%m-%dT%H:%M:%S" "{}" "+%s" | awk '{$1=$1};1'
    }
    function EpochToDate () {
      xargs -I {} date -j -f "@%s" "{}" "+%Y-%m-%dT%H:%M:%S" | awk '{$1=$1};1'
    }
else
    function DateOffset () {
      date -d $2"${1} day" +"%Y-%m-%d"
    }
    function forkss () {
      ss -atnp 2>/dev/null | awk '{ printf "%s %s %s\n", $1, $4, $6 }' | grep -v TIME-WAIT | grep -v FIN-WAIT
    }
    function forkssoutput () {
      if [[ $FORKNAME == 'littlelambocoin' ]]; then
        CONFLICTS=$( forkss | grep :$port[^0-9] | grep -v '"'${FORKNAME} | sed 's/((//' | grep -Eo '.*users:"[^"]*["]' | sed 's/users://' )
      else
        CONFLICTS=$( forkss | grep :$port[^0-9] | grep -v '"'${FORKNAME}_ | sed 's/((//' | grep -Eo '.*users:"[^"]*["]' | sed 's/users://' )
      fi
      if [[ $CONFLICTS != '' ]]; then
         if [[ $SCANNEDMSG == 0 ]]; then
            printf "Scanned %-15.15s - Conflicts Found!\n" $fork
            SCANNEDMSG=1
         fi
         OLDIFS=$IFS
         IFS=''
         TITLES=$( ss -atnp | head -1 | awk '{$1=$1};1' )
         TITLES=$( awk    '{ printf ("                                       %-8.8s %-5.5s %-19.19s %-50s\n", $1, $4, $5, $8 ); }' <<< "$TITLES" )
         echo $TITLES
         CONFDESC=$(echo "$fork port $port in use by:" )
         CONFLICTS=$( awk -v confdesc="$CONFDESC" '{ printf ("%-38.38s %-8.8s %-25.25s %-50s\n", confdesc, $1, $2, $3 ); }' <<< "$CONFLICTS" )
         echo $CONFLICTS         
         IFS=$OLDIFS
      fi
    }
    function forkmemory () {
      for pid in $(pgrep ^${fork}_); do 
         awk '/Pss:/{ sum += $2 } END { print sum }' /proc/${pid}/smaps 
      done | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
    }
    function DateToEpoch () {
      date -f - +%s | awk '{$1=$1};1'
    }
    function EpochToDate () {
      date -f - +%Y-%m-%dT%H:%M:%S
    }
fi

