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
else
    function DateOffset () {
        date -d $2"${1} day" +"%Y-%m-%d"
    }
    function forkss () {
      ss -atnp 2>/dev/null | grep -v TIME-WAIT
    }
    
fi

