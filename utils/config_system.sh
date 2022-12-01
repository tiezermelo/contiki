#!/bin/bash
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m' # No Color

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

    echo -e "${RED}\nBackup original RPL files${NC}"
    mkdir -p $CONTIKI_PATH/utils/rpl/original_rpl_files
    backup_original_rpl_files;
    
    echo -e "${RED}\nUpdate mspsim submodule${NC}"
    update_mspsim_submodule

    echo -e "${RED}\nBuild coap and mqtt motes (no malicious)${NC}"
    build_no_malicious_motes

    echo -e "${RED}\nBuild RPL border router${NC}"
    build_rpl_border_router

}



# Starting configuration

echo -e "${BLUE}\nStarting configuration${NC}"
export CONTIKI_PATH="$(echo -e $HOME)/contiki"


#home_path=$(echo -e $HOME)
# cat >> $(echo -e $HOME)/.profile <<EOF
# PATH="\$PATH:/opt/msp430-gcc/bin"
# EOF

# source $HOME/.profile

echo -e "${BLUE}\n\nConfiguring master environment ${NC}"
build_master_environment

# attacks=("hello-flood" "version-number" "black-hole")

attacks=("hello-flood")
for attack in ${attacks[@]}; do
    echo -e "${BLUE}\n\nConfiguring $attack attack environment ${NC}"
    cd $CONTIKI_PATH

    echo -e "${RED}\nCreate $attack branch${NC}"
    create_branch;
    
    echo -e "${RED}\nCopy malicious RPL files${NC}"
    copy_files_rpl_$attack;

    echo -e "${RED}\nCopy malicious mote files${NC}"
    copy_files_malicious_motes;

    echo -e "${RED}\nBuild malicious motes${NC}"
    build_malicious_motes;

    echo -e "${RED}\nRestore original RPL configuration${NC}"  
    restore_default_config; 
done

echo -e "${BLUE}\n\nSwitch to master branch${NC}"
cd $CONTIKI_PATH
git checkout master
exit;
