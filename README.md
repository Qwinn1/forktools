# Qwinn's forktools

#### Several command line tools to greatly simplify CLI maintenance of one or many Chia forks


I created these CLI scripts, currently only for Ubuntu environment (Windows versions may be added later), because I am currently farming 21 separate Chia forks and maintenance
started becoming a chore, having to CD into the fork's hidden directories to view logs or config files, or to the fork-blockchain directory and . ./activate to issue any
fork commands.  So what I was doing was opening a terminal box with 20 tabs, with each one cd'd into that fork's proper directories so I could quickly issue commands.  That
worked well enough when it was only up to a dozen forks or so, but quickly grew cumbersome, ESPECIALLY recreating all the tabs after a reboot.

The scripts herein allow me to maintain and work with all the forks from a single terminal tab, without having to change directories.  Feel free to modify them for your 
own needs.  I think these tools make even maintaining a single fork (such as just chia) a lot easier, saving a great many keystrokes.

These are all very simple bash scripts.  No compiling is necessary.  Simply cat them and verify they're not doing anything you wouldn't want to do yourself.

# WHAT'S NEW

Still 100% local, still 100% bash!

Version 1.2 introduces forkmon!  This script gives you detailed information on every active fork process on your server, one section for farmers and another for harvesters.  Includes longest response times, fullnode worker count, proofs found in last 24-48 hours, memory usage, and much more!  (Effort%, height and wallet balance information will be trickier if I want to keep these tools local, so I'll get back to you all on those.)

Sample forkmon output (incomplete for brevity, counts won't match):

```qwinn@Huginn:~$ forkmon

----------------------------------------------------- FARMERS: 12 ------------------------------------------------------
                                                                                 FullNode      Memory   NoHarvResp
Fork               Version         Status   #Peers   #Plots   Netspace   ETW      Workers       Usage     Errors
------------------------------------------------------------------------------------------------------------------------
cactus             1.2.2.dev7      Farming       8     4424    255 PiB   3h 27m        20   1833.9 MB       0
cryptodoge         1.2.6           Farming      18     4424    174 PiB   1h 59m        20   1355.6 MB       1
dogechia           1.0.9           Farming       8     4424    495 PiB   6h 3m         20   2061.8 MB       0
hddcoin            1.2.5.dev2      Farming       8     4424    479 PiB   5h 43m        20   1165.0 MB       0
kale               0.1.111         Farming      21     4424    360 PiB   4h 8m         20   2031.5 MB       0
melati             1.1.7140        Farming       8     4424    276 PiB   3h 8m         20   1826.0 MB       0
olive              0.0.296         Farming      17     4424     91 PiB   2h 1m         20   1587.1 MB       0
seno               1.1.8.dev36     Farming       8     1379    349 PiB   13h 11m       20   2830.0 MB       0

------------------------------------------- HARVESTERS: 25 ------------------------------------------------

                                                             Longest      Longest     Proofs
                                                  Last      Response     Response      Since
Fork               Version      # Plots        Harvest         Today    Yesterday  Yesterday
------------------------------------------------------------------------------------------------------------
apple              1.2.31.dev1     1379         8s ago         3.23s        2.51s          2
avocado            1.1.7.dev124    1379         6s ago         2.36s        2.76s          3
btcgreen           2.1.0           1379         6s ago         1.97s        3.33s          4
cactus             1.2.2.dev7      1379         6s ago         1.83s        3.48s          3
cannabis           1.2.301         1379         5s ago         2.57s        3.55s          3
chia               1.2.5           1379         3s ago         3.60s        3.11s          0
covid              1.2.3           1379         3s ago         2.57s        2.93s          6
cryptodoge         1.2.6           1379         7s ago         2.89s        2.58s          7
dogechia           1.0.9           1379         2s ago         2.67s        3.58s          1
flax               0.1.1           1379         4s ago         2.09s        2.85s          0
flora              0.2.5           1379         1s ago         2.07s        2.40s          3
goji               0.2.3           1379        11s ago         2.62s        2.98s          3
greendoge          1.2.4           1379         3s ago         2.49s        3.41s          3
hddcoin            1.2.3           1379         2s ago         2.44s        2.46s          2
```


Also new is forktargets, which lists the target wallet addresses as configured in each fork's config.yaml in a convenient and organized list for easy visual comparison to whatever list of wallet addresses you're currently maintaining.  Good to check this every so often to make sure wallets haven't been diverted by error or malicious action.

Finally, forkstopa and forkports will now list their output alphabetically by fork name.

# INSTALLATION

```
git clone https://github.com/Qwinn1/forktools
cd forktools
chmod 777 fork*
```
 
# FORK NAMING CONVENTION ISSUES

- A handful of forks are so mind-boggingly lazy as to still use "chia" as their executable.  I have no interest in supporting forks that engage in such terrible practices.  Therefore, consider such forks simply not supported.  This currently includes ChiaRose, N-Chain, and Lucky.

- These scripts assume that the fork's binary executable and the .hidden data file directory are the same name.  A handful of forks didn't follow that convention.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork data directories):

  - Spare:     `ln -s /home/user/.spare-blockchain /home/user/.spare`
  - Goji:      `ln -s /home/user/.goji-blockchain /home/user/.goji`
  - Seno:      `ln -s /home/user/.seno2 /home/user/.seno`
  - Beer:      `ln -s /home/user/.beernetwork /home/user/.beer`

- These scripts assume the fork's repo directory is named 'forkname-blockchain'.  A handful of forks didn't follow that convention.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork repo/code directories):

  - Dogechia:   `ln -s /home/user/doge-chia /home/user/dogechia-blockchain`
  - littlelambocoin:  `ln -s /home/user/littlelambocoin /home/user/littlelambocoin-blockchain`
  - cryptodoge:  `ln -s /home/user/cryptodoge /home/user/cryptodoge-blockchain`

# COMMANDS WITH NO PARAMETERS:

- `forkcounth`            \-  Simply returns the number of active *_harvester processes running via ps -ef.  A quick numerical check to make sure the right number of fork harvester processes are running on the server (farmers also run harvester processes).  Should equal the total number of forks you are farming.
- `forkstopall`           \-  Stops all services (including daemon) for all forks with an active _harvester process running. No longer just a .template file, no longer needs maintenance.
- `forkports`             \-  Checks port locking contention on all forks with an active _harvester process.  Checks every port listed for mainnet in each fork's config.yaml, then runs netstat on every port used by that fork and lists any port-locking process which does not contain that fork's binary name as the owner of the process.  If the listed processes don't have a *different* fork's name as the owner of the process, that output can be disregarded.  If no processes are listed under a given fork in the output, no ports were locked by a different fork - i.e., no conflict found.
- `forkmon`               \-  Version 1.2 introduces forkmon!  This script gives you detailed information on every active fork process on your server, one section for farmers and another for harvesters.  Includes longest response times, fullnode worker count, memory usage, and much more! 
- `forktargets`           \-  Version 1.2 also adds forktargets, which lists the target wallet addresses as configured in every active fork farmer's  config.yaml in a convenient and organized list for easy visual comparison to whatever list of wallet addresses you intend rewards to go to that you're currently maintaining.  Good to check this every so often to make sure target wallets haven't been diverted by error or malicious action.


# COMMANDS WITH ONE PARAMETER, FORKNAME

- `forkloge chia`         \-  Searches for the word "ERROR" in .chia/mainnet/log/debug.log
- `forklogw flax`         \-  Searches for the word "WARNING" in .flax/mainnet/log/debug.log
- `forklogh greendoge`    \-  Searches for the word "harvester" in the greendoge debug.log file.  Good for checking response times.
- `forklogp dogechia`     \-  Searches for any non-zero "Found X proofs" in the dogechia debug.log file.
- `forklogt apple`        \-  Tails the last 100 lines of the apple debug.log file.
- `forkconfig hddcoin`    \-  Opens the .hddcoin/mainnet/config/config.yaml file in gedit.  Modify this script to your preferred text editor (vi, nano, whatever)
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
- `forkstoptl taco`       \-  stops timelord for taco.  Requires having previously run sh install-timelord.sh in the taco-blockchain directory.

# COMMANDS WITH TWO PARAMETERS

- `forklogg chia signage`    \-  Use when you need to search the log for something besides the premade options provided above.  This example searches for the word "signage" in the chia logs.

# SCRIPT TEMPLATES THAT REQUIRE EDITING

These three scripts have a .template extension because they can't work out of the box - they need to be edited for your specific configuration, but in all cases this is super easy, barely an inconvenience.  The purpose of the .template extension is so that future updates to forktools don't cause the version you edited to be overwritten.  Remove the .template extension once you've finished your work.

- `forkaddplotdirs chia`  \-  Takes forkname as a parameter.  Modify and uncomment the provided example lines to add all of your plot directories on that server to the specified fork.
- `forkstopall`           \-  No parameters.  Modify and uncomment the provided examples to sequentially shut down all services, nodes, and harvesters.  Quickly cleans everything up in preparation for a shutdown.  Remember to update it when you add a new fork or drop an old one.
- `forkstartall`          \-  No parameters.  Modify and uncomment the provided examples to sequentially fire up all of your farmers and harvesters (or even timelords, if you wish, using any of the other tools listed above).  Great for getting started quickly after a reboot.  Remember to update it when you add a new fork or drop an old one.



# SETTING UP ENVIRONMENT PATHS

If your blockchain directories and hidden folders are all directly under your $HOME directory, you don't really need to set up an environment, as those are the default paths.  You could then just run any given command by being in your forktools directory and running the script like this:  `./forkloge chia`.  If you have a custom location for your directories, or if you just want to be able to run the forktools from any directory on your system, create a text file called `envforktools.sh` and place it in the `/etc/profile.d` directory (sudo required, reboot to make the changes persistent and global).  Paste these into it, customizing the paths for your setup:

```
export FORKTOOLSDIR="$HOME/forktools"
export FORKTOOLSBLOCKCHAINDIRS="$HOME"
export FORKTOOLSHIDDENDIRS="$HOME"

export PATH="$PATH:$FORKTOOLSDIR"
```

A copy of exactly that envforktools.sh is included in the forktools directory for convenience.


# UPCOMING IN VERSION 1.3

I am currently working on adding scripts that will edit a fork's config.yaml files to set:

-   `log_level`   Script default: INFO
-   `log_maxfilesrotation`  Script Default: 99   
-   `plot_loading_frequency_seconds`  Script Default: 1800 (especially when done plotting, reloading plots every half hour is more than sufficient, every 3 minutes is huge overkill)   

...and there will be a harvester version with a second parameter of the IP address to set as your farmer_peer (hopefully also allowing you to just pass the server name as configured in /etc/hosts).


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

