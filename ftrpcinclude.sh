
# All RPC calls and most data assembly for forkmon and forkexplorer occurs in this include.


FARMERPROCESS='\s'$FORKNAME'_farmer'
FARMERRUNNING=$(ps -ef | grep -e $FARMERPROCESS | grep -v grep)
if [ -z "$FARMERRUNNING" ]; then
   echo "Farmer for $FORKNAME is not running, process aborted."
   exit
fi

CURRENTCONFIG=$FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml

# CD and activate venv
cd $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain
. ./activate

# The only hard coding I'm doing to account for crappy fork renaming practices, only because it's still testnet.  Hope they appreciate it. 
SUBMODULENAME=$FORKNAME
if [[ $FORKNAME == 'silicoin' ]]; then
  SUBMODULENAME='chia'
fi


# Get full_node, harvester and farmer rpc ports.  Uses c1grep function instead of grep so as to not trigger ERROR trap code 1 (no line found) which is intended
OLDIFS=$IFS
IFS=''
while read line; do
   WORKLINE=$(sed 's/#.*//' <<< $line )  # This removes any comments from consideration for alteration
   TESTSECTION=$(c1grep -e '^harvester:' -e '^farmer:' -e '^full_node:' -e '^timelord:' -e '^timelord_launcher:' -e '^ui:' -e '^introducer:' -e '^wallet:' -e '^logging:' <<< $WORKLINE )
  if [[ $TESTSECTION != '' && $TESTSECTION != $SECTION ]]; then 
    SECTION=$TESTSECTION 
  fi
  if [[ $SECTION == *full_node:* && $WORKLINE == *rpc_port:* ]]; then 
    FULLNODERPCPORT=$(sed 's/rpc_port: //' <<< $WORKLINE | awk '{$1=$1};1') 
  fi
  if [[ $SECTION == *farmer:* && $WORKLINE == *rpc_port:* ]]; then 
    FARMERRPCPORT=$(sed 's/rpc_port: //' <<< $WORKLINE | awk '{$1=$1};1') 
  fi
  if [[ $SECTION == *harvester:* && $WORKLINE == *rpc_port:* ]]; then 
    HARVESTRPCPORT=$(sed 's/rpc_port: //' <<< $WORKLINE | awk '{$1=$1};1') 
  fi  
done < $CURRENTCONFIG
IFS=$OLDIFS

# Get coin name
COINNAME=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_network_info | python -m json.tool)
COINNAME=$(grep -Po '"'"network_prefix"'"\s*:\s*"\K([^"]*)' <<< $COINNAME | sed 's/[a-z]/\U&/g')

# Get major-minor multiplier
MMMULTIPLIER=$( cat $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain/$SUBMODULENAME/consensus/block_rewards.py | grep "^_.*_per_$SUBMODULENAME ="| sed 's/.*=//' | awk '{$1=$1};1')

# Get wallet target address (can be different from what is set in config.yaml, if config was directly edited after last time farmer was started)
ADDRESS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{"search_for_private_key":false}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_reward_targets | python -m json.tool )
ADDRESS=$(grep -Po '"'"farmer_target"'"\s*:\s*"\K([^"]*)' <<< $ADDRESS)

# Address override.  Pass to forkexplore as -a parameter.
if [[ $SPECIFIEDADDRESS != '' ]]; then
  echo "here"
  ADDRESS=$SPECIFIEDADDRESS
fi
 
# Get puzzle hash for that address
PUZZLEHASH=$(echo "python3 -c 'import $SUBMODULENAME.util.bech32m as b; print(b.decode_puzzle_hash(\""$ADDRESS"\"). hex())'")
PUZZLEHASH=$(eval $PUZZLEHASH)

# Get coin history for address
COININFO=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"puzzle_hash\":\""$PUZZLEHASH"\", \"include_spent_coins\":true}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_coin_records_by_puzzle_hash | python -m json.tool")
COININFO=$(eval $COININFO)


# Parse JSON for one line per coin
TIMESTAMPEPOCHLIST=$(grep "timestamp"  <<< $COININFO | sed 's/"timestamp"://' | sed 's/,//' | awk '{$1=$1};1' | awk '{print "@"$1}' | date -f - +%Y-%m-%dT%H:%M:%S )
COINAMOUNTLIST=$(grep "amount"  <<< $COININFO | sed 's/"amount"://' | sed 's/,//' | awk '{$1=$1};1' )
COINBASELIST=$(grep "coinbase"  <<< $COININFO | sed 's/"coinbase"://' | sed 's/,//' | awk '{$1=$1};1' )
CONFIRMEDLIST=$(grep "confirmed_block_index"  <<< $COININFO | sed 's/"confirmed_block_index"://' | sed 's/,//' | awk '{$1=$1};1' )
SPENTLIST=$(grep "spent_block_index"  <<< $COININFO | sed 's/"spent_block_index"://' | sed 's/,//' | awk '{$1=$1};1' )

MERGEDCOINLIST=$(paste <(printf %s "$TIMESTAMPEPOCHLIST") <(printf %s "$COINAMOUNTLIST") <(printf %s "$COINBASELIST") <(printf %s "$CONFIRMEDLIST") <(printf %s "$SPENTLIST") | sort)

# Sum address balance from unspent MERGEDCOINLIST
ADDRESSBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20g' <<< $MERGEDCOINLIST )
# A ton of extra formatting work for ridiculous forks with like 20000 block rewards (looking at you cryptodoge and chaingreen)
if [[ "$ADDRESSBALANCE" > 9999 ]]; then
   ADDRESSBALANCE= $( (($ADDRESSBALANCE / 1000)) | bc )
   ADDRESSBALANCE="$ADDRESSBALANCE"K
fi

IFS=''
TODAYADDRESSCHANGE=$(grep $TODAYSTAMP <<< $MERGEDCOINLIST)
TODAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20g' <<< $TODAYADDRESSCHANGE )
YESTERDAYADDRESSCHANGE=$(grep $YESTERDAYSTAMP <<< $MERGEDCOINLIST)
YESTERDAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $2 / mult )); }' OFMT='%20.20g' <<< $YESTERDAYADDRESSCHANGE)
IFS=DEFAULT_IFS

# Sum farmed balance from coinbase = true
IFS=$'\t' 
FARMEDBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($3 == "true") s += (( $2 / mult )); }' OFMT='%20.20g' <<< $MERGEDCOINLIST )
IFS=''

BLOCKCHAINSTATE=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_blockchain_state | python -m json.tool)

# FARMCONNECTIONS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_connections | python -m json.tool)

FARMSYNCMODE=$(grep '"sync_mode":'  <<< $BLOCKCHAINSTATE | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
FARMSYNCED=$(grep '"synced":'  <<< $BLOCKCHAINSTATE | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
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

CURHEIGHT=$(grep '"height":'  <<< $BLOCKCHAINSTATE | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
CURPREVHASH=$(grep '"prev_hash":'  <<< $BLOCKCHAINSTATE | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
CURBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$CURPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
CURBLOCK=$(eval $CURBLOCK)
CURTIMESTAMP=$(grep '"timestamp":' <<< $CURBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
while [ "$CURTIMESTAMP" == 'null' ]; do
  CURPREVHASH=$(grep '"prev_hash":' <<< $CURBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
  CURBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$CURPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
  CURBLOCK=$(eval $CURBLOCK)  
  CURTIMESTAMP=$(grep '"timestamp":'  <<< $CURBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
done
CURHEIGHT=$(grep '"height":'  <<< $CURBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )

let PREVHEIGHT=$CURHEIGHT-500
PREVBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"height\":$PREVHEIGHT}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record_by_height | python -m json.tool")
PREVBLOCK=$(eval $PREVBLOCK)
PREVTIMESTAMP=$(grep '"timestamp":' <<< $PREVBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
while [ "$PREVTIMESTAMP" == 'null' ]; do
  PREVPREVHASH=$(grep '"prev_hash":' <<< $PREVBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
  PREVBLOCK=$(echo "curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{\"header_hash\":$PREVPREVHASH}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_block_record | python -m json.tool")
  PREVBLOCK=$(eval $PREVBLOCK)  
  PREVTIMESTAMP=$(grep '"timestamp":'  <<< $PREVBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
done
PREVHEIGHT=$(grep '"height":'  <<< $PREVBLOCK | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )

let DIFFHEIGHT=$CURHEIGHT-$PREVHEIGHT
let DIFFTIME=$CURTIMESTAMP-$PREVTIMESTAMP
AVGBLOCKTIME=$(echo "($DIFFTIME / $DIFFHEIGHT)" | bc -l)
# echo $DIFFTIME " " $DIFFHEIGHT " " "Avg" $AVGBLOCKTIME

RPCSPACEBYTES=$(grep '"space":' <<< $BLOCKCHAINSTATE | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
NETSPACE=$( assemble_bytestring "$RPCSPACEBYTES" )


# This works only on Avocado, normally get_plots is a harvester rpc call, not a farmer.  But it works like get_harvesters.  Will keep this here as reminder,
# but will otherwise get the plot info from farm summary, which is correct for avocado, unlike the other bunch of un-maintained forks I have to make an 
# exception for.
# GETPLOTS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_plots | python -m json.tool )
# echo "$GETPLOTS"

IFS=$'\n'
if [[ $FORKNAME = 'avocado' || $FORKNAME = 'seno' || $FORKNAME = 'chaingreen' || $FORKNAME = 'thyme' || $FORKNAME = 'equality' || $FORKNAME = 'goji' || $FORKNAME = 'achi' ]]; then
  BADFORKSUM=$(forksum $FORKNAME);
  SIZEOFPLOTS=$(grep "Total size of plots:"  <<< $BADFORKSUM | sed 's/Total size of plots://' | awk '{$1=$1};1' )
  if [[ $FORKNAME = 'avocado' ]]; then
    PLOTCOUNT=$(grep "Plot count for all harvesters:"  <<< $BADFORKSUM | sed 's/Plot count for all harvesters://' | awk '{$1=$1};1' )  
  else
    PLOTCOUNT=$(grep "Plot count:"  <<< $BADFORKSUM | sed 's/Plot count://' | awk '{$1=$1};1' )  
  fi
  PLOTSPACEBYTES=$(echo $SIZEOFPLOTS | awk '{ print $1 }' | awk '{$1=$1};1')
  PLOTSPACEUNIT=$(echo $SIZEOFPLOTS | awk '{ print $2 }' | awk '{$1=$1};1')

  # echo "Plot Space  " $PLOTSPACEBYTES " " $PLOTSPACEUNIT  
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
  HARVESTERLIST=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_harvesters | python -m json.tool )
  IFS=''
  PLOTSIZELIST=$(grep "file_size" <<< $HARVESTERLIST | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' ) 
  PLOTCOUNT=$(echo "$PLOTSIZELIST" | wc -l | awk '{$1=$1};1')
  PLOTSPACEBYTES=$(awk 'END { print s } { s += $1 }' OFMT='%.20g' <<< $PLOTSIZELIST )
fi

PROPORTION=$(echo "scale = 20; ($PLOTSPACEBYTES / $RPCSPACEBYTES)" | bc -l)
ETWMIN=$(echo "scale = 20; ($AVGBLOCKTIME / 60)" | bc -l )
ETWMIN=$(echo "scale = 20; ($ETWMIN / $PROPORTION)" | bc -l )
ETWSEC=$(echo "($ETWMIN * 60)" | bc)
ETWTEXT=$( assemble_timestring ${ETWSEC/.*} 's' 2 4 2 )


# Get last block win date and epoch
LASTBLOCKDATE=$(grep 'true' <<< $MERGEDCOINLIST | tail -1 | awk '{print $1}' )
LASTBLOCKEPOCH=$(grep 'true' <<< $MERGEDCOINLIST | tail -1 | awk '{print $1}' | date -f - +%s)
CURRENTDATEEPOCH=$(date +%s)
SECONDSSINCEHIT=$(echo "($CURRENTDATEEPOCH - $LASTBLOCKEPOCH)")
MINUTESSINCEHIT=$(echo "($SECONDSSINCEHIT / 60)" | bc )

# Create "ago" string for how long ago last block was farmed.  See forktoolsinit.sh for function definition.
LASTBLOCKAGOTEXT=$( assemble_timestring ${SECONDSSINCEHIT/.*} 's' 2 4 2 )

# Calculate effort
EFFORT=$(echo "($SECONDSSINCEHIT / $ETWSEC * 100)" | bc -l)
IFS=$OLDIFS


