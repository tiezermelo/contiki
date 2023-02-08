#!/bin/bash
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m'

# CONFIGURATION STEPS
# 1. Install git: apt-get install git

# 2. Clone git repository. 

# Original Contiki repository
# git clone  https://github.com/contiki-os/contiki.git

# Git clone by https
# git clone https://github.com/tiezermelo/contiki.git

# Git clone by ssh
# git clone git@github.com:tiezermelo/contiki.git

# Install Contiki dependencies
# Packages removed from command below:  gdb-arm-none-eabi binutils-msp430 gcc-msp430 msp430-libc msp430mcu mspdebu


function update_mspsim_submodule(){
    git submodule update --init $CONTIKI_PATH/tools/mspsim/
}

function create_branch() {
    git checkout -b $attack
    echo -e "${YELLOW}\n\nCurrent branch: \n"
    git branch
    echo -e "${NC}\n"
}

function backup_original_rpl_files(){
    cp $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c    $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-icmp6-bkp.c
    cp $CONTIKI_PATH/core/net/rpl/rpl-private.h  $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-private-bkp.h
    cp $CONTIKI_PATH/core/net/rpl/rpl-timers.c   $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-timers-bkp.c
}

function copy_files_malicious_motes(){
    cp $CONTIKI_PATH/utils/malicious_motes/${attack}/coap-${attack}.c $CONTIKI_PATH/examples/coap/coap-${attack}.c
    cp $CONTIKI_PATH/utils/malicious_motes/${attack}/mqtt-${attack}.c $CONTIKI_PATH/examples/mqtt/mqtt-${attack}.c
}


# Version Number Attack Configuration
function copy_malicious_mote_version-number(){
    cp $CONTIKI_PATH/examples/mqtt/mqtt-client.c $CONTIKI_PATH/examples/mqtt/mqtt-version-number.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION||g" $CONTIKI_PATH/examples/mqtt/mqtt-version-number.c

    cp $CONTIKI_PATH/examples/coap/coap-client.c $CONTIKI_PATH/examples/coap/coap-version-number.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION||g" $CONTIKI_PATH/examples/coap/coap-version-number.c
}


# Hello Flood Attack Configuration
function copy_malicious_mote_hello-flood(){
    cp $CONTIKI_PATH/examples/mqtt/mqtt-client.c $CONTIKI_PATH/examples/mqtt/mqtt-hello-flood.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION|/* Enable hello flood attack*/ \n#define RPL_CONF_DIS_INTERVAL	 	    0 \n#define RPL_CONF_DIS_START_DELAY	  0 \n/* End of attack */|g" $CONTIKI_PATH/examples/mqtt/mqtt-hello-flood.c

    cp $CONTIKI_PATH/examples/coap/coap-client.c $CONTIKI_PATH/examples/coap/coap-hello-flood.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION|/* Enable hello flood attack*/ \n#define RPL_CONF_DIS_INTERVAL	 	    0 \n#define RPL_CONF_DIS_START_DELAY	  0 \n/* End of attack */|g" $CONTIKI_PATH/examples/coap/coap-hello-flood.c
}


# Black Hole Attack Configuration
function copy_malicious_mote_black-hole(){
    cp $CONTIKI_PATH/examples/mqtt/mqtt-client.c $CONTIKI_PATH/examples/mqtt/mqtt-black-hole.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION|/* Enable black hole attack  */ \n#define RPL_CONF_MIN_HOPRANKINC 0 \n/* End of attack */|g" $CONTIKI_PATH/examples/mqtt/mqtt-black-hole.c

    cp $CONTIKI_PATH/examples/coap/coap-client.c $CONTIKI_PATH/examples/coap/coap-black-hole.c
    sed -i "s|//REPLACED_BY_ATTACK_CONFIGURATION|/* Enable black hole attack  */ \n#define RPL_CONF_MIN_HOPRANKINC 0 \n/* End of attack */|g" $CONTIKI_PATH/examples/coap/coap-black-hole.c
}



function build_rpl_border_router(){
    cd $CONTIKI_PATH/examples/ipv6/rpl-border-router/
    make TARGET=z1 border-router
}

function build_no_malicious_motes(){
    cd $CONTIKI_PATH/examples/mqtt
    make TARGET=wismote mqtt-client

    cd $CONTIKI_PATH/examples/coap
    make TARGET=z1 coap-client
    make TARGET=z1 coap-server
}

function copy_files_rpl_version-number() {
    cp $CONTIKI_PATH/utils/rpl/version-number/rpl-icmp6-version-number.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-private-bkp.h         $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-timers-bkp.c          $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_hello-flood() {
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-icmp6-bkp.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-private-bkp.h  $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/hello-flood/rpl-timers-hello-flood.c  $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_black-hole() {
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-icmp6-bkp.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/black-hole/rpl-private-black-hole.h   $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/black-hole/rpl-timers-black-hole.c    $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function build_malicious_motes(){
    cd $CONTIKI_PATH/examples/mqtt
    make TARGET=wismote mqtt-${attack}

    cd $CONTIKI_PATH/examples/coap
    make TARGET=z1 coap-${attack}
}

function restore_default_config(){
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-icmp6-bkp.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-private-bkp.h  $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/original_rpl_files/rpl-timers-bkp.c   $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function build_master_environment(){
    cd $CONTIKI_PATH
    git checkout master

    git config --global user.name $1
    git config --global user.email $2

    echo -e "${RED}\nBackup original RPL files${NC}"
    mkdir -p $CONTIKI_PATH/utils/rpl/original_rpl_files
    backup_original_rpl_files;
    
    echo -e "${RED}\nUpdate mspsim submodule${NC}"
    update_mspsim_submodule

    echo -e "${RED}\nBuild coap and mqtt motes (no malicious)${NC}"
    build_no_malicious_motes

    echo -e "${RED}\nBuild RPL border router${NC}"
    build_rpl_border_router

    cd $CONTIKI_PATH
    git add -f examples/coap/ examples/mqtt/ utils/rpl/original_rpl_files
    git commit -m "Master branch configured"
}



# Starting configuration

echo -e "${BLUE}\nStarting configuration${NC}"
export CONTIKI_PATH="$(echo -e $HOME)/contiki"


if ! grep -wq 'PATH:/opt/msp430-gcc/bin' $HOME/.profile 
then

cat >>  $HOME/.profile <<EOF
# Add msp43-gcc to path (contiki dependency)
PATH="\$PATH:/opt/msp430-gcc/bin"
EOF

source $HOME/.profile
echo -e "${RED}\nAdding msp430-gcc to PATH\n${NC}"

else
echo -e "${RED}\nMSP430-gcc already added to PATH\n{NC}"

fi


echo -e "${BLUE}\n\nConfiguring master environment ${NC}"
build_master_environment
exit;
attacks=("hello-flood" "version-number" "black-hole")

for attack in ${attacks[@]}; do
    echo -e "${BLUE}\n\nConfiguring $attack attack environment ${NC}"
    cd $CONTIKI_PATH
    git checkout master

    echo -e "${RED}\nCreate $attack branch${NC}"
    create_branch;
    
    echo -e "${RED}\nCopy malicious RPL files${NC}"
    copy_files_rpl_$attack;

    echo -e "${RED}\nCopy malicious mote files${NC}"
    # copy_files_malicious_motes;
    copy_malicious_mote_$attack;

    echo -e "${RED}\nBuild malicious motes${NC}"
    build_malicious_motes;

    echo -e "${RED}\nRestore original RPL configuration${NC}"  
    restore_default_config;

    cd $CONTIKI_PATH
    git add -f examples/coap/coap-${attack}.* examples/mqtt/mqtt-${attack}.* utils/rpl/original_rpl_files
    git commit -m "Configured $attack attack environment"

    echo -e "${YELLOW}\n\nFiles in coap directory: \n"
    ls $CONTIKI_PATH/examples/coap/
    echo -e "${NC}\n"
    
done

echo -e "${BLUE}\n\nSwitch to master branch${NC}"
cd $CONTIKI_PATH
git checkout master
exit;
