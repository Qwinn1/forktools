
# All RPC calls and most data assembly for forkmon and forkexplorer occurs in this include.

# Parse config for all ports
CURRENTCONFIG=$FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/config.yaml

. $FORKTOOLSDIR/ftparseports.sh
. $FORKTOOLSDIR/ftcheckprocs.sh

if [[ $FARMERRUNNING != 1 ]]; then
  echo "Farmer for $FORKNAME is not running, skipping."
  continue
fi

if [[ $FULLNODERUNNING != 1 ]]; then
  echo "Full Node for $FORKNAME is not running, skipping."
  continue
fi

cd $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain
. ./activate

OLDIFS=$IFS
PEERCOUNT=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_connections | python -m json.tool)
IFS=''
PEERCOUNT=$(echo $PEERCOUNT | grep -c '"type": 1' )
IFS=$OLDIFS

# Get coin name
COINNAME=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_network_info | python -m json.tool)
COINNAME=$(echo $COINNAME | sed 's/.*"network_prefix": "//' | sed 's/",.*//' | tr [a-z] [A-Z] | awk '{$1=$1};1')


# Get major-minor multiplier
MMMULTIPLIERNAME=$FORKNAME
# Hard coding to account for crappy lack of proper fork renaming. 
if [[ $MMMULTIPLIERNAME == 'rolls' ]]; then
   MMMULTIPLIERNAME='roll'
fi
MMMULTIPLIER=$( cat $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain/$FORKNAME/consensus/block_rewards.py | grep "^_.*_per_$MMMULTIPLIERNAME =" | sed 's/.*=//' | sed 's/_//g' | sed 's/\*.*//' | awk '{$1=$1};1')
if [[ $MMMULTIPLIER == '' ]]; then
   MMMULTIPLIER=$( cat $FORKTOOLSBLOCKCHAINDIRS/$FORKNAME-blockchain/$FORKNAME/consensus/block_rewards.py | grep "^_.*_per_chia =" | sed 's/.*=//' | sed 's/_//g' | sed 's/\*.*//' | awk '{$1=$1};1')
fi
MMMULTIPLIER=$(echo "(( $MMMULTIPLIER ))" | bc )

ADDRESS=''
# Get wallet target address (can be different from what is set in config.yaml, if config was directly edited after last time farmer was started)
if [[ $NFTSWITCH == 'on' ]]; then
   if [[ -f $FORKTOOLSDIR/ftconfigs/config.nftaddress.$FORKNAME ]]; then
      . $FORKTOOLSDIR/ftconfigs/config.nftaddress.$FORKNAME
      ADDRESS=$( echo $USEOTHERADDRESS )
   fi
elif [[ $HOTSWITCH == 'on' ]]; then
   ADDRESS=$($FORKNAME keys show | grep "First wallet address: " | head -1 | sed 's/First wallet address: //' )
else
   ADDRESS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{"search_for_private_key":false}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_reward_targets | python -m json.tool )
   ADDRESS=$(echo $ADDRESS | sed 's/.*"farmer_target": "//' | sed 's/",.*//' | awk '{$1=$1};1')
fi

# Address override.  Pass to forkexplore as -a parameter.
if [[ $SPECIFIEDADDRESS != '' ]]; then
  ADDRESS=$SPECIFIEDADDRESS
fi

if [[ $ADDRESS != '' ]]; then
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

   MERGEDCOINLIST=$(paste <(printf %s "$TIMESTAMPEPOCHLIST") <(printf %s "$COINBASELIST") <(printf %s "$COINAMOUNTLIST") <(printf %s "$CONFIRMEDLIST") <(printf %s "$SPENTLIST") | sort)

   if [[ $HIDEBALANCE != 1 ]]; then
      # Sum address balance from unspent MERGEDCOINLIST
      ADDRESSBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $3 / mult )); }' OFMT='%20.20f' <<< "$MERGEDCOINLIST" )
      # A ton of extra formatting work for ridiculous forks with like 20000 block rewards (looking at you cryptodoge and chaingreen)
      if [[ "$ADDRESSBALANCE" > 9999 ]]; then
         ADDRESSBALANCE= $( (($ADDRESSBALANCE / 1000)) | bc )
         ADDRESSBALANCE="$ADDRESSBALANCE"K
      fi
   fi

   TODAYADDRESSCHANGE=$(grep $TODAYSTAMP <<< "$MERGEDCOINLIST")
   TODAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $3 / mult )); }' OFMT='%20.20f' <<< "$TODAYADDRESSCHANGE" )
   YESTERDAYADDRESSCHANGE=$(grep $YESTERDAYSTAMP <<< "$MERGEDCOINLIST")
   YESTERDAYADDRESSCHANGE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($5 == "0") s += (( $3 / mult )); }' OFMT='%20.20f' <<< "$YESTERDAYADDRESSCHANGE")
   IFS=DEFAULT_IFS

   # Sum farmed balance from coinbase = true
   IFS=$'\t' 
   FARMEDBALANCE=$(awk -v mult="$MMMULTIPLIER" 'END { print s } { if ($2 == "true") s += (( $3 / mult )); }' OFMT='%20.20f' <<< "$MERGEDCOINLIST" )
   IFS=''
fi

BLOCKCHAINSTATE=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_blockchain_state | python -m json.tool)

# FARMCONNECTIONS=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/full_node/private_full_node.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FULLNODERPCPORT/get_connections | python -m json.tool)

FARMSYNCMODE=$(grep '"sync_mode":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
FARMSYNCED=$(grep '"synced":'  <<< "$BLOCKCHAINSTATE" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' )
FARMSTATUS='RPC Failed'
if [[ $FARMERRUNNING != 1 ]]; then
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

if [[ "$CURHEIGHT" -gt 500 ]]; then
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
fi

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

PLOTLIST=$(curl -s --insecure --cert $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.crt --key $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/config/ssl/farmer/private_farmer.key -d '{}' -H "Content-Type: application/json" -X POST https://localhost:$FARMERRPCPORT/get_harvesters | python -m json.tool 2>/dev/null)

IFS=$'\n'
if [[ $PLOTLIST == '' ]]; then
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
  PLOTSIZELIST=$(grep "file_size" <<< "$PLOTLIST" | sed 's/.*://' | sed 's/,//' | awk '{$1=$1};1' ) 
  PLOTCOUNT=$(echo "$PLOTSIZELIST" | wc -l )
  PLOTSPACEBYTES=$(awk 'END { print s } { s += $1 }' OFMT='%.20g' <<< "$PLOTSIZELIST" )
fi
IFS=$OLDIFS

if [[ $RPCSPACEBYTES != '' && $PLOTSPACEBYTES != '' && $AVGBLOCKTIME != '' ]]; then
  PROPORTION=$(echo "scale = 20; ($PLOTSPACEBYTES / $RPCSPACEBYTES)" | bc -l)
  ETWMIN=$(echo "scale = 20; ($AVGBLOCKTIME / 60)" | bc -l )
  ETWMIN=$(echo "scale = 20; ($ETWMIN / $PROPORTION)" | bc -l )
  ETWSEC=$(echo "($ETWMIN * 60)" | bc)
  ETWTEXT=$( assemble_timestring ${ETWSEC/.*} 's' 2 4 2 )
fi

IFS=''
CURRENTDATEEPOCH=$(date +%s)
LASTBLOCKDATE=$(c1grep 'true' <<< "$MERGEDCOINLIST" | tail -1 | awk '{print $1}' )

if [[ $ADDRESS = '' ]]; then
  BLOCKWON='false'
  EFFORT=99999
elif [[ $LASTBLOCKDATE == '' ]]; then
  BLOCKWON='false'
  # Calculate effort from date of first harvest in logs if possible
  # For speed purposes, find the highest log available instead of grabbing them all
  if [ ! -f $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/log/debug.log.1 ]; then
     FIRSTLOG='debug.log'
  else
     FIRSTLOG=$( find $FORKTOOLSHIDDENDIRS/.$FORKNAME/mainnet/log/debug.log.* | sed 's/.*debug\.log\.//' | sort -n | tail -1 )
     FIRSTLOG=$( echo "debug.log.$FIRSTLOG" )
  fi   
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
  if [[ $ETWSEC != '' ]]; then 
     EFFORT=$(echo "($SECONDSSINCEHIT / $ETWSEC * 100)" | bc -l)
  fi
fi
IFS=$OLDIFS

