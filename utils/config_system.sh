#!/bin/bash


# cd ~/

# Original Contiki repository
# git clone  https://github.com/contiki-os/contiki.git

# Git clone by https
# git clone https://github.com/tiezermelo/contiki.git

# Git clone by ssh
# git clone git@github.com:tiezermelo/contiki.git


export CONTIKI_PATH=$(pwd) #'~/contiki'

function update_mspsim_submodule(){
    git submodule update --init $CONTIKI_PATH/tools/mspsim/
}

function create_branch() {
    git checkout -b $attack
}

function backup_original_rpl_files(){
    cp $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6-bkp.c
    cp $CONTIKI_PATH/core/net/rpl/rpl-private.h  $CONTIKI_PATH/core/net/rpl/rpl-private-bkp.h
    cp $CONTIKI_PATH/core/net/rpl/rpl-timers.c   $CONTIKI_PATH/core/net/rpl/rpl-timers-bkp.c
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
    cp $CONTIKI_PATH/utils/rpl/rpl-icmp6-version-number.c  $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/rpl-private-bkp.h           $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/rpl-timers-bkp.c            $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_hello-flood() {
    cp $CONTIKI_PATH/core/net/rpl/rpl-icmp6-bkp.c           $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/core/net/rpl/rpl-private-bkp.h         $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/hello-flood/rpl-timers-hello-flood.c  $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_black-hole() {
    cp $CONTIKI_PATH/utils/rpl/rpl-icmp6-bkp.c            $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/rpl-private-black-hole.h   $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/rpl-timers-black-hole.c    $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function build_malicious_motes(){
    cd $CONTIKI_PATH/examples/mqtt
    make TARGET=wismote mqtt-${attack}

    cd $CONTIKI_PATH/examples/coap
    make TARGET=z1 coap-${attack}
}

function restore_default_config(){
    cp $CONTIKI_PATH/core/net/rpl/rpl-icmp6-bkp.c    $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/core/net/rpl/rpl-private-bkp.h  $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/core/net/rpl/rpl-timers-bkp.c   $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

attacks=("hello-flood" "version-number" "black-hole")

for attack in ${attacks[@]}; do
    echo $attack
    cd $CONTIKI_PATH

    update_mspsim_submodule 
    create_branch; # git branch; exit;
    backup_original_rpl_files; # ls $CONTIKI_PATH/core/net/rpl/ | grep bkp; exit;
    build_rpl_border_router;  # ls $CONTIKI_PATH/examples/ipv6/rpl-border-router/ | grep z1; exit;
    build_no_malicious_motes; # ls $CONTIKI_PATH/examples/coap/ | grep z1;  ls $CONTIKI_PATH/examples/mqtt/ | grep  wismote; exit;
    copy_files_rpl_$attack;  # cat $CONTIKI_PATH/core/net/rpl/rpl-timers.c | grep attack; exit;
    copy_files_malicious_motes;  # ls $CONTIKI_PATH/examples/coap/;  ls $CONTIKI_PATH/examples/mqtt/; exit;
    build_malicious_motes;  # ls $CONTIKI_PATH/examples/coap/ | grep z1;  ls $CONTIKI_PATH/examples/mqtt/ | grep  wismote; exit;
    restore_default_config; # cat $CONTIKI_PATH/core/net/rpl/rpl-timers.c | grep attack; exit;
done
