#! /usr/bin/env bash

echo "Installing forktools main branch..."

echo "Updating ( git fetch --all, git reset --hard origin/main ) to most current version of forktools..."
git fetch --all
git reset --hard origin/main

# Test for curl installation
CURLFOUND=$( type -P curl )
if [[ $CURLFOUND != '' ]]; then
  echo "Curl installed.  Proceeding with forktools installation."
else
  echo "Curl is not installed.  Curl is required for forktools to be able to make required RPC calls."
  echo "Aborting install script.  Please run the following commands and then run this install script again:"
  echo
  echo "sudo apt update"
  echo "sudo apt upgrade -y"
  echo "sudo apt install curl"   
  exit
fi  


if [[ $OSTYPE == 'darwin'* ]]; then
  ENVFILE="$HOME/.bash_profile"
else
  ENVFILE="$HOME/.bashrc"
fi

echo "Setting up environment variables in $ENVFILE"
# Removes all FORKTOOLS related lines from bash startup file
sed "-i.bak" '/FORKTOOLS/d' "$ENVFILE"
#

FORKTOOLSDIR=$PWD

# Tries to confirm at least one *-blockchain and one .*/mainnet/config exist wherever $FORKTOOLSBLOCKCHAINDIRS and $FORKTOOLSHIDDENDIRS were set previously (existing users) or $HOME if not already set (new users)
if [[ "$FORKTOOLSBLOCKCHAINDIRS" = '' ]]; then
  FORKTOOLSBLOCKCHAINDIRS="$HOME"
fi
FINDBLOCKCHAINDIRS=$(ls -d $FORKTOOLSBLOCKCHAINDIRS/*-blockchain | grep -v "No such file or directory" | wc -l | awk '{$1=$1};1')
if [[ "$FINDBLOCKCHAINDIRS" = 0 ]]; then
  cd ..
  FINDBLOCKCHAINDIRS=$(ls -d *-blockchain | wc -l | awk '{$1=$1};1')  
  cd $FORKTOOLSDIR  
fi
if [[ "$FINDBLOCKCHAINDIRS" = 0 ]]; then
   echo "Cannot find blockchain directories path.  Please specify full path to parent directory of your -blockchain directories."
   read FORKTOOLSBLOCKCHAINDIRS
fi

if [[ "$FORKTOOLSHIDDENDIRS" = '' ]]; then
  FORKTOOLSHIDDENDIRS="$HOME"
fi
FINDHIDDENDIRS=$(ls -da $FORKTOOLSHIDDENDIRS/.*/mainnet/config | wc -l | awk '{$1=$1};1')
if [[ "$FINDHIDDENDIRS" = 0 ]]; then
  cd ..
  FINDHIDDENDIRS=$(ls -da $FORKTOOLSHIDDENDIRS/.*/mainnet/config | wc -l | awk '{$1=$1};1')
  cd $FORKTOOLSDIR
fi
if [[ $FINDHIDDENDIRS = 0 ]]; then
  echo "Cannot find hidden data directories path.  Please specify full path to parent directory of your .fork directories."
  read FORKTOOLSHIDDENDIRS
fi

echo "export FORKTOOLSDIR=$FORKTOOLSDIR" >> "$ENVFILE"
echo "export FORKTOOLSBLOCKCHAINDIRS=$FORKTOOLSBLOCKCHAINDIRS" >> "$ENVFILE"
echo "export FORKTOOLSHIDDENDIRS=$FORKTOOLSHIDDENDIRS" >> "$ENVFILE"
echo 'export PATH=$PATH:$FORKTOOLSDIR' >> "$ENVFILE"
source "$ENVFILE"

echo "Scanning for and setting up required symlinks for forks with non-standard paths..."


# Symlink creation for -blockchain dirs
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/doge-chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/dogechia-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/doge-chia $FORKTOOLSBLOCKCHAINDIRS/dogechia-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/littlelambocoin" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/littlelambocoin-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/cryptodoge" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/cryptodoge-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/cryptodoge $FORKTOOLSBLOCKCHAINDIRS/cryptodoge-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/nchain-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain $FORKTOOLSBLOCKCHAINDIRS/nchain-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/chia-rosechain" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/rose-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/chia-rosechain $FORKTOOLSBLOCKCHAINDIRS/rose-blockchain
fi

# Symlink creation for .hidden dirs
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.spare-blockchain" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.spare" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.spare-blockchain $FORKTOOLSHIDDENDIRS/.spare
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.goji-blockchain" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.goji" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.goji-blockchain $FORKTOOLSHIDDENDIRS/.goji
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.seno2" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.seno" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.seno2 $FORKTOOLSHIDDENDIRS/.seno
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.beernetwork" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.beer" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.beernetwork $FORKTOOLSHIDDENDIRS/.beer
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.venidium/kition" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.venidium/mainnet" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.venidium/kition $FORKTOOLSHIDDENDIRS/.venidium/mainnet
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.chia/ext9" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.nchain/mainnet" ) ]]; then
  if [[ ( ! -d "$FORKTOOLSHIDDENDIRS/.nchain" ) ]]; then
    printf 'Created dummy directory: '
    mkdir -v $FORKTOOLSHIDDENDIRS/.nchain
  fi
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.chia/ext9 $FORKTOOLSHIDDENDIRS/.nchain/mainnet
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.chiarose" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.rose" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.chiarose $FORKTOOLSHIDDENDIRS/.rose
fi


# Symlink creation for code directories
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/silicoin" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/silicoin
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/nchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/nchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/rose" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/chia $FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/rose
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/fishery" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/fishery
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/lucky-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/lucky-blockchain/lucky" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/lucky-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/lucky-blockchain/lucky
fi

# Symlink creation for executables
if [[ ( -f "$FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/venv/bin/chia" ) && ( ! -f "$FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/venv/bin/nchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/venv/bin/chia $FORKTOOLSBLOCKCHAINDIRS/ext9-blockchain/venv/bin/nchain
fi
if [[ ( -f "$FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/venv/bin/chia" ) && ( ! -f "$FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/venv/bin/rose" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/venv/bin/chia $FORKTOOLSBLOCKCHAINDIRS/chia-rosechain/venv/bin/rose
fi
if [[ ( -f "$FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/venv/bin/chia" ) && ( ! -f "$FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/venv/bin/fishery" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/venv/bin/chia $FORKTOOLSBLOCKCHAINDIRS/fishery-blockchain/venv/bin/fishery
fi




echo "Copying config.FORKTOOL.template files to config.FORKTOOL if necessary..."
if [[ ( ! -f "$FORKTOOLSDIR/config.forkstartall" ) ]]; then
  echo "No existing config.forkstartall file found.  Copied from config.forkstartall.template."
  echo "  WARNING:  forkstartall will not function until config.forkstartall is manually configured."
  cp $FORKTOOLSDIR/config.forkstartall.template $FORKTOOLSDIR/config.forkstartall
fi 
if [[ ( ! -f "$FORKTOOLSDIR/config.forkaddplotdirs" ) ]]; then
  echo "No existing config.forkaddplotdirs file found.  Copied from config.forkaddplotdirs.template."
  echo "  WARNING:  forkaddplotdirs will not function until config.forkaddplotdirs is manually configured."
  cp $FORKTOOLSDIR/config.forkaddplotdirs.template $FORKTOOLSDIR/config.forkaddplotdirs
fi 
if [[ ( ! -f "$FORKTOOLSDIR/config.forklog" ) ]]; then
  echo "No existing config.forklog file found.  Copied from config.forklog.template."
  echo "  forklog will function correctly with forktools defaults, but user may change defaults as desired in config.forklog ."
  cp $FORKTOOLSDIR/config.forklog.template $FORKTOOLSDIR/config.forklog
fi 
if [[ ( ! -f "$FORKTOOLSDIR/config.forkexplore" ) ]]; then
  echo "No existing config.forkexplore file found.  Copied from config.forkexplore.template."
  echo "  forkexplore will function correctly with forktools defaults, but user may change defaults as desired in config.forkexplore ."
  cp $FORKTOOLSDIR/config.forkexplore.template $FORKTOOLSDIR/config.forkexplore
fi 
if [[ ( ! -f "$FORKTOOLSDIR/config.forkfixconfig" ) ]]; then
  echo "No existing config.forkfixconfig file found.  Copied from config.forkfixconfig.template."
  echo "  forkfixconfig will function correctly with forktools defaults, but user may change defaults as desired in config.forkfixconfig ."
  cp $FORKTOOLSDIR/config.forkfixconfig.template $FORKTOOLSDIR/config.forkfixconfig
fi 
if [[ ( ! -f "$FORKTOOLSDIR/config.forkconfig" ) ]]; then
  echo "No existing config.forkconfig file found.  Copied from config.forkconfig.template."
  echo "  forkconfig will function correctly with forktools defaults, but user may change defaults as desired in config.forkconfig ."
  cp $FORKTOOLSDIR/config.forkconfig.template $FORKTOOLSDIR/config.forkconfig
fi 


echo "Making forktool scripts executable..."
cd $FORKTOOLSDIR
chmod +x fork*


echo "forktools installation completed!  I hope you'll enjoy.  - Qwinn"


