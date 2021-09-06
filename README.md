# Qwinn's forktools

# WHAT'S NEW

Literally practically everything.  But still 100% local, still 100% bash!

Version 2.0 is a massive update with nearly a dozen new features! 

- new tool:  forkexplore! a 100% local blockchain address explorer!  As long as you have a farmer running a synced blockchain, forktools can query on hot or cold wallet balances and transaction history.  Wallet sync is not necessary.  Also consolidates the paired 0.25/1.75 block rewards for easier review. Can specify date ranges for the output too.  Here's a taste:

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

- updated tool:  forkmon!  Naturally the address information has made it into forkmon - with the most specific and accurate calculation of ETW and Effort% possible (down to seconds), using chia's exact formula but without rounding 23 or 44 days to 'a month'.

```---------------------------------------------------------------- FARMERS: 13 --------------------------------------------------------------

                                                                       FulNode   Memory   NoHarv        Wallet              Last
Fork              Version         Status   #Peers   #Plots   Netspace  Workers    Usage   Errors       Balance   ETW        Block   Effort
-------------------------------------------------------------------------------------------------------------------------------------------
cactus            1.2.2.dev7      Farming       8     4424    266 PiB     20    1900 MB       0        458 CAC   3h2m     1h54m ago    62%
cryptodoge        1.2.6           Farming      25     4424    188 PiB     20    1637 MB    7674    3600000 XCD   2h1m     2h38m ago   130%
dogechia          1.0.9           Farming       8     4424    507 PiB     20    2126 MB       0        328 XDG   5h53m       3m ago     0%
hddcoin           1.2.5.dev2      Farming      10     4424    499 PiB     20    2091 MB       0        331 HDD   5h59m       4h ago    67%
kale              0.1.111         Farming       9     4424    361 PiB     20    2082 MB       0        254 XKA   4h44m    7h36m ago   160%
melati            1.1.7140        Farming       8     4424    274 PiB     20    1885 MB       0        374 XMX   2h58m      26m ago    15%
olive             0.0.296         Farming       8     4424    109 PiB     20    1621 MB       0       1042 XOL   1h15m    1h31m ago   121%
pipscoin          1.1.0           Farming      74     4424     31 PiB     20    1785 MB       0        240 PIPS  27m        22m ago    84%
seno              1.1.8.dev36     Farming       7     1379    350 PiB     20    3054 MB       0        160 XSE   13h6m    5h34m ago    42%
silicoin          0.0.9.dev10     Farming      55     4424    821 PiB     20    2189 MB       0        225 TSIT  9h2m      5h7m ago    56%
```

- new tool:  forkfixconfig!  Tired of changing the same settings in every config file every time you update or set up a new fork?  Then forkfixconfig is for you!  Allows automated setting (with backups, of course) of your preferred log_level, max_logfilesrotation, plot_loading_frequency (old or new version), farmer_peer for your harvesters and more!  Even allows you to add 'multiprocessing_limit" for the new feature added to several forks to reduce RAM usage - but it won't install it until it can verify you are synced, because setting it before that would be bad.  Here's a taste:

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
  Old Target Peer Count:  target_peer_count: 80
  New Target Peer Count:  target_peer_count: 10
  Old Harvester Farmer_Peer IP:  host: *self_hostname
  New Harvester Farmer_Peer IP:  host: 10.0.0.104
  Appending:  multiprocessing_limit: 4
Should you proceed, a backup of your current config.yaml will be made called config.yaml.2021-09-03
Are you sure you wish to make these changes? (Y/y)y
```

- update tool:  forktargets!  Reformatted and now focuses on the farmer target reward (pool target is not considered).  More importantly, it now checks to make sure that the setting in your config.yaml has actually taken effect.  Wait, the config.yaml isn't the last word as to where rewards go?  Afraid not.  A little demonstration...

```qwinn@Huginn:~/forktools$ forktargets
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

- new tool:  forklog!  Replaces forkloge, forklogt, forklogg, forklogh forklogp and forklogw from previous versions. Instead, you'll use this one tool with lots of switches that you can combine at will.  Also has fully customizable date range capability.  And it's quite well documented.  You want to see all ERRORs *and* WARNINGs *and* found proofs from the last 12 days all in one output, but then just the last 20 lines of the result?  That's now super easy, barely an inconvenience:

```qwinn@Huginn:~/forktools$ forklog -h
Usage:  forklog
  forkname                                  Required parameter.  All others optional, but need at least one to get any results.
  -e | --error                              Adds 'ERROR' as a search term.
  -w | --warning                            Adds 'WARNING' as a search term.
  -p | --proof                              Adds any positive # of found proofs as a search term.
  -ha | --harv                              Adds 'harvester' as a search term.
  -g 'word' | --grep 'word'                 Adds 'word' as a search term.  Multiple uses allowed.
  -l 10 | --lastxdays 10                    Shows only results for the last 10 days.
                                            Default value can be set in forktoolsinit.sh.
  -s YYYY-MM-DD | --startdate YYYY-MM-DD    Do not show results prior to this date.  If both this and -l / --lastxdays are set, this is used.
                                            Default value can be set in forktoolsinit.sh.
  -u | --enddate YYYY-MM-DD                 Do not show results after this date.
                                            Default value can be set in forktoolsinit.sh.
  -t [100] | --tail [100]                   Tails the last 100 lines of the result.
                                            The number parameter is optional.  If not set, uses default value set in forktoolsinit.sh
  -h | --help                               Show this information again.
qwinn@Huginn:~/forktools$ ```

- all tools now have vastly improved error handling when parameters are passed incorrectly.

- all configuration options centralized!  Every single forktool now shares an include - forktoolsinit.sh - which contains every configurable option for every single tool.  You no longer edit forkaddplotdirs to add your plot directories, and then separately manipulate forkstartall to tell it which forks to start up after a reboot - instead, every single customization is all done in the same include file.  I won't bother showing it here.  Just trust me, you'll want to check out the CONFIGURATION SECTION of forktoolsinit.sh for yourself ASAP to see all the options for setting defaults that you have now.  This will make backing up your customizations in preparation for updating forktools much easier.  For version 2.0 only I'll be releasing a forktoolsinit.sh file, but every version after that it'll be forktoolsinit.sh.template so that I don't overwrite your customizations.  I'll let you know with each update if you will need to diff and merge the two files, or if it hasn't changed and you need not bother.  All the .template files from previous versions are no longer necessary and have been removed.

If I haven't gotten your attention by now, I never will.  So let's get on with it.
```

# INSTALLATION

```
# if you don't have curl already, version 2.0 of forktools does require it in order to make RPC calls to the various fork full nodes, farmers and harvesters.  It's currently the only dependency.
sudo apt update
sudo apt upgrade -y
sudo apt install curl

git clone https://github.com/Qwinn1/forktools
cd forktools
chmod 777 fork*
```

# SETTING UP ENVIRONMENT PATHS

In previous versions my instructions were to add forktools to your paths by placing a file in /etc/profile.d.  That, it turns out, was a lousy idea.  Thanks to solarhash for suggesting a far far better option.  If you placed envforktools.sh in that directory for previous versions, please delete it with my apologies.  Instead, open your ~/.bashrc file, and just add these lines below to the end.

```
export FORKTOOLSDIR="$HOME/forktools"
export FORKTOOLSBLOCKCHAINDIRS="$HOME"
export FORKTOOLSHIDDENDIRS="$HOME"

export PATH="$PATH:$FORKTOOLSDIR"
```
Then run `source ~/.bashrc` to make it work immediately, or just reboot.  And you're done.  This is a far cleaner solution.
 
# FORK NAMING CONVENTION ISSUES

- A handful of forks are so mind-boggingly lazy as to still use "chia" as their executable, or create "chia_farmer" processes.  I have no interest in supporting forks that engage in such terrible practices.  Therefore, consider such forks simply not supported.  This currently includes ChiaRose, N-Chain, and Lucky.

- These scripts assume that the fork's binary executable and the .hidden data file directory are the same name.  A handful of forks didn't follow that convention.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork data directories):

  - Spare:              `ln -s /home/user/.spare-blockchain /home/user/.spare`
  - Goji:               `ln -s /home/user/.goji-blockchain /home/user/.goji`
  - Seno:               `ln -s /home/user/.seno2 /home/user/.seno`
  - Beer:               `ln -s /home/user/.beernetwork /home/user/.beer`

- These scripts assume the fork's repo directory is named 'forkname-blockchain'.  A handful of forks didn't follow that convention.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork repo/code directories):

  - Dogechia:           `ln -s /home/user/doge-chia /home/user/dogechia-blockchain`
  - littlelambocoin:    `ln -s /home/user/littlelambocoin /home/user/littlelambocoin-blockchain`
  - cryptodoge:         `ln -s /home/user/cryptodoge /home/user/cryptodoge-blockchain`

# COMMANDS WITH NO PARAMETERS:

- `forkmon`               \-  In my opinion the current heart of forktools.  This script gives you detailed information on every active fork process on your server, one section for farmers and another for harvesters.  Includes longest response times, fullnode worker count, memory usage, wallet balances for your target addresses, how long ago the last block was won, effort percent, and much more! 
- `forkstopall`           \-  Stops all services (including daemon) for all forks with an active _harvester process running.
- `forkstartall`          \-  Requires configuration in forktoolsinit.sh.  Just list there which forks you'd like started as farmers, which as farmer-no-wallet, and which as harvesters.  Between this and `forkstopall`, shutdowns and reboots are relatively painless now.
- `forkports`             \-  Checks port locking contention on all forks with an active _harvester process.  Checks every port listed for mainnet in each fork's config.yaml, then runs netstat on every port used by that fork and lists any port-locking process which does not contain that fork's binary name as the owner of the process.  If the listed processes don't have a *different* fork's name as the owner of the process, that output can probably be safely disregarded.  If no processes are listed under a given fork in the output, no ports were locked by a different fork - i.e., no conflict found.
- `forktargets`           \-  Version 2.0 lists the target wallet addresses as configured in every active fork farmer's config.yaml in a convenient and organized list for easy visual comparison to whatever list of wallet addresses you intend rewards to go to that you're currently maintaining.  In version 2.0 now also compares the target setting in config.yaml to the RPC call for the same value, and gives a big warning if they don't match.


# COMMANDS WITH ONE PARAMETER, FORKNAME

- `forkfixconfig`         \-  Provides automated editing of several entries that require frequent editing - log level, plot loading frequency, farmer peer for harvesters, and several more.  Requires confirmation and creates backups.  Does not actually require editing of default options in forktoolsinit.sh - the defaults I picked should work fine - but if you'd like to tweak them, you can do so there.  Please report if the defaults as I chose them cause you any issues so I can review.
- `forkconfig hddcoin`    \-  Opens the .hddcoin/mainnet/config/config.yaml file in gedit.  Modify this script to use your preferred text editor (vi, nano, whatever).  Not going to make that a configurable option because IMO it would be dangerous to do so because reasons.
- `forknodes avocado`     \-  prints a list of currently connected nodes for sharing with others having difficulty connecting. Prepends each node and port with "avocado show -a " for easy CLI connection command via cut and paste.
- `forkstartf kale`       \-  runs "kale start farmer -r"
- `forkstartfnw cactus`   \-  runs "cactus start farmer-no-wallet -r"
- `forkstarth cannabis`   \-  runs "cannabis start harvester -r"
- `forksum scam`          \-  runs "scam farm summary"
- `forkver flora`         \-  runs "flora version", returns the version # of the current install
- `forkshowwallet maize`  \-  runs "maize show wallet"
- `forkstoph covid`       \-  stops harvester process for covid (If you're running GUI farmer, recommend closing that first)
- `forkstopa socks`       \-  stops ALL services for socks (If you're running GUI farmer, recommend closing that first)
- `forkbenchips tad`      \-  runs benchmark of your system's capacity to run a timelord for tad, in ips.  Requires having previously run sh install-timelord.sh in the tad-blockchain directory
- `forkstarttl silicoin`  \-  starts timelord for silicoin.  Requires having previously run sh install-timelord.sh in the silicoin-blockchain directory.
- `forkstoptl pipscoin`   \-  stops timelord for pipscoin.  Requires having previously run sh install-timelord.sh in the pipscoin-blockchain directory.
- `forkaddplotdirs taco`  \-  Requires configuration in forktoolsinit.sh to use.  List your plot directories there, then you can add them to any fork quickly with a single command.

# COMMANDS WITH MULTIPLE PARAMETERS

- `forklog`               \-  This single function has now replaced all previous log parsing forktools. You need to pass at least one switch after the forkname to get any output.  You can manipulate log output now any way I could think of if you get creative with the switches, but you're still able to duplicate the quick and simple older versions with a single switch for each.  Just run forklog -h to get a full list of options.
- `forkexplore`           \-  New 100% local address explorer.  Provides address balances for your target receive address for the selected fork, but has an additional -a switch which allows you to explore any receive address you wish, hot or cold, and all the same date range options that forklog now has.  Does not require wallet sync, just a synced full node.  Run forkexplore -h for detailed usage instructions.


# HOW WE GOT HERE - notes from version 1.0, updated slightly

#### Several command line tools to greatly simplify CLI maintenance of one or many Chia forks


I created these CLI scripts, currently only for Ubuntu environment (but very very workable on Windows by installing WSL2, I do it myself), because I was farming 21 separate Chia forks and maintenance started becoming a chore, having to CD into the fork's hidden directories to view logs or config files, or to the fork-blockchain directory and . ./activate to issue any fork commands.  So what I was doing was opening a terminal box with 20 tabs, with each one cd'd into that fork's proper directories so I could quickly issue commands.  That worked well enough when it was only up to a dozen forks or so, but quickly grew cumbersome, ESPECIALLY recreating all the tabs after a reboot.

The scripts herein allow me to maintain and work with all the forks from a single terminal tab, without having to change directories.  Feel free to modify them for your own needs.  I think these tools make even maintaining a single fork (such as just chia) a lot easier, saving a great many keystrokes.

These are all very simple bash scripts (EDIT:  some are not so simple anymore!).  No compiling is necessary.  Simply cat or grep them however you like and verify they're not doing anything you wouldn't want to do yourself.




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

