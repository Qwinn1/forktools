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
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/Olive-blockchain" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/olive-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/Olive-blockchain $FORKTOOLSBLOCKCHAINDIRS/olive-blockchain
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/sit-blockchain" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain $FORKTOOLSBLOCKCHAINDIRS/sit-blockchain
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

# Symlink creation for mainnet folder
if [[ ( -d "$FORKTOOLSHIDDENDIRS/.chinilla/vanillanet" ) && ( ! -d "$FORKTOOLSHIDDENDIRS/.chinilla/mainnet" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSHIDDENDIRS/.chinilla/vanillanet $FORKTOOLSHIDDENDIRS/.chinilla/mainnet
fi



# Symlink creation for code directories
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/sit" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/silicoin-blockchain/sit
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
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/flora-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/flora-blockchain/flora" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/flora-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/flora-blockchain/flora
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/bpx-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/bpx-blockchain/bpx" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/bpx-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/bpx-blockchain/bpx
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/gold-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/gold-blockchain/gold" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/gold-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/gold-blockchain/gold
fi
if [[ ( -d "$FORKTOOLSBLOCKCHAINDIRS/petroleum-blockchain/chia" ) && ( ! -d "$FORKTOOLSBLOCKCHAINDIRS/petroleum-blockchain/petroleum" ) ]]; then
  printf 'Created symlink: '
  ln -sv $FORKTOOLSBLOCKCHAINDIRS/petroleum-blockchain/chia $FORKTOOLSBLOCKCHAINDIRS/petroleum-blockchain/petroleum
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


