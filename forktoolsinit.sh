# To be included in all but the simplest forktools.  Sets paths to default to $HOME installations, contains configuration of defaults for all tools,
# and defines functions


#### START CONFIGURATION SETTINGS

#### FORKLOG SETTINGS

# How many lines should forklog tail if you specify -t with no parameter?
FORKLOGTAIL=100

# The below list allows you to set different default date ranges for each log-based or transaction-dated forktool.
# FORKTOOLSTARTDATE - Do not show log entries or transactions before this date.  To show all, set this to 2021-03-19 (Chia Mainnet Launch)
# FORKTOOLLASTXDAYS - Show only the last X days (ending today/now, midnight cutoff) for the given log/transaction results.
# Set only one of the two above for a given forktool.  If both are set, the one by date takes precedence.  
# FORKTOOLSENDDATE  - Defaults to tomorrow, which will almost always be the most desirable default
# You can override these defaults at runtime with switches.  Run forklog -h or forkexplore -h for usage instructions.

# Date Format:  2021-03-19
FORKLOGSTARTDATE=
FORKLOGLASTXDAYS=5
FORKLOGENDDATE=$(date -d '+1 day' +"20%y-%m-%d") # Tomorrow
FORKEXPLORESTARTDATE=
FORKEXPLORELASTXDAYS=20
FORKEXPLOREENDDATE=$(date -d '+1 day' +"20%y-%m-%d") # Tomorrow

#### FORKSTARTALL settings
#  Set the next 3 variables to specify which forks you want forkstartall to start with forkstartf, forkstartfnw, and/or forkstarth)
#  forkstartf is (re)start farmer with wallet, forkstartfnw is (re)start farmer without wallet, forkstarth is (re)start harvester
# All these lines will be ignored until you remove the # at the beginning

FORKSTARTFLIST="# List forks to start with forkname start farmer -r
# chia
# flax
# flora
"
FORKSTARTFNWLIST='# List forks to start with forkname start farmer-no-wallet -r
cactus
cryptodoge
dogechia
hddcoin
kale
melati
olive
pipscoin
seno
silicoin
socks
taco
tad
'
FORKSTARTHLIST='# List forks to start with forkname start harvester -r
apple
avocado
beet
btcgreen
cannabis
chia
covid
flax
flora
goji
greendoge
maize
scam
'

#### FORKADDPLOTDIRS SETTINGS
# List all plot directories to add here.  Make as many lines as you need, modify to fit your own paths, then remove the #s to activate the lines):
FORKADDPLOTDIRS='
/media/qwinn/dsk11/Plot11
/media/qwinn/dsk12/Plot12
/media/qwinn/dsk13/Plot13
/media/qwinn/dsk14/Plot14
/media/qwinn/dsk17/Plot17
/media/qwinn/dsk18/Plot18
/media/qwinn/dsk19/Plot19
/media/qwinn/dsk21/Plot21
/media/qwinn/dsk23/Plot23
/media/qwinn/dsk27/Plot27
/plotter1/stage1
/plotter2/stage2
'

#### FORKFIXCONFIG SETTINGS
# Set desired values.  Set to '' to not modify the existing value in the config.yaml.
SETLOGLEVEL='INFO'            # Default chia value: 'WARNING'. Strongly recommend setting to 'INFO' for all forks. Some forktools will not work well without this.
SETMAXLOGROTATION='99'        # Default chia value: 7. The number of logs to retain. I strongly recommend setting to 99 or even higher, to preserve full history.
SETPLOTLOADFREQUENCY='18000'  # Default chia value: 120 seconds (2 minutes). Recommend 1800 (30 minutes) if still plotting, 18000 (5 hours) if done plotting.
SETFNTARGETPEERCOUNT='80'     # Default chia value: 80. I don't have a recommendation for this one, but some people like to adjust it, so here's the option.
SETBATCHSIZE='1500'           # Default chia value: Initially 30, now 300. I don't have problems loading all my plots in one batch.  If you do, please report it.
SETBATCHSLEEP='1'             # Default chia value: Initially 10, now 1. 
SETMULTIPROC='4'              # IMPORTANT:  "multiprocessing_limit: X" was designed by grayfallstown and has been implemented in several forks. Meant to reduce the number of full_node processes (which is monitored by forkmon) and thus reduce RAM usage. My understanding is the unmodified value is roughly the number of your CPU cores, which is great for initial syncing, but severe overkill once synced.  Therefore, even if you leave this variable set to 4, it will not be added to your config until a full node RPC call confirms full sync.  Otherwise you'd have to edit this setting every time you wanted to forkfixconfig a new fork.

# The first of the following 3 settings was designed to simply append "multi_processing limit: ", but now that we have SETMULTIPROC, these are all currently useless. That's no reason to strip the functionality.  Was tough to get it right.  And hopefully there will be new settings to come.
APPEND1=''  # For future use
APPEND2=''  # For future use
APPEND3=''  # For future use


#### END CONFIGURATION SETTINGS



if [ -z "$FORKTOOLSDIR" ];  then # sets the forktools directory.  Defaults to $HOME/forktools.
  FORKTOOLSDIR="$HOME/forktools"
fi

if [ -z "$FORKTOOLSBLOCKCHAINDIRS" ];  # sets the parent directory for all the fork-blockchain directories if it is empty.  Defaults to $HOME.
 then
  FORKTOOLSBLOCKCHAINDIRS="$HOME"
 fi
 
if [ -z "$FORKTOOLSHIDDENDIRS" ];  # sets the parent directory for all the fork-blockchain directories if it is empty.  Defaults to $HOME.
 then
  FORKTOOLSHIDDENDIRS="$HOME"
 fi


# These two lines reroute ugly error messages to a file in forktools directory.  Mainly so we don't get a lot of ugly python errors when user uses Ctrl-C while
# a fork's python function is running.
# The exec 3 part is so we can restore error output to wherever it used to be going to when done after script finishes.

# Graceful exit on Ctrl-C
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
YESTERDAYSTAMP=$(date -d '-1 day' +"20%y-%m-%d")


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
  BYTECOUNT=$(echo $(("$BYTECOUNT / 1073741824" )) | bc -l)
  BYTECOUNTUNIT='GiB'
  
  if [[ $BYTECOUNT -gt 1023 ]]; then
    BYTECOUNT=$(echo $(("$BYTECOUNT / 1024")) | bc -l)
    BYTECOUNTUNIT='TiB'
  fi
  if [[ $BYTECOUNT -gt 1023 ]]; then
    BYTECOUNT=$(echo $(("$BYTECOUNT / 1024")) | bc -l)
    BYTECOUNTUNIT='PiB'
  fi
  if [[ $BYTECOUNT -gt 1023 ]]; then
    BYTECOUNT=$(echo $(("$BYTECOUNT / 1024")) | bc -l)
    BYTECOUNTUNIT='EiB'
  fi
  RETURNTEXT=$(echo "$BYTECOUNT $BYTECOUNTUNIT")    
  echo $RETURNTEXT
}

# Used to make sure that a grep that will be known to sometimes not find any results doesn't return a 1 and trigger error trapping
c1grep() { grep "$@" || test $? = 1; }

