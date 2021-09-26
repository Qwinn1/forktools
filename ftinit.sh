# To be included in all forktools.  Calls all configuration includes and defines forktools functions.

HELPREQUEST=$(echo $* | grep '-help' ) 
if [[ $HELPREQUEST != '' ]]; then
  print_usage
  exit
fi   

. ftplatformfuncs.sh

# Display forktool startup string.  Silenced after first time so forktools can call other forktools without redisplaying in the call.
# Also makes sure that any redirected errors go to the parent forktool's error log, not to the log of a called forktool.
if [[ $FTBASECOMMAND == '' ]]; then
  export FTBASECOMMAND=$( echo $0 | sed 's|.*forktools/||' | sed 's/q$//' )
  export FTFULLCOMMAND=$( echo $FTBASECOMMAND $* )  
  echo "'$FTFULLCOMMAND' initiated on `date`..."
  echo
  if [[ $FTERRORSTOFILE == 'Yes' ]]; then
    exec 3>&2  # capture current stderr output destination
    exec 2>> "$FORKTOOLSDIR/ftlogs/$FTBASECOMMAND.errors" #reroute stderr
    echo "'$FTFULLCOMMAND' initiated on" $(date) >> "$FORKTOOLSDIR/ftlogs/$FTBASECOMMAND.errors"
  fi  
fi

if [[ $VALIDATEFORKNAME == 'Yes' && ! -d $FORKTOOLSBLOCKCHAINDIRS/$1-blockchain ]]; then
   echo "$FTFULLCOMMAND:  Directory $1-blockchain does not exist.  '$FTBASECOMMAND' aborted."
   exit
fi
   
trap stopforkscript SIGINT
stopforkscript() {
   echo -e "\nCtrl-C detected.  $FTPARENTSCRIPT aborted."
   echo
   echo "'$FTFULLCOMMAND' interrupted by user (errors immediately above likely due to this) on" $(date) >> "$FORKTOOLSDIR/ftlogs/$FTBASECOMMAND.errors"
   if [[ $FTERRORSTOFILE == 'Yes' ]]; then   
     exec 2>&3 #Restore stderr destination"
   fi
   exit
}

#### LOGGING SETTINGS
. $FORKTOOLSDIR/ftconfigs/config.logging


#### Call corresponding include for the forktool we're running.  
# We'll include forkstartall for any run of forkstart, even if it's not 'forkstart all'
FTCURRENTTOOL=$( echo $0 | sed 's|.*forktools/||' | sed 's/q$//' )
if [[ $FTCURRENTTOOL == 'forkstart' ]]; then
  FTCURRENTTOOL='forkstartall'
fi
if [[ -f $FORKTOOLSDIR/ftconfigs/config.$FTCURRENTTOOL ]]; then
  . $FORKTOOLSDIR/ftconfigs/config.$FTCURRENTTOOL
fi


# Constants and Dates
DEFAULT_IFS=$' \t\n'
TODAYSTAMP=`date +"20%y-%m-%d"`
YESTERDAYSTAMP=$(DateOffset -1)


##  FUNCTIONS

# Takes a period of time and represents it in the form of "1d 2h 3m 4s"
assemble_timestring () {
  # Currently works from days to seconds.
  # Parameter $1:  # of the provided unit
  # Parameter $2:  "m" or "s" - unit of parameter $1, as a single character.  Example:  to convert "432 minutes" to an ago string, pass in 432 and "m"
  # Parameter $3:  Lowest unit to return.  1 = second, 2 = minute, 3 = hour, 4 = day
  # Parameter $4:  Highest unit to return.  1 = second, 2 = minute, 3 = hour, 4 = day
  # Parameter $5:  Maximum time units to concatenate.  Defaults to 2.
  TIMECOUNTER=$1
  TIMEUNIT=$2
  TIMEMINUNIT=$3
  TIMEMAXUNIT=$4
  LASTBLOCKAGOTEXT=''
  TIMEMAXFINALUNITS=2  
  RETURNTEXT=''
  if [[ -n $5 ]]; then
    TIMEMAXFINALUNITS=$5
  fi

  if [[ $TIMECOUNTER == 'm' ]]; then # We'll work with seconds only
     TIMECOUNTER=$(echo $(("$TIMECOUNTER * 60")))
  fi
  
  if [[ $TIMECOUNTER -gt 86399 && $TIMEMAXUNIT -gt 3 && $TIMEMAXFINALUNITS -gt 0 ]]; then
    TIMECURRENTAMT=$(echo $(("$TIMECOUNTER / 86400")))
    TIMECURRENTUNIT='d'
    RETURNTEXT=$(echo "$TIMECURRENTAMT$TIMECURRENTUNIT")
    TIMECOUNTER=$(echo $(( $TIMECOUNTER % 86400)))
    TIMEMAXFINALUNITS=$TIMEMAXFINALUNITS-1
  fi
  if [[ $TIMECOUNTER -gt 3599 && $TIMEMINUNIT -lt 4 && $TIMEMAXUNIT -gt 2 && $TIMEMAXFINALUNITS -gt 0 ]]; then
    TIMECURRENTAMT=$(echo $(("$TIMECOUNTER / 3600")))
    TIMECURRENTUNIT='h'
    RETURNTEXT=$(echo "$RETURNTEXT$TIMECURRENTAMT$TIMECURRENTUNIT")
    TIMECOUNTER=$(echo $(( $TIMECOUNTER % 3600)))
    TIMEMAXFINALUNITS=$TIMEMAXFINALUNITS-1
  fi
  if [[ $TIMECOUNTER -gt 59 && $TIMEMINUNIT -lt 3 && $TIMEMAXUNIT -gt 1 && $TIMEMAXFINALUNITS -gt 0 ]]; then
    TIMECURRENTAMT=$(echo $(("$TIMECOUNTER / 60")))
    TIMECURRENTUNIT='m'
    RETURNTEXT=$(echo "$RETURNTEXT$TIMECURRENTAMT$TIMECURRENTUNIT")
    TIMECOUNTER=$(echo $(( $TIMECOUNTER % 60)))
    TIMEMAXFINALUNITS=$TIMEMAXFINALUNITS-1
  fi
  if [[ $TIMECOUNTER -gt 0 && $TIMEMINUNIT -lt 2 && $TIMEMAXUNIT -gt 0 && $TIMEMAXFINALUNITS -gt 0 ]]; then
    TIMECURRENTAMT=$(echo $(("$TIMECOUNTER / 1")))
    TIMECURRENTUNIT='s'
    RETURNTEXT=$(echo "$RETURNTEXT$TIMECURRENTAMT$TIMECURRENTUNIT")
  fi
  
  RETURNTEXT=$(echo "$RETURNTEXT" | awk '{$1=$1};1' )
  echo $RETURNTEXT
}

# Convert bytes to TiB/PiB/EiB
assemble_bytestring() {
  #Parameter1:  # of bytes
  BYTECOUNT=$1
  # Let's go straight to gigabytes, given plot sizes
  BYTECOUNT=$(echo "scale=0; (( $BYTECOUNT / 1073741824 )) " | bc )
  BYTECOUNTUNIT='GiB'

  if [[ "$BYTECOUNT" -gt 1023 ]]; then
    BYTECOUNT=$(echo "scale=0; (( $BYTECOUNT / 1024 ))" | bc )
    BYTECOUNTUNIT='TiB'
  fi
  if [[ "$BYTECOUNT" -gt 1023 ]]; then
    BYTECOUNT=$(echo "scale=0; (( $BYTECOUNT / 1024 ))" | bc ) 
    BYTECOUNTUNIT='PiB'
  fi
  if [[ "$BYTECOUNT" -gt 1023 ]]; then
    BYTECOUNT=$(echo "scale=1; (( $BYTECOUNT / 1024 ))" | bc )
    BYTECOUNTUNIT='EiB'
  fi
 
  RETURNTEXT=$(echo "$BYTECOUNT $BYTECOUNTUNIT")    
  echo $RETURNTEXT
}

# Used to make sure that a grep that is expected to sometimes not find any results doesn't return a 1 and trigger error trapping
c1grep() { grep -a "$@" || test $? = 1; }


