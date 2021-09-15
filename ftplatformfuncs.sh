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
      netstat -atnp 2>/dev/null | grep -v TIME_WAIT
    }
    function forkmemory () {
      echo 'N/A'
    }
    function DateToEpoch () {
      { read DT ; date -j -f "%Y-%m-%dT%H:%M:%S" "$DT" "+%s" ; } | awk '{$1=$1};1'
    }
    function EpochToDate () {
      { read DT ; date -j -f "@%s" "$DT" "+%Y-%m-%dT%H:%M:%S" ; } | awk '{$1=$1};1'
    }
else
    function DateOffset () {
      date -d $2"${1} day" +"%Y-%m-%d"
    }
    function forkss () {
      ss -atnp 2>/dev/null | grep -v TIME-WAIT
    }
    function forkmemory () {
      for pid in $(pgrep ^${fork}_); do 
         awk '/Pss:/{ sum += $2 } END { print sum }' /proc/${pid}/smaps 
      done | awk '{ sum +=$1/1024 } END {printf "%7.0f MB\n", sum}'
    }
    function DateToEpoch () {
      date --date="$1" +%s | awk '{$1=$1};1'
    }
    function EpochToDate () {
      date -f - +%Y-%m-%dT%H:%M:%S
    }
fi

