# Qwinn's forktools

Eighteen 100% local, 100% bash scripts to make fork maintenance and monitoring infinitely easier.  Very useful even if you're only farming Chia.  Includes a 100% local blockchain explorer that can provide full history of any wallet address, deeply detailed monitoring stats, service starting and stopping, code patching, automated config.yaml editing (including mass adding and/or deleting of plot directory lists), fully scripted updating of any fork to the latest released version, all forktool output can now be logged to files, and most commands can now be run for a single fork or all of them at once.  Requires extremely little configuration (really only have to supply your plot directories for 'forkaddplotdirs' to work, and which services for which forks 'forkstart all' should start), but there are lots of optional configuration options available to fine tune other forktools to your taste.

Fully tested and compatible under Ubuntu 20.04, MacOS X, and WSL2 installations under Windows.

# The Short List Of Commands And What They Do

- `fork`                \- Allows you to run any command for any fork from any directory, with some abbreviations for frequently used commands
- `forklist`            \- Displays count and quick list of all running farmers and harvesters
- `forkmon`             \- Displays detailed statistics for all running farmers and harvesters
- `forkstart`           \- Start or restart fork services.  Can start all of your fork services sequentially after some configuration.
- `forkstop`            \- Stop all fork services for one fork or all forks running a daemon process.
- `forkexplore`         \- Provides transaction history for your target wallet address by default, but can explore any specified address
- `forkaddplotdirs`     \- Uses a list you provide to add multiple plot directories to a fork, or all installed forks.
- `forkremoveplotdirs`  \- Uses a list you provide to remove multiple plot directories from a fork, or all installed forks.
- `forkupdate`          \- Updates your fork to a new version. Only parameters it needs are the forkname and optionally the branch/version you want.
- `forkpatch`           \- Applies useful code patches to every fork.  For now, only adds grayfallstown's multiprocessing_limit patch
- `forklog`             \- Powerful and versatile debug.log parser
- `forkfixconfig`       \- Allows you to quickly set your preferred settings in one or all fork's config.yamls.
- `forkedit`            \- Simply opens up a fork's config.yaml in your preferred text editor (gedit by default)
- `forkcheck`           \- Displays all configured ports for all forks in a chart, and identifies any non-standard ports configured for each fork.
- `forkports`           \- Checks to make sure the ports used by each fork are actually only being used by that fork
- `forktargets`         \- Displays a list of the target receive addresses for every fork running a farmer
- `forknodes`           \- Prints a list of the peers you're connected to, in 'show -a' format for sharing with friends who can't connect
- `forkbenchips`        \- Benchmarks your server's capacity for running a timelord


# Changelog, Version 4.0:

- New tool `forkremoveplotdirs`.  Identical to forkaddplotdirs except that it removes plot directories instead of adding them.  Has its own config file that needs to be edited in order to use.
- New tool `forkcheck`.  Whereas forkports monitors actual port usage, forkcheck lists all the ports as set in your config.yaml's in a nicely formatted chart (very similar in layout to the Chia Forks Trader "Unofficial List of Chia Forks" ports tab) and, as a bonus, compares them to the ports in the fork's `initial-config.yaml` and identifies all non-standard ports in your operating configs.
- New tool `forkpatch`.  Applies popular code patches to all forks, with plenty of validation to ensure the patch can be applied safely.  For now, only supports grayfallstown's excellent multiprocessing_limit patch that can drastically reduce CPU and memory usage.  Works on every known fork.  And there will be more global code patches to come!
- Extensive improvements to `forkports`.  Now runs for every installed fork it can find, rather than only forks running a harvester process.  Now ignores conflicts with timelord port and timelord launcher port (because the vast majority of people don't run them) and introducer port and remote peer port usage (because neither conflicts with local ports).  Forks with very long names (looking at you, LLC) will no longer show as conflicting with itself.  And forkports now runs much much much much much faster.
- `forktargets` now also runs much much faster
- `forkaddplotdirs` and the new `forkremoveplotdirs` now support fork-specific config files.  For example, if you have a different set of plot directories for chives, simply create `ftconfigs/config.forkaddplotdirs.chives`, and set the fork-specific plot directories in it.  These fork-specific configs will be respected even when running with 'all' parameter and when run from within `forkupdate`.
- `forkfixconfig` also supports fork specific configs now, but behaves slightly differently.  You name them the same way (`config.forkfixconfig.forkname`) and you COULD make it a duplicate of the entire main `config.forkfixconfig` file and it would all work (any setting in `config.forkfixconfig` can be overridden by the value set in `config.forkfixconfig.forkname`), but you probably shouldn't, because the settings in the main file, `config.forkfixconfig`, are still operative and applied *unless* overwritten by the settings in the fork specific config.  So for example if you want to just override the Maize full node RPC port to resolve the conflict with Tranzact's full node port, create `config.forkfixconfig.maize` and have only one line in it, `SETFULLNODERPCPORT= 8667`.  Then even when you update the fork with forkupdate, that port setting will always be re-applied, and all the other global settings from the main `config.forkfixconfig` will also still be applied.  This way you still only have to maintain the global settings that you don't ever override in one place, `config.forkfixconfig`.
- The install scripts have been improved so that, when new parameters are added to a forktool's config template file, the new parameters will be automatically added to your own custom config files and all of your personal preferred settings will be preserved.
- A bug that could very very rarely cause some forktools to just display the -help information and nothing else has been fixed.
- All hardcoded references to specific forks in forktools code have been removed. The code that deals with forks that use "chia" process names and otherwise do things in a non-standard fashion is entirely dynamic now, and if a fork changes the way it handles those things from one version to another, forktools will support both versions.
- `forkfixconfig` can now be used to edit `parallel_read` in the harvester section, which is mainly only useful to Mac OS X users using exfat-formatted drives.
- `forkmon` now has a "Srvcs DNFHW" column in both sections. This identifies which services are running.  The DNFHW refers to Daemon Node Farmer Harvester Wallet, and it will show Y  under that service's letter if it's running, and N if it isn't.
- Many irrelevant bash error messages, particularly in `forkmon` and `forkexplore`, that were generated during normal, expected operation will no longer be logged or visible to users.
- If a newly installed fork is still below height 500, accurate ETW calculations aren't possible. `forkmon` will now show "Ht<500" under ETW and "N/A" under Effort in this circumstance.
- If a newly installed fork has never had a successful harvest, `forkmon` will now show 'Never' under LastHarvest rather than the number of seconds since 1970.
- Symlink creation for venidium removed now that it has moved to mainnet.

# INSTALLATION INSTRUCTIONS:

For new installations:

```
git clone https://github.com/Qwinn1/forktools
cd forktools
bash installft.sh
source ~/.bashrc
```

For existing users:
```
# back up your forktools/config.* files
# cd to parent directory of your current forktools directory
sudo rm -r forktools
git clone https://github.com/Qwinn1/forktools
# copy your configs to the forktools/ftconfigs folder
cd forktools
bash installft.sh
```

FOREVER AFTER, you can update forktools at any time by simply running the following:

```
cd forktools
bash installft.sh   # or 'bash installfttest.sh' for testing branch
```


# FORKTOOLS MAJOR FEATURES:

- forkexplore ( 100% local address explorer ) :

```qwinn@Huginn:~/.silicoin/mainnet/log$ forkexplore hddcoin -s 2021-08-28 -u 2021-08-30

                         EXPLORING Address:
   hdd1w5hw0qsv0se7fasdfasd9un8325g0kyl6fdafaaw0953ha5phxh2313ss8fvkg2

                    Balance:           343 HDD
                    Today:               8 HDD
                    Yesterday:           2 HDD
---------------------------------------------------------------------
                       Height      Height     Farmed         Total
DateTime               Confirmed   Spent      Block?        Amount
---------------------------------------------------------------------
2021-08-28T03:56:32    252432      0          Yes         2.00 HDD  
2021-08-28T07:41:38    253161      0          Yes         2.00 HDD  
2021-08-28T08:32:03    253336      0          Yes         2.00 HDD  
2021-08-28T11:39:57    253959      0          Yes         2.00 HDD  
2021-08-28T12:02:45    254036      0          Yes         2.00 HDD  
2021-08-28T19:57:23    255552      0          No         13.00 HDD  
2021-08-28T22:39:44    256057      0          Yes         2.00 HDD  
2021-08-28T23:18:25    256170      0          Yes         2.00 HDD  
2021-08-29T01:48:40    256658      0          Yes         2.00 HDD  
2021-08-29T13:44:29    258960      0          Yes         2.00 HDD  
2021-08-29T16:21:35    259447      0          Yes         2.00 HDD  
2021-08-29T17:28:27    259644      0          Yes         2.00 HDD  
2021-08-30T08:00:15    262475      0          Yes         2.00 HDD  
2021-08-30T18:47:29    264529      0          Yes         2.00 HDD  
2021-08-30T22:32:24    265164      0          Yes         2.00 HDD  
---------------------------------------------------------------------
    15 transactions from 2021-08-28 to 2021-08-30:       41.00 HDD  
```

- forkmon ( Detailed overview of all running farmers and harvesters ) :

```
------------------------------------------------------------------- FARMERS: 15 -----------------------------------------------------------------

                                                                              FulNode   Memory   NoHarv       Address              Last
Farmer            Version         Status   #Peers   #Plots  Height  Netspace  Workers    Usage   Errors       Balance   ETW        Block   Effort
-------------------------------------------------------------------------------------------------------------------------------------------------
apple             1.2.30          Farming      26     4970  343297   372 PiB     20    2307 MB       0          0 APPLE 3h44m       4m ago     2%
avocado           1.1.7.dev124    Farming      10     4970  400048   384 PiB     20    2278 MB       0          0 AVO   4h2m        6m ago     2%
beet              2.1.3b0         Farming      26     4970  191771    57 PiB     20    1668 MB       0          0 XBT   34m      1h49m ago   313%
btcgreen          2.1.0           Farming      47     4969  244892   227 PiB     20    2318 MB       2          0 XBTC  2h37m    9h28m ago   361%
cannabis          1.2.301         Farming      12     4970  353211   243 PiB     20    1991 MB       0          0 CANS  2h33m     6h1m ago   235%
covid             1.2.3           Farming      22     4971  307010   245 PiB     20    2111 MB       0          0 COV   2h33m      37m ago    24%
flax              0.1.2           Farming      42     4970  525263   2.5 EiB     20    2838 MB       0          0 XFX   1d7h      2d2h ago   159%
flora             0.2.5           Farming      12     4970  425441   738 PiB     20    2657 MB       0          0 XFL   7h56m   14h11m ago   178%

...

-------------------------------------------------- HARVESTERS: 32 ------------------------------------------------------
                                                         Average    Average    Longest    Longest   5 Sec  5 Sec  Proofs
                                                 Last   Response   Response   Response   Response   Warns  Warns   Since
Harvester         Version      # Plots        Harvest      Today  Yesterday      Today  Yesterday   Today  Y/Day   Y/Day
------------------------------------------------------------------------------------------------------------------------
apple             1.2.30          1636         0s ago      0.85s      0.71s     64.49s     58.33s     131    156       2      
avocado           1.1.7.dev124    1636         1s ago      0.85s      0.70s     88.74s     67.60s     144    147       3      
beet              2.1.3b0         1636         0s ago      0.84s      0.72s     92.75s     75.68s     137    166      19      
btcgreen          2.1.0           1636         0s ago      0.84s      0.75s     58.53s    143.27s     154    161       3      
cactus            1.2.2.dev7      1636         7s ago      0.83s      0.70s     66.14s     62.16s     131    147       8      
cannabis          1.2.301         1636         3s ago      0.82s      0.71s     58.44s     66.78s     116    150       7      
chia              1.2.7           1636         4s ago      0.83s      0.62s     88.28s     73.64s     129    132       0      
covid             1.2.3           1636         2s ago      0.88s      0.72s     72.08s     53.36s     137    165       9      
cryptodoge        1.2.6           1636         1s ago      0.87s      0.71s     67.90s     89.14s     143    169       3      
dogechia          1.0.9           1636         2s ago      0.87s      0.69s     83.03s     94.74s     132    150       3   
```

- forkfixconfig ( Automated editing of fork config.yamls to preferred settings as set up in config.forkfixconfig )

```
(venv) qwinn@Gungnir:~/silicoin-blockchain$ forkfixconfig silicoin 10.0.0.104
Proposed changes to /home/qwinn/.silicoin/mainnet/config/config.yaml :
  Old Log Level:  log_level: "WARNING" # Can be CRITICAL, ERROR, WARNING, INFO, DEBUG, NOTSET
  New Log Level:  log_level: "INFO" # Can be CRITICAL, ERROR, WARNING, INFO, DEBUG, NOTSET
  Old Plot Load Frequency:  interval_seconds: 120 # The interval in seconds to refresh the plot file manager
  New Plot Load Frequency:  interval_seconds: 18000 # The interval in seconds to refresh the plot file manager
  Old Batch Size:  batch_size: 30 # How many plot files the harvester processes before it waits batch_sleep_milliseconds
  New Batch Size:  batch_size: 1500 # How many plot files the harvester processes before it waits batch_sleep_milliseconds
  Old Batch Sleep:  batch_sleep_milliseconds: 10 # Milliseconds the harvester sleeps between batch processing
  New Batch Sleep:  batch_sleep_milliseconds: 1 # Milliseconds the harvester sleeps between batch processing
  Old Target Peer Count:  target_peer_count: 70
  New Target Peer Count:  target_peer_count: 80
  Old Harvester Farmer_Peer IP:  host: *self_hostname
  New Harvester Farmer_Peer IP:  host: 10.0.0.104
  Appending:  multiprocessing_limit: 4
Should you proceed, a backup of your current config.yaml will be made called config.yaml.2021-09-03
Are you sure you wish to make these changes? (Y/y)y
```

- forktargets : ( Lists target addresses as set up in config.yamls and verifies the current running farmer process is using that address. )

```
qwinn@Huginn:~/forktools$ forktargets
          cactus - config.yaml and Farmer RPC agree.  Address: cac1blahblah
      cryptodoge - config.yaml and Farmer RPC agree.  Address: xcd1blahblah
        dogechia - config.yaml and Farmer RPC agree.  Address: xdg11blahblah
         hddcoin - config.yaml and Farmer RPC agree.  Address: hdd11blahblah
            kale - config.yaml and Farmer RPC agree.  Address: xka11blahblah
          melati - config.yaml and Farmer RPC agree.  Address: xmx11blahblah
           olive - config.yaml and Farmer RPC agree.  Address: xol11blahblah
        pipscoin - config.yaml and Farmer RPC agree.  Address: pips11blahblah
            seno - config.yaml and Farmer RPC agree.  Address: xse11blahblah
        silicoin - WARNING!  config.yaml and RPC target addresses DO NOT MATCH!   WARNING!
                   When this happens, rewards actually go to the target address reported by the farmer RPC call.
                   If you recently edited the config.yaml but didn't restart your farmer, you should restart it or revert your config changes.
                   config.yaml:      tsit11blahblah
                   Farmer RPC call:  tsit11differentblahblah
           socks - config.yaml and Farmer RPC agree.  Address: sock1blahblah
            taco - config.yaml and Farmer RPC agree.  Address: xtx1blahblah
             tad - config.yaml and Farmer RPC agree.  Address: tad1blahblah
qwinn@Huginn:~/forktools$ 
```

- forklog :  ( Extremely versatile debug.log parser with multiple runtime switches including date range available. ) 

```qwinn@Muninn:~/forktools$ forklog -help
forklog help:

SYNOPSIS:  Extremely versatile and powerful log parsing tool.  See parameters below.
           The 'forklog running:' first line of output is the bash command generated
    after interpretation of the switches that actually produces the resulting output,
    albeit prior to some path variable substitution.
           As many search terms as desired can be added by the various switches.
    A line will show if any one of the search terms are found in that line.
           The file ftconfigs/config.forklog allows for setting some default filters
    such as a specific date range or only the previous X days worth of log entries.
           Note that the config setting FORKLOGTAIL effectively sets the maximum number
    of lines this tool can output.  This number can be overridden with -t switch.
           Running 'forklog forkname' with no switches produces the last FORKLOGTAIL
    lines of the log with no filters or search terms.

PARAMETERS/SWITCHES:
    forkname                                Required.  All others optional.
    -e | --error                            Adds 'ERROR' as a search term.
    -w | --warning                          Adds 'WARNING' as a search term.
    -h | --harv                             Adds 'harvester' as a search term.
    -p | --proof                            Adds any positive # of found proofs as a search term.
    -g 'word' | --grep 'word'               Adds 'word' as a search term.  Multiple uses allowed.
    -l 10 | --lastxdays 10                  Shows only results for the last 10 days.
    -s YYYY-MM-DD | --startdate YYYY-MM-DD  Do not show results prior to this date.  If both this
                                               and -l / --lastxdays are set, this is used.
    -u | --enddate YYYY-MM-DD               Do not show results after this date.
    -t 100 | --tail 100                     Tails the last 100 lines of the result. forklog always
                                               tails FORKLOGTAIL lines as set in ftconfigs/
                                               config.forklog. Use -t to override that default.
    -help | --help                   Show this information again.

```


# SETTING UP ENVIRONMENT PATHS

This section is now obsolete as `bash installft.sh` will set up your paths in .bashrc (or .bash_profile, if you're on MacOS X) for you.

# FORK NAMING CONVENTION ISSUES

This section is now obsolete as `bash installft.sh` will set up any known needed symlinks for you.


# COMMANDS WITH NO PARAMETERS:

- `forkmon`                \-  In my opinion the current heart of forktools.  This script gives you detailed information on every active fork process on your server, one section for farmers and another for harvesters.  Includes average and longest response times, fullnode worker count, memory usage, wallet balances for your target addresses, how long ago the last block was won, number of 5 second warnings in the logs, ETW (far more accurately than what chia or any other fork provides), effort percent, and much more!  Forkmon can take a single fork as a parameter, a -n / --nobalance switch can be specified to show all wallet balances as 0, useful if you want privacy when posting forkmon results online, and either -f  --farmeronly or -h | --harvesteronly to show only one of the two sections.
- `forkports`              \-  Checks potential port locking contention on all installed forks, whether running or not.  Runs `ss` scanning for ports used by each fork (as set in each fork's config.yaml) and lists any process which references those ports and does not contain that fork's binary name as the owner of the process.  Ignores timelord port, timelord launcher port, introducer port and remote peer port usage, as conflicts with these do not create any problems for the vast majority of users.
- `forkcheck`              \-  Whereas `forkports` monitors actual port usage, forkcheck lists all the ports as set in your config.yaml's in a nicely formatted chart (very similar in layout to the Chia Forks Trader "Unofficial List of Chia Forks" ports tab) and, as a bonus, compares them to the ports in the fork's initial-config.yaml and identifies all non-standard ports that you have set up in your operating configs.
- `forktargets`            \-  lists the target wallet addresses as configured in every active fork farmer's config.yaml in a convenient and organized list for easy visual comparison to whatever list of wallet addresses you intend rewards to go to that you're currently maintaining.  Also compares the target setting in config.yaml to the RPC call for the same value, and gives a big warning if they don't match.
- `forklist`               \-  Gives both farmer and harvester counts including a single line list of which forks are running for each.

# COMMANDS WITH ONE PARAMETER: FORKNAME

- `forkfixconfig chia`     \-  Provides automated editing of several entries in chia's config.yaml that require frequent editing - log level, plot loading frequency, farmer peer for harvesters, and several more.  Requires confirmation and creates backups.  Does not actually require editing of default options in config.forkfixconfig - the defaults I picked should work fine - but if you'd like to tweak them, you can do so there.  Please report if the defaults as I chose them cause you any issues so I can review.  As of v2.3, can now also accept "all", "farmers" or "harvesters" instead of forkname.
- `forkedit hddcoin`       \-  Opens the .hddcoin/mainnet/config/config.yaml file in gedit. You can now set your preferred text editor in config.forkedit.
- `forknodes avocado`      \-  prints a list of currently connected nodes for sharing with others having difficulty connecting. Prepends each node and port with "avocado show -a " for easy CLI connection command via cut and paste.
- `forkbenchips taco`      \-  runs benchmark of your system's capacity to run a timelord for tad, in ips.  Requires having previously run sh install-timelord.sh in the tad-blockchain directory
- `forkaddplotdirs taco`   \-  Requires configuration in config.forkaddplotdirs to use.  List your plot directories there, then you can add them to any fork quickly with a single command.  Gives warnings if a drive listed in the config is not mounted.  Can be run with "all" as the parameter instead of forkname to add directories to every installed fork. 
- `forkremoveplotdirs tad` \-  Requires configuration in config.forkremoveplotdirs to use.  Allows for systemic removal of plot directories from one or all installed forks.
- `forkupdate`             \-  Updates a fork to the most recent version with a single command.  Removes the existing blockchain directory and recreates it with git clone as a fresh installation.  Can optionally take a -b "tag" switch (to be applied to the git clone commmand).  Note that forkupdate will backup and then remove the existing config.yaml so that 'fork init' during the update process will recreate a fresh config.yaml that includes any new parameters added by the development team.  Target addresses, farmer peer and multiprocessing_limit will be transferred to the new config.yaml, and other settings will be configured via forkfixconfig (so your settings in config.forkfixconfig will be applied).

# COMMANDS WITH MULTIPLE PARAMETERS/SWITCHES

- `fork`                   \-  Allows you to issue commands from any directory as if you were cd'd into the fork's -blockchain directory and activated. It allows for 3 3-letter abbreviations for the 2nd parameter - 'sum' for 'farm summary', 'wal' for 'wallet show' and 'ver' for 'version'.  This effectively replaces forksum, forkver and forkwalletshow from previous versions of forktools.
- `forkstart`              \-  Use this to start up one, or all, of your farmers, harvesters, and timelords.  By editing config.forkstartall, you can run `forkstart all` to start every farmer and harvester you like sequentially (great for use following a reboot).  This single command has now replaced all previous forkstart* tools.  Instead of `forkstartall`, run `forkstart all`.  Instead of `forkstartf chia`, run `forkstart chia -f`.  Other switches are -fnw for farmer-no-wallet, -h for harvester and -t for timelord.  Run `forkstart -help` for usage details.
- `forkstop`               \-  Use this to stop all services for one or all forks (great for prepping for a shutdown).  This single command has now replaced all previous forkstop* tools.  Instead of `forkstopall`, run `forkstop all`.  Instead of `forkstopa flax`, run `forkstop flax`.  Instead of `forkstoptl hddcoin`, run `forkstop hddcoin -t` to stop timelord.  Run `forkstop -help` for usage details.  (Note - there is no longer an equivalent way to reproduce the old `forkstoph`, as I decided there is no good reason to stop just the harvester service without also shutting down the daemon and all other services.)
- `forklog`                \-  This single function has now replaced all previous log parsing forktools. Running it without switches
will just get you a tail of the log.  You can manipulate log output now any way I could think of if you get creative with the switches, but you're still able to duplicate the quick and simple older versions with a single switch for each.  Just run forklog -help to get a full list of options. The first line of forklog output will be the actual bash command that is constructed after all the switches and parameters are interpreted that produces the output that follows.
- `forkexplore`            \-  100% local address explorer.  Provides address balances for your target receive address for the selected fork, but has an additional -a switch which allows you to explore any receive address you wish, hot or cold, and all the same date range options that forklog has.  Does not require sync, just a running farmer and full node.  Run forkexplore -help for detailed usage instructions.
- `forkpatch`              \-  Can be run for one fork or 'all' forks.  Used to apply useful code patches to every fork.  For now, can only add grayfallstown's multiprocessing_limit patch.  This phenomenal patch has been known to reduce RAM usage for 50 forks running on a xeon server from 150GB down to 50GB.  That is an extreme case, but everyone should see a significant reduction in RAM from applying this patch to every fork.  My RAM usage dropped about 30-50% with it, as it lowered my Full Node Worker count for every fork from 20 (the default depends on the number of your CPU cores) to 6.  And 6 is still a conservative setting, more than enough to maintain sync once achieved.


# DISCORD SERVER

Got a fun crowd here already.  Come join us!  And if you have any issues, I'll be happy to help.

https://discord.gg/XmTEZ4SHtj


## OLDER CHANGELOGS

# Changelog, Version 3.11:

- Extensive improvements to forkupdate.  The version grab works identically to git clone now, a ton more validation, and if either the git clone command fails or the user does not actively confirm that the update went well at the end of the process, the original -blockchain directory and config.yaml are restored. 
- No more hardcoded forks in the forkmon/forkexplore logic to grab the major-minor multiplier in the code. So if a fork wants to name their code directory 'chia' instead of their own forkname, this will be automatically detected now, and different versions of the same fork that handle it different ways can now both work simultaneously.

# Changelog, Version 3.1:

- `forkstart all` can now take a `-s #` switch, where # is the number of seconds to sleep in between starting each fork.  Good for if it's been a while since you ran your forks and they'll need to resync, or for weaker CPUs that have trouble starting that many processes consecutively without a pause.
- `forkmon` and `forkexplore` can now take a `-p` switch, which makes them report on hot wallet address instead of target address.  Intended for folks who use cold wallets and NFT plots to quickly see if any pool rewards have gone to their hot wallets so they can transfer them to their cold wallets.
- Flora has renamed their code directory and major-to-minor multiplier code to 'chia'.  Added special handling to make forktools compatible to Flora 1.2.9+.
- `forkupdate`:  if -b main or -b latest was explicitly specified, forkupdate would fail if those branches didn't exist.  They are now validated prior to attempting to run forkupdate.
- Install script for main will now make install script for testing executable, and vice versa.

# Changelog, Version 3.01:

- Lucky has properly renamed their processes in their latest version.  This update just removes the special handling that was previously required.  Update to latest version of lucky for it to be compatible with latest forktools versions.

# Changelog, Version 3.0:

- full Mac OS X compatibility has been achieved.  Thanks, SolarHash, for all the help with this!
- all tools now have far more detailed online -help
- all tools now print the datetime it was initiated as the first line of output.
- all configuration files are now moved to and searched for in new forktools/ftconfigs directory.
- all tools can now have their output logged to files created in the new forktools/ftlogs directory.  Only forkmon output is logged by default.  Edit ftconfigs/config.logging to enable logging for any other forktool.
- there are now two install scripts.  `bash installft.sh` will update you to the latest code in the main branch. `bash installfttest.sh` will update you to the latest code in the testing branch.
- forkconfig has been renamed to forkedit, to prevent confusion with forkfixconfig
- forkexplore can now handle 0 or just 1 transaction found without errors
- forkmon now handles Last Block and Effort% calculations much better when a block hasn't been won yet.  Effort% will in that case be calculated from the date of the first successful harvest in the earliest log (so, assuming you haven't deleted logs, from when you started farming the fork).
- forkmon has been optimized for faster performance
- forkmon can now accept -f | --farmeronly or -h | --harvesteronly switches to skip the other section of forkmon's output.
- forkaddplotdirs can now accept "all" instead of forkname as a parameter, which will add the drives specified in ftconfigs/config.forkaddplotdirs to every fork with an active harvester.  Great for adding a brand new drive to all forks.
- forkfixconfig can now accept "all" instead of forkname as a parameter, which will apply the settings specified in ftconfigs/config.forkfixconfig to every fork with an active harvester.  Can also use "farmers" instead of forkname to only configure forks running a farmer, or "harvesters" instead to configure only forks running an active harvester but not an active farmer.
- new tool forklist replaces the old forkcounth.  Instead of just giving a count of running harvesters and nothing else, forklist gives both farmer and harvester counts including a single line list of which forks are running for each.  I am finding this tool extremely handy and using it constantly.
- new tool forkstop accepts switches, enabling it to replace forkstopa, forkstoph, forkstoptl and forkstopall. Run forkstop -help for details.
- new tool forkstart accepts switches, enabling it to replace forkstartf, forkstartfnw, forkstarth, forkstartall and forkstarttl.  Run forkstart -help for details.
- new tool fork allows you to issue any command from any directory as if you were cd'd into the fork's -blockchain directory and activated. It allows for 3 3-letter abbreviations that effectively replace forkver, forksum, and forkwalletshow.  Instead of those tools, you can now run 'fork chia ver', 'fork flax sum', and 'fork hddcoin wal', for example.  And you can submit any other command you wish that can be run from the activated -blockchain directory, such as 'fork hddcoin show -a 132.123.213.321:4131'
- new tool forkupdate updates a fork to the most recent tagged release from the fork's online repository (from the "latest" branch if the fork maintains one, from "main" if not) with a single command.  Removes the existing blockchain directory and recreates it with git clone as a fresh installtion.  Can optionally take a -b "tag" switch (to be applied to the git clone commmand).  Note that forkupdate will backup and then remove the existing config.yaml so that 'fork init' during the update process will recreate a fresh config.yaml that includes any new parameters added by the development team.  Target addresses and farmer peer will be transferred to the new config.yaml, and other settings will be configured via forkfixconfig (so your settings in config.forkfixconfig will be applied).
- changes to some scripts to allow compatibility with shells that run fork processes (and thus change the format of process lists), like SCREEN

# Changelog, Version 2.2:

1. All configuration options have been moved out of forktoolsinit.sh and into sub-includes named config.forkstartall, config.forkaddplotdirs, etc.   For your own convenience, please preserve your settings when updating for transfer to the new config file structure.
2. New `bash installft.sh` installation script.  Updates code to latest version, tests for curl installation, sets up environment variables, creates all known needed symlinks, sets up new config.forktool files from .template versions if not already configured (see previous changelog entry) and makes forktools executable.
3. Compatibility added for forks that do not rename their processes, folders or code directories from "chia".  Prime examples are lucky (edit: lucky processes have since been fixed), xcha, nchain, rose and fishery.  Please note that adding this compatibility is NOT an endorsement on my part recommending farming of any forks with such terrible lazy coding practices.  Quite the opposite.  KNOWN ISSUE:  Everything works except memory usage, which cannot be fixed at this time due to process names being indistinguishable from chia and each other. 
4. Forkmon fixes and enhancements:
   - Issue with a minority of forks showing "1 plot" should be fixed.
   - Can now accept optional first parameter FORKNAME to only show output for the specified fork
   - Can now accept optional parameter -n (or --nobalance) to show all wallet balances as 0 (for privacy if posting results publicly)
   - Forkmon will no longer be fooled by forks that duplicate chia process names into thinking chia is running when it isn't
   - Added "Height" as a column
   - When forkmon is initiated, a "Forkmon initiated at datetime" stamp will be sent to the forkerrors.txt error dump file.
   - Fixed incorrect chia netspace display.  Also added a decimal point of precision when netspace shown in EiB
   - Forkmon should be able to handle debug.log files with NULLs in them now (which can happen if harvesters are running when server crashes)
5. Forklog fixes and enhancements
   - The first line of output from forklog will now always be the actual bash command that was assembled from all the parameters and switches to generate the output that follows.
   - The previous "FORKLOGTAIL" setting (which is now set in config.forklog) is now always active. Puts a hard limit on how many lines of output you can get. Can be overridden with -t parameter.
   - Can now run forklog with *just* a -t parameter, to just tail the last bunch of lines.
6. forkaddplotdirs will now show warnings if a drive specified in config.forkaddplotdirs is not mounted.
7. forkshowwallet renamed to forkwalletshow to be consistent with the format of the manual command.
8. forkedit default text editor can now be changed via editing config.forkedit (defaults to gedit as before) (this entry revised as of version 3.0 due to renaming of forkconfig to forkedit)
9. A great deal of work has been made to make forktools MacOS X compatible, though some work still needs to be done.  The simpler tools should work fine on MaxOS X, but forklog, forkmon and forkexplore probably won't until at least next version.



# DONATIONS ACCEPTED

Thank you for your support.  And if you can't donate, but you are getting good use of these tools, I'd appreciate at least a star on the github page.  Thank you!

```
Chia:        xch1gsqc9t20fs22eltff3c9eghnw80sq609zsgcj8sz5378jupzd5xqqrv0sl
BTCGreen:    xbtc15d4yfuyx4zx9yl7r3y8mmw4ey6q8p4khvh27jw692rav84x8002qng2s69
Cactus:      cac1x73mqd9g4md2vgcjc0yemvz5j2xlzuk4d78kkdgse59f5mgxvj4qudr3yz
Covid:       cov19h8apm8cnggn2mag8qr8enxmyutngxh5te3fj3fmmy98ywkaa49qzpymq3
Dogechia:    xdg1tmk09uhu74na3pk0zsh9h30a8k3wy9u4a4gpexjskknfqqwlh42qe2spxt
Flax:        xfx179de2g9d33rd2h8yanhx82h2yx7hvqt4c8j6kjylw2q2zdl2fvgqmze5pe
Flora:       xfl1wwtptljkz288swswmazjc74ck6thfg6hy7hd0dr5suggvdjlzscs3x08qw
GreenDoge:   gdog10jx7mdylp935k2vrhkfpt6qcq3ttwzedl0nl62vtvkkgd8mkj2pse7afdn
HDDcoin:     hdd1w5hw0qsv0se7kysdl9un8325g0kyl668w0953ha5phxh47jtu3ss8fvkg2
Olive:       xol1xff06jnuger5s6ewa47xqrmxm6z09rn8m2wg9qsdyf4cfd8uwrdsnhwkkt
Scam:        scm1flju3xzwt2vpqjn5sttwwgxe7xcy825lagca0xc2ycum5eghvcaqayqk9d
Silicoin:    tsit1s8akjytuygq5kfwk85ag6jqvc93k6vw5hz2vwx3ekjsjy55h2lkq93xphd
Socks:       sock1lwvch9vss70k2s3x0mdqkxdrpr56z2dyc69cpw32apuhexr6rnxq8ullpj
Taco:        xtx18d6spw69ghwhdc928ysex3el0ny83l0rzvj2es0m8ram5jaqckjqgcpzad
Tad:         tad15ygc3yqnp5gvdq30svx4thtkdxz9qzfwmev2nvw4s36nkrzgce3scqj2l7
```

