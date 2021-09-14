# To be included in all forktools.  Calls all configuration includes and defines forktools functions.

. ftplatformfuncs.sh


#### START CONFIGURATION INCLUDE CALLS

# In version 2.1+, all configurations have been moved to sub-includes in order to keep them totally separated from the code,
# so they will not need to be overwritten by future updates.


#### FORKADDPLOTDIRS SETTINGS
# List all your plot directories in config.forkaddplotdirs.

. config.forkaddplotdirs


#### FORKSTARTALL settings
# Configure the 3 variables in config.forkstartall to specify which forks you want forkstartall to start with forkstartf, forkstartfnw, and/or forkstarth
# forkstartf is (re)start farmer with wallet, forkstartfnw is (re)start farmer without wallet, forkstarth is (re)start harvester

. config.forkstartall


#### FORKLOG SETTINGS

# View and edit config.forklog for instructions on how to customize forklog behavior

. config.forklog


#### FORKEXPLORE SETTINGS
# View and edit config.forkexplore for instructions on how to customize forkexplore behavior

. config.forkexplore


#### FORKFIXCONFIG SETTINGS
# View and edit config.forkfixconfig for instructions on how to customize the settings forkfixconfig will set in your forks' config.yaml files

. config.forkfixconfig


#### END CONFIGURATION INCLUDE CALLS


# These two lines reroute ugly error messages after a Control-C to /dev/null.  Mainly so we don't get a lot of ugly python errors when user uses Ctrl-C while
# a fork's python function is running.

# Attempt graceful exit on Ctrl-C
trap stopForkScript SIGINT
stopForkScript() {
   echo -e "\nCtrl-C detected.  $0 aborted."
   exec 2> /dev/null #Restore stderr destination
   exit
}

function print_usage_forkname_only() {
   echo "Usage:  $0"
   echo "  forkname          Required parameter.  Name of fork executable to work with."
   echo "  -h | --help       Show this information again."
   exit
}

RUNNINGSCRIPT=$( echo $0 | sed 's|.*forktools/||' )
if [[ $VALIDATEFORKNAME = 'Yes' ]]; then
   if [[ $1 = '-h' || $1 = '--help' ]]; then
      print_usage_forkname_only
      exit
   fi
   if [ ! -d $FORKTOOLSBLOCKCHAINDIRS/$1-blockchain ]; then
      echo $RUNNINGSCRIPT "requires a valid forkname.  Directory $1-blockchain does not exist.  $RUNNINGSCRIPT aborted."
      exit
   fi
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
c1grep() { grep "$@" || test $? = 1; }



