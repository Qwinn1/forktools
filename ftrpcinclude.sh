
# All RPC calls and most data assembly for forkmon and forkexplorer occurs in this include.

if [[ $FORKNAME != 'chia' && $FORKNAME != 'xcha' && $FORKNAME != 'fishery' && $FORKNAME != 'rose' && $FORKNAME != 'nchain' ]]; then
  FARMERPROCESS='\s'$FORKNAME'_farmer'
  FARMERRUNNING=$(ps -ef | grep -e $FARMERPROCESS | grep -v grep)
  if [ -z "$FARMERRUNNING" ]; then
     echo "Farmer for $FORKNAME is not running, skipping."
     continue
  fi
else
  FARMERRUNNING=1  # if it isn't, we'll be skipping the fork completely
  case "$FORKNAME" in
    "chia"            ) PORTTOSEARCH=":8559 ";;
    "xcha"            ) PORTTOSEARCH=":5159 ";;
    "nchain"          ) PORTTOSEARCH=":38559 ";;
    "fishery"         ) PORTTOSEARCH=":4799 ";;
    "rose"            ) PORTTOSEARCH=":8459 ";;
  esac
  CHIAPORTINUSE=$(forkss | grep '"chia_farm' | grep -c $PORTTOSEARCH )
  if [[ $CHIAPORTINUSE == 0 ]]; then
     echo "Farmer for $FORKNAME is not running, skipping."
     continue
  fi
fi

if [[ $FORKNAME != 'chia' && $FORKNAME != 'xcha' && $FORKNAME != 'fishery' && $FORKNAME != 'rose' && $FORKNAME != 'nchain' ]]; then
  FULLNODEPROCESS='\s'$FORKNAME'_full_n'
  FULLNODERUNNING=$(ps -ef | grep -e $FULLNODEPROCESS | grep -v grep)
  if [ -z "$FULLNODERUNNING" ]; then
     echo "Full Node for $FORKNAME is not running, skipping."
     continue
  fi
else
  case "$FORKNAME" in
    "chia"            ) PORTTOSEARCH=":8555 ";;
    "xcha"            ) PORTTOSEARCH=":5155 ";;
    "nchain"          ) PORTTOSEARCH=":38555 ";;
    "fishery"         ) PORTTOSEARCH=":4795 ";;
    "rose"            ) PORTTOSEARCH=":8025 ";;
  esac
  CHIAPORTINUSE=$(forkss | grep '"chia_full' | grep -c $PORTTOSEARCH )
  if [[ $CHIAPORTINUSE == 0 ]]; then
     echo "Full node for $FORKNAME is not running, skipping."
     continue
  fi
fi


CURRENTCONFIG=$FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml

# CD and activate venv
cd $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain
. ./activate

# Get full_node, harvester and farmer rpc ports.  Uses c1grep function instead of grep so as to not trigger ERROR trap code 1 (no line found) which is intended
OLDIFS=$IFS
IFS=''
MEMORYCONFIG=$(cat $CURRENTCONFIG | c1grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^logging:' -e 'rpc_port: ') 
while read line; do
   WORKLINE=$(sed 's/#.*//' <<< "$line" )  # This removes any comments from consideration for alteration
   TESTSECTION=$(c1grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^logging:' <<< "$WORKLINE" )
  if [[ $TESTSECTION != '' && $TESTSECTION != $SECTION ]]; then 
    SECTION=$TESTSECTION 
  fi
  if [[ $SECTION == *full_node:* && $WORKLINE == *rpc_port:* ]]; then 
    FULLNODERPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
  fi
  if [[ $SECTION == *farmer:* && $WORKLINE == *rpc_port:* ]]; then 
    FARMERRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
  fi
  if [[ $SECTION == *harvester:* && $WORKLINE == *rpc_port:* ]]; then 
    HARVESTRPCPORT=$(sed 's/rpc_port: //' <<< "$WORKLINE" | awk '{$1=$1};1') 
  fi  
done < <(printf '%s\n' "$MEMORYCONFIG")
IFS=$OLDIFS

PEERCOUNT=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_connections | python -m json.tool)
IFS=''
PEERCOUNT=$(echo $PEERCOUNT | grep -c '"type": 1' )
IFS=$OLDIFS

# Get coin name
COINNAME=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_network_info | python -m json.tool)
COINNAME=$(echo $COINNAME | sed 's/.*"network_prefix": "//' | sed 's/",.*//' | tr [a-z] [A-Z] | awk '{$1=$1};1')


# Get major-minor multiplier
# Hard coding to account for crappy lack of proper fork renaming. 
MMMULTIPLIERNAME=$FORKNAME
if [[ $FORKNAME == 'silicoin' || $FORKNAME == 'nchain' || $FORKNAME == 'fishery' || $FORKNAME == 'xcha' || $FORKNAME = 'lucky' || $FORKNAME = 'rose' ]]; then
  MMMULTIPLIERNAME='chia'
fi
MMMULTIPLIER=$( cat $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain/$FORKNAME/consensus/block_rewards.py | grep "^_.*_per_$MMMULTIPLIERNAME =" | sed 's/.*=//' | sed 's/_//g' | awk '{$1=$1};1')
MMMULTIPLIER=$(echo "(( $MMMULTIPLIER ))" | bc )
if [[ $FORKNAME == 'fishery' ]]; then
  # this is what they set "_mojo_per_chia" to in their block_rewards.py
  # 1000000000 * 0.001 * 3
  # this is exactly the first thing they teach you to always do in scripting school.  Declare all constants as calculations.
  # shouldn't have changed your name
  MMMULTIPLIER=1000000000   # For some reason, actually doing the full calculation breaks things.
fi

# Get wallet target address (can be different from what is set in config.yaml, if config was directly edited after last time farmer was started)
ADDRESS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{"search_for_private_key":false}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_reward_targets | python -m json.tool )
ADDRESS=$(echo $ADDRESS | sed 's/.*"farmer_target": "//' | sed 's/",.*//' | awk '{$1=$1};1')

# Address override.  Pass to forkexplore as -a parameter.
if [[ $SPECIFIEDADDRESS != '' ]]; then
  ADDRESS=$SPECIFIEDADDRESS
fi

# Get puzzle hash for that address
PUZZLEHASH=$(echo "python3 -c 'import $FORKNAME.util.bech32m as b; print(b.decode_puzzle_hash(\""$ADDRESS"\"). hex())'")
PUZZLEHASH=$(eval $PUZZLEHASH)


# Get coin history for address
COININFO=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"puzzle_hash\":\""$PUZZLEHASH"\", \"include_spent_coins\":true}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_coin_records_by_puzzle_hash | python -m json.tool")
COININFO=$(eval $COININFO)

IFS=''
# Parse JSON for one line per coin
TIMESTAMPEPOCHLIST=$(grep "timestamp"  <<< "$COININFO" | sed 's/"timestamp"://' | sed 's/,//' | awk '{$1=$1};1' | awk '{print "@"$1}' | EpochToDate )
COINAMOUNTLIST=$(grep "amount"  <<< "$COININFO" | sed 's/"amount"://' | sed 's/,//' | awk '{$1=$1};1' )
COINBASELIST=$(grep "coinbase"  <<< "$COININFO" | sed 's/"coinbase"://' | sed 's/,//' | awk '{$1=$1};1' )
CONFIRMEDLIST=$(grep "confirmed_block_index"  <<< "$COININFO" | sed 's/"confirmed_block_index"://' | sed 's/,//' | awk '{$1=$1};1' )
SPENTLIST=$(grep "spent_block_index"  <<< "$COININFO" | sed 's/"spent_block_index"://' | sed 's/,//' | awk '{$1=$1};1' )

MERGEDCOINLIST=$(paste <(printf %s "$TIMESTAMPEPOCHLIST") <(printf %s "$COINAMOUNTLIST") <(printf %s "$COINBASELIST") <(printf %s "$CONFIRMEDLIST") <(printf %s "$SPENTLIST") | sort)

if [[ $HIDEBALANCE != 1 ]]; then
   # Sum address balance from unspent MERGEDCOINLIST
   ADDRESSBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20f' <<< "$MERGEDCOINLIST" )
   # A ton of extra formatting work for ridiculous forks with like 20000 block rewards (looking at you cryptodoge and chaingreen)
   if [[ "$ADDRESSBALANCE" > 9999 ]]; then
      ADDRESSBALANCE= $( (($ADDRESSBALANCE / 1000)) | bc )
      ADDRESSBALANCE="$ADDRESSBALANCE"K
   fi
fi

TODAYADDRESSCHANGE=$(grep $TODAYSTAMP <<< "$MERGEDCOINLIST")
TODAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20f' <<< "$TODAYADDRESSCHANGE" )
YESTERDAYADDRESSCHANGE=$(grep $YESTERDAYSTAMP <<< "$MERGEDCOINLIST")
YESTERDAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20f' <<< "$YESTERDAYADDRESSCHANGE")
IFS=DEFAULT_IFS

# Sum farmed balance from coinbase = true
IFS=$'\t' 
FARMEDBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($3 == "true") s += (( $2 / mult )); }' OFMT='%20.20f' <<< "$MERGEDCOINLIST" )
IFS=''

BLOCKCHAINSTATE=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_blockchain_state | python -m json.tool)

# FARMCONNECTIONS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_connections | python -m json.tool)

FARMSYNCMODE=$(grep '"sync_mode":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
FARMSYNCED=$(grep '"synced":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
FARMSTATUS='RPC Failed'
if [ -z "$FARMERRUNNING" ]; then
    FARMSTATUS='Not Running'
  elif [[ $FARMSYNCMODE != 'false' ]]; then
    FARMSTATUS='Syncing'
  elif [[ $FARMSYNCED != 'true' ]]; then
    FARMSTATUS='Not Synced'
  else FARMSTATUS='Farming'  
fi


# The following two chunks of code (for CURHEIGHT and PREVHEIGHT) duplicates chia's process for determining average time per block, which goes into ETW calculation
# Grabs current block, then block 500 lower, gets difference in timestamps, then calculates average

CURHEIGHT=$(grep '"height":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
PEAKHEIGHT=$CURHEIGHT
CURPREVHASH=$(grep '"prev_hash":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
CURBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$CURPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
CURBLOCK=$(eval $CURBLOCK)
CURTIMESTAMP=$(grep '"timestamp":' <<< "$CURBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
while [ "$CURTIMESTAMP" == 'null' ]; do
  CURPREVHASH=$(grep '"prev_hash":' <<< "$CURBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
  CURBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$CURPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
  CURBLOCK=$(eval $CURBLOCK)  
  CURTIMESTAMP=$(grep '"timestamp":'  <<< "$CURBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
done
CURHEIGHT=$(grep '"height":'  <<< "$CURBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )

let PREVHEIGHT=$CURHEIGHT-500
PREVBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"height\":$PREVHEIGHT}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record_by_height | python -m json.tool")
PREVBLOCK=$(eval $PREVBLOCK)
PREVTIMESTAMP=$(grep '"timestamp":' <<< "$PREVBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
while [ "$PREVTIMESTAMP" == 'null' ]; do
  PREVPREVHASH=$(grep '"prev_hash":' <<< "$PREVBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
  PREVBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$PREVPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
  PREVBLOCK=$(eval $PREVBLOCK)  
  PREVTIMESTAMP=$(grep '"timestamp":'  <<< "$PREVBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
done
PREVHEIGHT=$(grep '"height":'  <<< "$PREVBLOCK" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )

let DIFFHEIGHT=$CURHEIGHT-$PREVHEIGHT
let DIFFTIME=$CURTIMESTAMP-$PREVTIMESTAMP
AVGBLOCKTIME=$(echo "($DIFFTIME / $DIFFHEIGHT)" | bc -l)
# echo $DIFFTIME " " $DIFFHEIGHT " " "Avg" $AVGBLOCKTIME

RPCSPACEBYTES=$(grep '"space":' <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
NETSPACE=$( assemble_bytestring "$RPCSPACEBYTES" )

# This works only on Avocado, normally get_plots is a harvester rpc call, not a farmer.  But it works like get_harvesters.  Will keep this here as reminder,
# but will otherwise get the plot info from farm summary, which is correct for avocado, unlike the other bunch of un-maintained forks I have to make an 
# exception for.
# GETPLOTS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_plots | python -m json.tool )
# echo "$GETPLOTS"

# RPC calls works on most forks and is much faster than farm summary.  If it doesn't work, we'll use farm summary.
# Avocado is weird in that they renamed "get_harvesters" to "get_plots", so we call it differently
IFS=''
if [[ $FORKNAME = "avocado" ]]; then
   HARVESTERLIST=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_plots | python -m json.tool )
else
   HARVESTERLIST=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_harvesters | python -m json.tool )
fi

IFS=$'\n'
if [[ $HARVESTERLIST == '' ]]; then
  BADFORKSUM=$(fork $FORKNAME sum);
  SIZEOFPLOTS=$(grep "Total size of plots:"  <<< "$BADFORKSUM" | sed 's/Total size of plots://' | awk '{$1=$1};1' )
  CANSEEHARVESTERS=$(grep -c "Plot count for all harvesters:" <<< "$BADFORKSUM" )
  if [[ "$CANSEEHARVESTERS" > 0 ]]; then
    PLOTCOUNT=$(grep "Plot count for all harvesters:"  <<< "$BADFORKSUM" | sed 's/Plot count for all harvesters://' | awk '{$1=$1};1' )  
  else
    PLOTCOUNT=$(grep "Plot count:"  <<< "$BADFORKSUM" | sed 's/Plot count://' | awk '{$1=$1};1' )  
  fi
  PLOTSPACEBYTES=$(echo $SIZEOFPLOTS | awk '{ print $1 }' | awk '{$1=$1};1')
  PLOTSPACEUNIT=$(echo $SIZEOFPLOTS | awk '{ print $2 }' | awk '{$1=$1};1')
  if [ $PLOTSPACEUNIT == "EiB" ]; then
    PLOTSPACEBYTES=$(echo "($PLOTSPACEBYTES * 1024)" | bc)
    PLOTSPACEUNIT="PiB"
  fi
  if [ $PLOTSPACEUNIT == "PiB" ]; then
    PLOTSPACEBYTES=$(echo "($PLOTSPACEBYTES * 1024)" | bc)
    PLOTSPACEUNIT="TiB"  
  fi
  if [ $PLOTSPACEUNIT == "TiB" ]; then
    PLOTSPACEBYTES=$(echo "($PLOTSPACEBYTES * 1024)" | bc)
    PLOTSPACEUNIT="GiB"  
  fi
  PLOTSPACEBYTES=$(echo "($PLOTSPACEBYTES * 1073741824)" | bc) # Number of bytes in a GiB.  1024 cubed.
  PLOTSPACEUNIT="bytes"  
else
  PLOTSIZELIST=$(grep "file_size" <<< "$HARVESTERLIST" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' ) 
  PLOTCOUNT=$(echo "$PLOTSIZELIST" | wc -l )
  PLOTSPACEBYTES=$(awk 'END { print s } { s += $1 }' OFMT='%.20g' <<< "$PLOTSIZELIST" )
fi
IFS=$OLDIFS

PROPORTION=$(echo "scale = 20; ($PLOTSPACEBYTES / $RPCSPACEBYTES)" | bc -l)
ETWMIN=$(echo "scale = 20; ($AVGBLOCKTIME / 60)" | bc -l )
ETWMIN=$(echo "scale = 20; ($ETWMIN / $PROPORTION)" | bc -l )
ETWSEC=$(echo "($ETWMIN * 60)" | bc)
ETWTEXT=$( assemble_timestring ${ETWSEC/.*} 's' 2 4 2 )

IFS=''
CURRENTDATEEPOCH=$(date +%s)
LASTBLOCKDATE=$(c1grep 'true' <<< "$MERGEDCOINLIST" | tail -1 | awk '{print $1}' )
if [[ $LASTBLOCKDATE == '' ]]; then
  BLOCKWON='false'
  # Calculate effort from date of first harvest in logs if possible
  # For speed purposes, find the highest log available instead of grabbing them all
  FIRSTLOG=$( find $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/log/debug.log.* | sed 's/.*debug\.log\.//' | sort -n | tail -1 )
  FIRSTLOG=$( echo "debug.log.$FIRSTLOG" )
  FIRSTHARVESTLINE=$(cat $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/log/$FIRSTLOG | grep "eligible for farming" | sort | head -1)  
  if [[ $FIRSTHARVESTLINE != '' ]]; then
    FIRSTHARVESTTIME=$(sed 's/\..*//' <<< "$FIRSTHARVESTLINE" | awk '{$1=$1};1')
    FIRSTHARVESTEPOCH=$(echo "$FIRSTHARVESTTIME" | DateToEpoch )
    SECONDSSINCESTART=$(echo "($CURRENTDATEEPOCH - $FIRSTHARVESTEPOCH)")
    EFFORT=$(echo "($SECONDSSINCESTART / $ETWSEC * 100)" | bc -l)    
  else
    EFFORT=99999
  fi
else
  BLOCKWON='true'
  LASTBLOCKEPOCH=$(echo $LASTBLOCKDATE | DateToEpoch )
  SECONDSSINCEHIT=$(echo "($CURRENTDATEEPOCH - $LASTBLOCKEPOCH)")  
  MINUTESSINCEHIT=$(echo "($SECONDSSINCEHIT / 60)" | bc )  
  LASTBLOCKAGOTEXT=$( assemble_timestring ${SECONDSSINCEHIT/.*} 's' 2 4 2 )
  EFFORT=$(echo "($SECONDSSINCEHIT / $ETWSEC * 100)" | bc -l)
fi
IFS=$OLDIFS

