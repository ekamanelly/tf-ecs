#!/bin/bash 

echo "Installing tfswitch locally"
wget https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh  #Get the installer on to your machine

chmod 755 install.sh #Make installer executable

./install.sh -b `pwd`/.bin      #Install tfswitch in a location you have permission

CUSTOMBIN=`pwd`/.bin            #set custom bin path

export PATH=$PATH:$CUSTOMBIN    #Add custom bin path to PATH environment

$CUSTOMBIN/tfswitch -b $CUSTOMBIN/terraform 1.2.6 #or simply tfswitch -b $CUSTOMBIN/terraform 0.11.7

terraform $*                   # pass argument to terraform "init"
