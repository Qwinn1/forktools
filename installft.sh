#! /usr/bin/env bash

echo "Installing forktools..."

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

echo "Setting up environment variables in .bashrc..."
# Removes all FORKTOOLS related lines from .bashrc
sed -i '/FORKTOOLS/d' "$HOME/.bashrc"

FORKTOOLDSDIR=$PWD

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

echo "export FORKTOOLSDIR=$FORKTOOLSDIR" >> "$HOME/.bashrc"
echo "export FORKTOOLSBLOCKCHAINDIRS=$FORKTOOLSBLOCKCHAINDIRS" >> "$HOME/.bashrc"
echo "export FORKTOOLSHIDDENDIRS=$FORKTOOLSHIDDENDIRS" >> "$HOME/.bashrc"
echo 'export PATH=$PATH:$FORKTOOLSDIR' >> "$HOME/.bashrc"
source $HOME/.bashrc

echo "Scanning for and setting up required symlinks for forks with non-standard paths..."

# Symlink creation for -blockchain dirs
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/doge-chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/dogechia-blockchain" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSBLOCKCHAINDIRS/doge-chia -> $FORKTOOLSBLOCKCHAINDIRS/dogechia-blockchain"
  ln -s $FORKTOOLSBLOCKCHAINDIRS/doge-chia $FORKTOOLSBLOCKCHAINDIRS/dogechia-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/littlelambocoin" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/littlelambocoin-blockchain" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin -> $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin-blockchain"
  ln -s $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin $FORKTOOLSBLOCKCHAINDIRS/littlelambocoin-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/cryptodoge" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/cryptodoge-blockchain" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSBLOCKCHAINDIRS/cryptodoge -> $FORKTOOLSBLOCKCHAINDIRS/cryptodoge-blockchain"
  ln -s $FORKTOOLSBLOCKCHAINDIRS/cryptodoge $FORKTOOLSBLOCKCHAINDIRS/cryptodoge-blockchain
fi

# Symlink creation for .hidden dirs
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.spare-blockchain" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.spare" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSHIDDENDIRS/.spare-blockchain -> $FORKTOOLSBLOCKCHAINDIRS/.spare"
  ln -s $FORKTOOLSHIDDENDIRS/.spare-blockchain $FORKTOOLSHIDDENDIRS/.spare
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.goji-blockchain" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.goji" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSHIDDENDIRS/.goji-blockchain -> $FORKTOOLSBLOCKCHAINDIRS/.goji"
  ln -s $FORKTOOLSHIDDENDIRS/.goji-blockchain $FORKTOOLSHIDDENDIRS/.goji
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.seno2" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.seno" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSHIDDENDIRS/.seno2 -> $FORKTOOLSBLOCKCHAINDIRS/.seno"
  ln -s $FORKTOOLSHIDDENDIRS/.seno2 $FORKTOOLSHIDDENDIRS/.seno
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.beernetwork" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.beer" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSHIDDENDIRS/.beernetwork -> $FORKTOOLSBLOCKCHAINDIRS/.beer"
  ln -s $FORKTOOLSHIDDENDIRS/.beernetwork $FORKTOOLSHIDDENDIRS/.beer
fi
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.venidium/kition" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.venidium/mainnet" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSHIDDENDIRS/.venidium/kition -> $FORKTOOLSBLOCKCHAINDIRS/.venidium/mainnet"
  ln -s $FORKTOOLSHIDDENDIRS/.venidium/kition $FORKTOOLSHIDDENDIRS/.venidium/mainnet
fi

# Symlink creation for submodules
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/silicoin" ) ]]; then
  echo "Creating symlink:  $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia -> $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/silicoin"
  ln -s $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/silicoin
fi

