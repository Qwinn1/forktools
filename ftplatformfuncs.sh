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
      join <(ps x -o pid,comm | awk '{print $1 " \"" $2 "\""}' | sort) <(lsof -i4 -i TCP -n | grep LISTEN | awk '{print $2 " " $9 " :"}' | sort)
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
      ss -atnp 2>/dev/null | grep -v TIME-WAIT | grep -v FIN-WAIT | grep -v SYN-SENT
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

