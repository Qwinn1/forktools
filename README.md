# Qwinn's forktools

# Changelog, Version 2.3 (testing):

- Mac OS X compatibility nearing completion
- forkexplore can now handle 0 or just 1 transaction found without errors
- new tool forkstop accepts switches, enabling it to replace forkstopa, forkstoph, forkstoptl and forkstopall. Run forkstop -h for details.
- new tool forkstart accepts switches, enabling it to replace forkstartf, forkstartfnw, forkstarth, forkstartall and forkstarttl.  Run forkstart -h for details.

# Changelog, Version 2.2:

1. All configuration options have been moved out of forktoolsinit.sh and into sub-includes named config.forkstartall, config.forkaddplotdirs, etc.   For your own convenience, please preserve your settings when updating for transfer to the new config file structure.
2. New `bash installft.sh` installation script.  Updates code to latest version, tests for curl installation, sets up environment variables, creates all known needed symlinks, sets up new config.forktool files from .template versions if not already configured (see previous changelog entry) and makes forktools executable.
3. Compatibility added for forks that do not rename their processes, folders or code directories from "chia".  Prime examples are lucky, xcha, nchain, rose and fishery.  Please note that adding this compatibility is NOT an endorsement on my part recommending farming of any forks with such terrible lazy coding practices.  Quite the opposite.  KNOWN ISSUE:  Everything works except memory usage, which cannot be fixed at this time due to process names being indistinguishable from chia and each other. 
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
8. forkconfig default text editor can now be changed via editing config.forkconfig (defaults to gedit as before)
9. A great deal of work has been made to make forktools MacOS X compatible, though some work still needs to be done.  The simpler tools should work fine on MaxOS X, but forklog, forkmon and forkexplore probably won't until at least next version.


# INSTALLATION INSTRUCTIONS:

For initial update to version 2.2, I recommend (for one final time) simply wiping out your forktools directory and doing a fresh `git clone https://github.com/qwinn1/forktools`.  If you helped in the testing branch and haven't already gotten the very latest version of the install script, preserve your config.* files.  If you are still on the main branch of version 2.0, preserve your forktoolsinit.sh for transfer of your configuration settings to the new config.fork* file structure.

FOREVER AFTER THAT, you can update forktools at any time by simply running the following:

```
cd forktools
bash installft.sh  # This will update all scripts without touching your config files.
bash installft.sh  # Run it a second time just in case the install script itself was updated during the first run.

# Only needed if this is your first ever install of forktools
source ~/.bashrc  # or source ~/.bash_profile if you're on MacOS X
```

That's it!  Forever after, you can run `bash installft.sh` at any time without harm (including whenever you've installed a new fork which needs symlinks created).  Shouldn't ever need to re-git-clone forktools again.  Once version 2.2 is on your system, updating forktools solely via the install script has become super easy, barely an inconvenience.


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
(venv) qwinn@Muninn:~/forktools$ forkmon

------------------------------------------------------------------- FARMERS: 14 -----------------------------------------------------------------

                                                                              FulNode   Memory   NoHarv       Address              Last
Farmer            Version         Status   #Peers   #Plots  Height  Netspace  Workers    Usage   Errors       Balance   ETW        Block   Effort
-------------------------------------------------------------------------------------------------------------------------------------------------
apple             1.2.31.dev1     Farming       8     4424  268478   381 PiB     20    1974 MB      42        414 APPLE 4h47m    3h31m ago    73%
avocado           1.1.7.dev124    Farming       8     4424  324927   404 PiB     20    1971 MB       5        280 AVO   4h44m     5h4m ago   106%
beet              2.1.1           Farming       8     4424  114123    55 PiB     20    1334 MB      28        980 XBT   40m        19m ago    47%
btcgreen          2.1.0           Farming       8     4424  173656   252 PiB     20    2369 MB      41        494 XBTC  3h7m      1h5m ago    35%
cannabis          1.2.301         Farming       8     4424  280697   239 PiB     20    1820 MB      28       4896 CANS  2h57m    2h39m ago    90%
covid             1.2.3           Farming       8     4424  232792   244 PiB     20    1816 MB      28       3740 COV   2h50m    2h52m ago   101%
flax              0.1.1           Farming       8     4424  451807   2.6 EiB     20    3273 MB      28        140 XFX   1d10h    7h33m ago    21%
flora             0.2.5           Farming       8     4424  351214   736 PiB     20    2392 MB      40        496 XFL   8h34m       7h ago    81%
goji              0.2.3           Farming       8     1377  383528   553 PiB     20    2802 MB       0        194 XGJ   21h53m   4h40m ago    21%
goldcoin          1.0.1.dev11     Farming       8     4424   37045    53 PiB      6     515 MB      29        736 OZT   32m        44m ago   133%
greendoge         1.2.6           Farming       8     4424  321717   528 PiB     20    1016 MB      28       3440 GDOG  6h1m     2h21m ago    39%
maize             1.2.3.dev14     Farming       8     4424  268535   342 PiB     20    1881 MB      41        514 XMZ   4h6m     3h11m ago    77%
mint              0.1.0           Farming      20     4424   91489     5 PiB     19    1577 MB       0         40 XQM   2m          2m ago   119%
scam              1.0.5           Farming       8     4424  174416   126 PiB     20    1639 MB      42       5680 SCM   1h25m    1h20m ago    93%

-------------------------------------------- HARVESTERS: 29 ------------------------------------------------
                                                            Longest      Longest     Proofs
                                                 Last      Response     Response      Since
Harvester         Version      # Plots        Harvest         Today    Yesterday  Yesterday
------------------------------------------------------------------------------------------------------------
apple             1.2.31.dev1     1377         7s ago         5.63s        4.32s          4
avocado           1.1.7.dev124    1377        10s ago         3.49s        3.94s          3
beet              2.1.1           1377        12s ago         3.52s        4.43s         14
btcgreen          2.1.0           1377         8s ago         3.85s        3.75s          4
cactus            1.2.2.dev7      1377         6s ago         3.29s        3.68s         10
cannabis          1.2.301         1377         9s ago         4.46s        2.77s          3
chia              1.2.6           1377         8s ago         4.25s        3.98s          0
covid             1.2.3           1377         3s ago         2.63s        4.70s          4
cryptodoge        1.2.6           1377         8s ago         2.86s        3.00s          4
dogechia          1.0.9           1377         6s ago         4.07s        4.40s          1
flax              0.1.1           1377         1s ago         3.42s        3.29s          0
flora             0.2.5           1377         2s ago         3.89s        4.30s          1
goji              0.2.3           1377         0s ago         3.66s        3.70s          6
goldcoin          1.0.1.dev11     1377         5s ago         3.58s        5.10s         66
greendoge         1.2.6           1377         3s ago         5.25s        3.38s          2
hddcoin           1.2.5.dev2      1377         3s ago         4.31s        2.36s          1
kale              0.1.111         1377         5s ago         2.74s        4.01s          1
maize             1.2.3.dev14     1377         7s ago         3.45s        3.19s          1
melati            1.1.7141.dev13  1377         2s ago         2.76s        3.23s          4
mint              0.1.0           1377         7s ago         1.01s        0.00s          1
olive             0.2976          1377         7s ago         3.49s        4.05s          9
pipscoin          1.1.0           1377         7s ago         2.64s        4.36s         10
scam              1.0.5           1377         1s ago         4.02s        3.55s         10
sector            1.1.7.dev112    1377         3s ago         4.97s        3.54s          5
seno              1.1.8.dev36     1377         2s ago         3.08s        3.85s          5
silicoin          0.2.1.dev4      1377         6s ago         3.24s        6.74s          1
socks             0.1.dev4802     1377         3s ago         3.15s        4.63s          6
taco              2.1.1.dev1      1377         2s ago         1.89s        6.36s          6
tad               1.0.2           1377         7s ago         3.16s        3.29s          6
```

- forkfixconfig ( Automated editing of fork config.yamls to preferred settings as set up in config.forkfixconfig. )

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

```(venv) qwinn@Muninn:~/forktools$ forklog -h
Usage:  forklog
  forkname                                  Required parameter.  All others optional, but need at least one to get any results.
  -e | --error                              Adds 'ERROR' as a search term.
  -w | --warning                            Adds 'WARNING' as a search term.
  -ha | --harv                               Adds 'harvester' as a search term.
  -p | --proof                              Adds any positive # of found proofs as a search term.
  -g 'word' | --grep 'word'                 Adds 'word' as a search term.  Multiple uses allowed.
  -l 10 | --lastxdays 10                    Shows only results for the last 10 days.
                                            Default value can be set globally in config.forklog.
  -s YYYY-MM-DD | --startdate YYYY-MM-DD    Do not show results prior to this date.  If both this and -l / --lastxdays are set, this is used.
                                            Default value can be set globally in config.forklog.
  -u | --enddate YYYY-MM-DD                 Do not show results after this date.
                                            Default value can be set globally in config.forklog
  -t 100 | --tail 100                       Tails the last 100 lines of the result.
                                            forklog always tails FORKLOGTAIL lines as set in config.forklog. Use -t to change that number.
  -h | --help                               Show this information again.
```


# SETTING UP ENVIRONMENT PATHS

This section is now obsolete as `bash installft.sh` will set up your paths in .bashrc (or .bash_profile, if you're on MacOS X) for you.

# FORK NAMING CONVENTION ISSUES

This section is now obsolete as `bash installft.sh` will set up any known needed symlinks for you.


# COMMANDS WITH NO PARAMETERS:

- `forkmon`               \-  In my opinion the current heart of forktools.  This script gives you detailed information on every active fork process on your server, one section for farmers and another for harvesters.  Includes longest response times, fullnode worker count, memory usage, wallet balances for your target addresses, how long ago the last block was won, ETW (far more accurately than what chia or any other fork provides), effort percent, and much more! As of version 2.2, forkmon can now take a single fork as a parameter, and -n / --nobalance switch can be specified to show all wallet balances as 0, useful if you want privacy when posting forkmon results online.
- `forkports`             \-  Checks port locking contention on all forks with an active _harvester process.  Checks every port listed for mainnet in each fork's config.yaml, then runs `ss` scanning for every port used by that fork and lists any process which references those ports and does not contain that fork's binary name as the owner of the process.  If the listed processes don't have a *different* fork or app's name as the owner of the process, that output can probably be safely disregarded.  If no processes are listed under a given fork in the output, no ports were locked by a different fork - i.e., no conflict found.
- `forktargets`           \-  lists the target wallet addresses as configured in every active fork farmer's config.yaml in a convenient and organized list for easy visual comparison to whatever list of wallet addresses you intend rewards to go to that you're currently maintaining.  Also compares the target setting in config.yaml to the RPC call for the same value, and gives a big warning if they don't match.


# COMMANDS WITH PARAMETERS, EXAMPLES OF USAGE

- `forkfixconfig chia`    \-  Provides automated editing of several entries in chia's config.yaml that require frequent editing - log level, plot loading frequency, farmer peer for harvesters, and several more.  Requires confirmation and creates backups.  Does not actually require editing of default options in config.forkfixconfig - the defaults I picked should work fine - but if you'd like to tweak them, you can do so there.  Please report if the defaults as I chose them cause you any issues so I can review.
- `forkconfig hddcoin`    \-  Opens the .hddcoin/mainnet/config/config.yaml file in gedit. You can now set your preferred text editor in config.forkconfig.
- `forknodes avocado`     \-  prints a list of currently connected nodes for sharing with others having difficulty connecting. Prepends each node and port with "avocado show -a " for easy CLI connection command via cut and paste.
- `forksum scam`          \-  runs "scam farm summary"
- `forkver flora`         \-  runs "flora version", returns the version # of the current install
- `forkwalletshow maize`  \-  runs "maize wallet show"
- `forkstart kale -f`     \-  runs "kale start farmer -r"
- `forkstart cactus -fnw  \-  runs "cactus start farmer-no-wallet -r"
- `forkstart cannabis`-h  \-  runs "cannabis start harvester -r"
- `forkstart silicoin`-t  \-  starts timelord for silicoin.  Requires having previously run sh install-timelord.sh in the silicoin-blockchain directory.
- `forkstart all`         \-  starts every service listed in config.forkstartall
- `forkstop covid`        \-  stops all services for covid (If you're running GUI farmer, recommend closing that first)
- `forkstop stor -t`      \-  stops 
- `forkstop all`          \-  stops all services for covid (If you're running GUI farmer, recommend closing that first)
- `forkbenchips tad`      \-  runs benchmark of your system's capacity to run a timelord for tad, in ips.  Requires having previously run sh install-timelord.sh in the tad-blockchain directory
- `forkstoptl pipscoin`   \-  stops timelord for pipscoin.  Requires having previously run sh install-timelord.sh in the pipscoin-blockchain directory.
- `forkaddplotdirs taco`  \-  Requires configuration in config.forkaddplotdirs to use.  List your plot directories there, then you can add them to any fork quickly with a single command.  Gives warnings if a drive listed in the config is not mounted.

# COMMANDS WITH MULTIPLE PARAMETERS

- `forklog`               \-  This single function has now replaced all previous log parsing forktools. You need to pass at least one switch after the forkname to get any output.  You can manipulate log output now any way I could think of if you get creative with the switches, but you're still able to duplicate the quick and simple older versions with a single switch for each.  Just run forklog -h to get a full list of options. The first line of forklog output will be the actual bash command that is constructed after all the switches and parameters are interpreted that produces the output that follows.
- `forkexplore`           \-  100% local address explorer.  Provides address balances for your target receive address for the selected fork, but has an additional -a switch which allows you to explore any receive address you wish, hot or cold, and all the same date range options that forklog has.  Does not require sync, just a running farmer.  Run forkexplore -h for detailed usage instructions.


## HOW WE GOT HERE - notes from version 1.0, updated slightly

#### Several command line tools to greatly simplify CLI maintenance of one or many Chia forks


I created these CLI scripts, currently only for Ubuntu environment (but very very workable on Windows by installing WSL2, I do it myself), because I was farming 21 separate Chia forks and maintenance started becoming a chore, having to CD into the fork's hidden directories to view logs or config files, or to the fork-blockchain directory and . ./activate to issue any fork commands.  So what I was doing was opening a terminal box with 20 tabs, with each one cd'd into that fork's proper directories so I could quickly issue commands.  That worked well enough when it was only up to a dozen forks or so, but quickly grew cumbersome, ESPECIALLY recreating all the tabs after a reboot.

The scripts herein allow me to maintain and work with all the forks from a single terminal tab, without having to change directories.  Feel free to modify them for your own needs.  I think these tools make even maintaining a single fork (such as just chia) a lot easier, saving a great many keystrokes.

These are all very simple bash scripts (EDIT:  some are not so simple anymore!).  No compiling is necessary.  Simply cat or grep them however you like and verify they're not doing anything you wouldn't want to do yourself.

# DISCORD SERVER

Got a fun crowd here already.  Come join us!  And if you have any issues, I'll be happy to help.

https://discord.gg/XmTEZ4SHtj


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

