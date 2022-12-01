# Install Contiki dependencies
# Packages removed from command below:  gdb-arm-none-eabi binutils-msp430 gcc-msp430 msp430-libc msp430mcu mspdebu
apt-get install -y build-essential gcc-arm-none-eabi openjdk-8-jdk openjdk-8-jre ant libncurses5-dev:i386 libncurses5:i386 zlib1g:i386 net-tools 

DEBIAN_FRONTEND=noninteractive apt-get -y -q install wireshark

# export CONTIKI_PATH="$(echo -e $HOME)/contiki"
export CONTIKI_PATH="$(pwd)"

cat $CONTIKI_PATH/utils/msp430-gcc/msp430* > /opt/msp430-gcc-4.7.0.tar.gz
tar -xvf /opt/msp430-gcc-4.7.0.tar.gz -C /opt/
mv /opt/msp430-gcc-4.7.0 /opt/msp430-gcc
chmod 770 /opt/msp430-gcc
rm /opt/msp430-gcc-4.7.0.tar.gz

# update default java version to java8
tmp=$(echo $(echo -e '0' | sudo update-alternatives --config java | grep java-8 | cut -c 3))
echo -e "$tmp\n" | sudo update-alternatives --config java
java -version

