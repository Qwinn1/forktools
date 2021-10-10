#! /usr/bin/env bash

if [[ $OSTYPE == 'darwin'* ]]; then
  ENVFILE="$HOME/.bash_profile"
else
  ENVFILE="$HOME/.bashrc"
fi

echo "Setting up environment variables in $ENVFILE"
# Removes all FORKTOOLS related lines from bash startup file
sed "-i.bak" '/FORKTOOLS/d' "$ENVFILE"

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

. $FORKTOOLSDIR/ftsymlinks.sh

echo "Moving any config files in forktools folder to forktools/ftconfigs folder."
mv $FORKTOOLSDIR/config.* $FORKTOOLSDIR/ftconfigs

echo "Copying config.FORKTOOL.template files to config.FORKTOOL if necessary..."
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forkstartall" ) ]]; then
  echo "No existing config.forkstartall file found.  Copied from config.forkstartall.template."
  echo "  WARNING:  forkstartall will not function until config.forkstartall is manually configured."
  cp $FORKTOOLSDIR/ftconfigs/config.forkstartall.template $FORKTOOLSDIR/ftconfigs/config.forkstartall
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forkaddplotdirs" ) ]]; then
  echo "No existing config.forkaddplotdirs file found.  Copied from config.forkaddplotdirs.template."
  echo "  WARNING:  forkaddplotdirs will not function until config.forkaddplotdirs is manually configured."
  cp $FORKTOOLSDIR/ftconfigs/config.forkaddplotdirs.template $FORKTOOLSDIR/ftconfigs/config.forkaddplotdirs
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forklog" ) ]]; then
  echo "No existing config.forklog file found.  Copied from config.forklog.template."
  echo "  forklog will function correctly with forktools defaults, but user may change defaults as desired in config.forklog ."
  cp $FORKTOOLSDIR/ftconfigs/config.forklog.template $FORKTOOLSDIR/ftconfigs/config.forklog
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forkexplore" ) ]]; then
  echo "No existing config.forkexplore file found.  Copied from config.forkexplore.template."
  echo "  forkexplore will function correctly with forktools defaults, but user may change defaults as desired in config.forkexplore ."
  cp $FORKTOOLSDIR/ftconfigs/config.forkexplore.template $FORKTOOLSDIR/ftconfigs/config.forkexplore
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forkfixconfig" ) ]]; then
  echo "No existing config.forkfixconfig file found.  Copied from config.forkfixconfig.template."
  echo "  forkfixconfig will function correctly with forktools defaults, but user may change defaults as desired in config.forkfixconfig ."
  cp $FORKTOOLSDIR/ftconfigs/config.forkfixconfig.template $FORKTOOLSDIR/ftconfigs/config.forkfixconfig
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.forkedit" ) ]]; then
  echo "No existing config.forkedit file found.  Copied from config.forkedit.template."
  echo "  forkedit will use gedit as the text editor by default, but this can be changed to your preferred editor in config.forkedit."
  cp $FORKTOOLSDIR/ftconfigs/config.forkedit.template $FORKTOOLSDIR/ftconfigs/config.forkedit
fi 
if [[ ( ! -f "$FORKTOOLSDIR/ftconfigs/config.logging" ) ]]; then
  echo "No existing config.logging file found.  Copied from config.logging.template."
  echo "  Only forkmon logging is enabled by default.  Update config.logging to enable logs for any or every forktool (except forkconfig)."
  cp $FORKTOOLSDIR/ftconfigs/config.logging.template $FORKTOOLSDIR/ftconfigs/config.logging
fi 


echo "Making forktool scripts executable..."
cd $FORKTOOLSDIR
chmod +x fork*


echo "forktools installation completed!  I hope you'll enjoy.  - Qwinn"


