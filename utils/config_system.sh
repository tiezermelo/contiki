#!/bin/bash


cd ~/

# Original Contiki repository
# git clone  https://github.com/contiki-os/contiki.git

git clone https://github.com/tiezermelo/contiki.git

export CONTIKI_PATH='~/contiki/'

git submodule update --init $CONTIKI_PATH/tools/mspsim/

attacks=("hello-flood" "version-number" "black-hole")

for attack in ${attacks[@]}; do
    echo $attack 
    create_branch()
    backup_original_rpl_files()
    build_rpl_border_router()
    build_no_malicious_motes()
    copy_files_rpl_${attack}()
    copy_files_malicious_motes()
    build_malicious_motes()
    restore_default_config()
done

function create_branch() {
    cd $CONTIKI_PATH
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

build_rpl_border_router(){
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

function copy_files_rpl_version_number() {
    cp $CONTIKI_PATH/utils/rpl/rpl-icmp6-versionnumber.c  $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/rpl-private-bkp.h          $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/rpl-timers-bkp.c           $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_hello_flood() {
    cp $CONTIKI_PATH/utils/rpl/rpl-icmp6-bkp.c          $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/rpl-private-bkp.h        $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/rpl-timers-helloflood.c  $CONTIKI_PATH/core/net/rpl/rpl-timers.c
}

function copy_files_rpl_black_hole() {
    cp $CONTIKI_PATH/utils/rpl/rpl-icmp6-bkp.c           $CONTIKI_PATH/core/net/rpl/rpl-icmp6.c
    cp $CONTIKI_PATH/utils/rpl/rpl-private-blackhole.h   $CONTIKI_PATH/core/net/rpl/rpl-private.h
    cp $CONTIKI_PATH/utils/rpl/rpl-timers-blackhole.c    $CONTIKI_PATH/core/net/rpl/rpl-timers.c
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



# function copy_files_attacks_rpl(){
#     cp $CONTIKI_PATH/utils/rpl/master/rpl-icmp6-versionnumber.c  $CONTIKI_PATH/core/net/rpl/rpl-icmp6-versionnumber.c
#     cp $CONTIKI_PATH/utils/rpl/master/rpl-timers-helloflood.c    $CONTIKI_PATH/core/net/rpl/rpl-timers-helloflood.c
#     cp $CONTIKI_PATH/utils/rpl/master/rpl-timers-blackhole.c     $CONTIKI_PATH/core/net/rpl/rpl-timers-blackhole.c
#     cp $CONTIKI_PATH/utils/rpl/master/rpl-private-blackhole.h    $CONTIKI_PATH/core/net/rpl/rpl-private-blackhole.h
# }