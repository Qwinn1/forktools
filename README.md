# Qwinn's forktools

#### Several command line tools to greatly simplify CLI maintenance of one or many Chia forks


I created these CLI scripts, currently only for Ubuntu environment (Windows versions may be added later), because I am currently farming 21 separate Chia forks and maintenance
started becoming a chore, having to CD into the fork's hidden directories to view logs or config files, or to the fork-blockchain directory and . ./activate to issue any
fork commands.  So what I was doing was opening a terminal box with 20 tabs, with each one cd'd into that fork's proper directories so I could quickly issue commands.  That
worked well enough when it was only up to a dozen forks or so, but quickly grew cumbersome, ESPECIALLY recreating all the tabs after a reboot.

The scripts herein allow me to maintain and work with all the forks from a single terminal tab, without having to change directories.  Feel free to modify them for your 
own needs.  I think these tools make even maintaining a single fork (such as just chia) a lot easier, saving a great many keystrokes.

These are all very simple bash scripts.  No compiling is necessary.  Simply cat them and verify they're not doing anything you wouldn't want to do yourself.

# INSTALLATION

```
git clone https://github.com/Qwinn1/forktools
cd forktools
chmod 777 fork*
```
 
# FORK NAMING CONVENTION ISSUES

- A handful of forks are so mind-boggingly lazy as to still use "chia" as their executable.  I have no interest in supporting forks that engage in such terrible practices.  Therefore, consider such forks simply not supported.  This currently includes ChiaRose, N-Chain, and Lucky.

- The vast majority of forks named the fork's binary executable and the .hidden data file directory the same thing.  A handful didn't.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork data directories):

  - Spare:     `ln -s /home/user/.spare-blockchain /home/user/.spare`
  - Goji:      `ln -s /home/user/.goji-blockchain /home/user/.goji`
  - Seno:      `ln -s /home/user/.seno2 /home/user/.seno`
  - Beer:      `ln -s /home/user/.beernetwork /home/user/.beer`

- The vast majority of forks named the fork's blockchain directory 'forkname-blockchain'.  A handful didn't.  This can be easily solved by setting up symbolic links for those forks that break the convention.  Here are the commands to create the necessary symlinks for the few I'm aware of (obviously edit "/home/user" portion to be the parent directory of your fork data directories):

  - Dogechia:   `ln -s /home/user/doge-chia /home/user/dogechia-blockchain`
  - littlelambocoin:  `ln -s /home/user/littlelambocoin /home/user/littlelambocoin-blockchain`

# COMMANDS WITH NO PARAMETERS:

- `forkcounth`            \-  Simply returns the number of active *_harvester processes running via ps -ef.  A quick numerical check to make sure the right number of fork harvester processes are running on the server (farmers also run harvester processes).  Should equal the total number of forks you are farming.

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



# UPCOMING IN VERSION 1.1

I am currently working on adding scripts that will edit a fork's config.yaml files to set:

-   `log_level`   Script default: INFO
-   `log_maxfilesrotation`  Script Default: 99   
-   `plot_loading_frequency_seconds`  Script Default: 1800 (especially when done plotting, reloading plots every half hour is more than sufficient, every 3 minutes is huge overkill)   

...and there will be a harvester version with a second parameter of the IP address to set as your farmer_peer (hopefully also allowing you to just pass the server name as configured in /etc/hosts).


