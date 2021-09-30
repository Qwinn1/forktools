if [[ $FTERRORSTOFILE == 'Yes' ]]; then
  exec 2>&3  #Restore stderr destination
fi
exit

