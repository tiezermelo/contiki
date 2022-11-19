apt-get install -y build-essential gcc-arm-none-eabi openjdk-8-jdk openjdk-8-jre ant libncurses5-dev:i386 libncurses5:i386

export CONTIKI_PATH="$(echo -e $HOME)/contiki"

cat /home/osboxes/contiki/utils/msp430-gcc/msp430* > /opt/msp430-gcc-4.7.0.tar.gz
tar -xvf /opt/msp430-gcc-4.7.0.tar.gz -C /opt/
mv /opt/msp430-gcc-4.7.0 /opt/msp430-gcc
chmod 770 /opt/msp430-gcc
# need to do chmod on /opt/msp430-gcc
# try to change the path
