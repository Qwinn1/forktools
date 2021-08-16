# Qwinn's forktools

### Several command line tools to greatly simply CLI maintenance of one or many Chia forks

I created these CLI scripts, currently only for Ubuntu environment (Windows versions may be added later), because I am currently farming 21 separate Chia forks and maintenance
started becoming a chore, having to CD into the fork's hidden directories to view logs or config files, or to the fork-blockchain directory and . ./activate to issue any
fork commands.  So what I was doing was opening a terminal box with 20 tabs, with each one cd'd into that fork's proper directories so I could quickly issue commands.  That
worked well enough when it was only up to a dozen forks or so, but quickly grew cumbersome, ESPECIALLY recreating all the tabs after a reboot.

The scripts herein allow me to maintain and work with all the forks from a single terminal tab, without having to change directories.  Feel free to modify them for your 
own needs.  I think these tools make even maintaining a single fork (such as just chia) a lot easier, saving a great many keystrokes.

These are all very simple bash scripts.  No compiling is necessary.  Simply cat them and verify they're not doing anything you wouldn't want to do yourself.

Note that in the following description, FORKNAME is the name of the hidden file and binary for the fork.  In all forks I'm aware of, the two are the same (minus the leading
period of the hidden directory, of course).

# INSTALLATION

```
git clone https://github.com/Qwinn1/forktools
cd forktools
chmod 777 fork*
```

# ASSUMPTIONS REGARDING FORK NAMING CONVENTIONS

These scripts assume:

- That the fork's binary executable name and the .hidden file directory name are the same.  I'm unaware of any fork that violates this convention.  I refer to that name as 'forkname' in documentation.
- That the name of the fork's blockchain directory is 'forkname-blockchain'.  The only fork I'm aware of that violates this convention in a default git installation is dogechia, which names their blockchain directory 'doge-chia' instead of what would conventionally be 'dogechia-blockchain'.  You can deal with this by setting up a symbolic link like so:  `ln -s /home/user/doge-chia /home/user/dogechia-blockchain`

# COMMANDS WITH NO PARAMETERS:

- `forkcounth`            \- Simply returns the number of active *_harvester processes running via ps -ef.  A quick numerical check to make sure the right number of fork harvester processes are running on the server (farmers also run harvester processes).  Should equal the total number of forks you are farming.

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
- `forkaddplotdirs chia`  \-  This script will do nothing until you manually edit it.  Modify and uncomment the provided example lines to add all of your plot directories on that server to the specified fork.

# COMMANDS WITH TWO PARAMETERS

- `forklogg chia signage`    \-  Use when you need to search the log for something besides the premade options provided above.  This example searches for the word "signage" in the chia logs.

# SETTING UP ENVIRONMENT PATHS

If your blockchain directories and hidden folders are all directly under your $HOME directory, you don't really need to set up an environment, as those are the default paths.  You could then just run any given command by being in your forktools directory and running the script like this:  `./forkloge chia`.  If you have a custom location for your directories, or if you just want to be able to run the forktools from any directory on your system, create a text file called `envforktoolsv.sh` and place it in the `/etc/profile.d` directory (sudo required, reboot to make the changes persistent and global).  Paste these into it, customizing the paths for your setup:

```
export FORKTOOLSDIR="$HOME/forktools"
export FORKTOOLSBLOCKCHAINDIRS="$HOME"
export FORKTOOLSHIDDENDIRS="$HOME"

export PATH="$PATH:/$FORKTOOLSDIR"
```

A copy of exactly that envforktools.sh is included in the forktools directory for convenience.



# UPCOMING IN VERSION 1.1

I am currently working on adding scripts that will edit a fork's config.yaml files to set:

-   `log_level`   Script default: INFO
-   `log_maxfilesrotation`  Script Default: 99   
-   `plot_loading_frequency_seconds`  Script Default: 1800 (especially when done plotting, reloading plots every half hour is more than sufficient, every 3 minutes is huge overkill)   
-   `plot_directories`  Script Default:  None.  But if you edit the relevant variable in the script and list the drives the way they should appear in the config.yaml, it will insert them for you.

...and there will be a harvester version that also sets the farmer_peer to the IP address of your farmer, passed in as a parameter.



# DONATIONS ACCEPTED.  

Thank you for your support.

- Chia:        xch1gsqc9t20fs22eltff3c9eghnw80sq609zsgcj8sz5378jupzd5xqqrv0sl
- Flax:        xfx179de2g9d33rd2h8yanhx82h2yx7hvqt4c8j6kjylw2q2zdl2fvgqmze5pe
- Dogechia:    xdg1tmk09uhu74na3pk0zsh9h30a8k3wy9u4a4gpexjskknfqqwlh42qe2spxt
- HDDcoin:     hdd1w5hw0qsv0se7kysdl9un8325g0kyl668w0953ha5phxh47jtu3ss8fvkg2
- Chaingreen:  cgn13tdywzv3lxm8txzt5ggxvmzwjkxlhvcq04qjrc50rpjdpcsfh7jshzx9l2
- Silicoin:    tsit1s8akjytuygq5kfwk85ag6jqvc93k6vw5hz2vwx3ekjsjy55h2lkq93xphd
- Tad:         tad15ygc3yqnp5gvdq30svx4thtkdxz9qzfwmev2nvw4s36nkrzgce3scqj2l7             
- Flora:       xfl1wwtptljkz288swswmazjc74ck6thfg6hy7hd0dr5suggvdjlzscs3x08qw
- Taco:        xtx18d6spw69ghwhdc928ysex3el0ny83l0rzvj2es0m8ram5jaqckjqgcpzad
- Cactus:      cac1x73mqd9g4md2vgcjc0yemvz5j2xlzuk4d78kkdgse59f5mgxvj4qudr3yz
- Apple:       apple18ccn7ksalj9gu0t4yzj89fljav7886yz22xcdx707axwmdlane8ql76k03
- Maize:       xmz1ep5p5qlc66uw98h6a9f9kt5xcfuzafph43m9l6wnacgm8ndfvujs8khasf
- GreenDoge:   gdog10jx7mdylp935k2vrhkfpt6qcq3ttwzedl0nl62vtvkkgd8mkj2pse7afdn
- Covid:       cov19h8apm8cnggn2mag8qr8enxmyutngxh5te3fj3fmmy98ywkaa49qzpymq3
- Melati:      xmx1v52ku7lq90xhcakdqghz39tu32zpkusfmyz3hs5v2xgwa37q939q3u98av
- Cannabis:    cans1ekz29eve4z7hes59anqnd0wcggcekkd7qhh8j0lcz4waeqt847sq6f87h0
- BTCGreen:    xbtc15d4yfuyx4zx9yl7r3y8mmw4ey6q8p4khvh27jw692rav84x8002qng2s69
- Kale:        xka18hv0y237ehdjp896mpqswdnu3epkj7ehxwgmng4yusw3ccjgpydqthfwwv
- Avocado:     avo1p4p7m4rwwltgln7cg03ucgcldas5w6n7w4y7786ju56v79yq8plssfl3ts
- Socks:       sock1lwvch9vss70k2s3x0mdqkxdrpr56z2dyc69cpw32apuhexr6rnxq8ullpj
- Olive:       xol1xff06jnuger5s6ewa47xqrmxm6z09rn8m2wg9qsdyf4cfd8uwrdsnhwkkt
- Scam:        scm1flju3xzwt2vpqjn5sttwwgxe7xcy825lagca0xc2ycum5eghvcaqayqk9d 

