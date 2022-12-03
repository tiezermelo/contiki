#!/bin/bash
BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# Clone RPL framework repository
echo -e "${BLUE}\nClone RPL framework repository${NC}"
cd $HOME
#git clone https://github.com/dhondta/rpl-attacks.git


# Clone MQTT Malaria repository
echo -e "${BLUE}\nClone MQTT Malaria repository${NC}"
cd $HOME
git clone https://github.com/etactica/mqtt-malaria.git


# Clone IoT-Flock repository
echo -e "${BLUE}\nClone IoT-Flock repository${NC}"
cd $HOME
git clone https://github.com/ThingzDefense/IoT-Flock.git


wget https://bootstrap.pypa.io/get/pip.py 
# curl https://bootstrap.pypa.io/get/pip.py --output get-pip.py
python3 get-pip.py
python3 -m pip install --upgrade pip


echo -e "${BLUE}\nUpdate default python3 version to python-3.8${NC}"
cd $HOME/rpl-attacks
echo -e "\n${RED}${pwd}\n${NC}"

python3 -m pip install --upgrade setuptools coapthon wheel
python3 -m pip install -r requirements
pip3 uninstall fabric 
pip3 uninstall fabric3 


# Download and install qt
# https://web.stanford.edu/dept/cs_edu/resources/qt/install-linux
echo -e "${BLUE}\nDownload qt version 5.12.3${NC}"
wget https://download.qt.io/archive/qt/5.12/5.12.3/qt-opensource-linux-x64-5.12.3.run 
chmod +x qt-opensource-linux-x64-5.12.3.run 
./qt-opensource-linux-x64-5.12.3.run



exit;



#####################################3

# UPDATE SYSTEM
sudo apt update


# Config RPL Attacks Framework

# Install RPL framework dependencies
echo -e "${BLUE}\nInstall RPL framework dependencies${NC}"
tmp=$(python3 --version)
if ! echo "$tmp" | grep -q "3.8"; 
then

add-apt-repository ppa:deadsnakes/ppa 
apt update 
apt-get install -y python3.8 python3.8-dev python3.8-distutils software-properties-common 


else

apt-get install -y python3 python3-dev python3-distutils software-properties-common 
# wget https://bootstrap.pypa.io/get/pip.py 
# # curl https://bootstrap.pypa.io/get/pip.py --output get-pip.py
# python3 get-pip.py

fi

exit;

# update default python3 version to python-3.8
echo -e "${BLUE}\nUpdate default python3 version to python-3.8${NC}"
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
tmp=$(echo "0" | update-alternatives --config python3  | grep 3.8 | cut -c3 )
echo "$tmp\n" | update-alternatives --config python3

echo -e "\n${RED}${python3 -version}\n${NC}"


# echo -e "${BLUE}\nUpdate default python3 version to python-3.8${NC}"
# cd $HOME/rpl-attacks
# echo -e "\n${RED}${pwd}\n${NC}"

# python3 -m pip install --upgrade setuptools coapthon wheel
# python3 -m pip install -r requirements
# pip3 uninstall fabric 
# pip3 uninstall fabric3 

# run rpl-framework 
# python3.8 main.py

echo -e "${YELLOW}\nEnd RPL Framework configuration${NC}"

# Configuring MQTT Malaria tool

echo -e "${BLUE}\nInstall MQTT Malaria dependencies${NC}"
apt-get install python2.7 python2.7-dev python2.7-distutils wget
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2.7 get-pip.py
python2 -m pip install --upgrade pip

# tmp=$(python2.7 --version)
# if ! echo "$tmp" | grep -q "2.7"; 
# then

# apt-get install python2.7 python2.7-dev python2.7-distutils wget
# wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
# python2.7 get-pip.py
# python2 -m pip install --upgrade pip

# else

# apt-get install -y python3 python3-dev python3-distutils software-properties-common 
# wget https://bootstrap.pypa.io/get/pip.py 
# # curl https://bootstrap.pypa.io/get/pip.py --output get-pip.py
# python3 get-pip.py

# fi

# update default python2 version to python-2.7
echo -e "${BLUE}\nUpdate default python2 version to python-2.7${NC}"
update-alternatives --install /usr/bin/python2 python2 /usr/bin/python2.7 1
tmp=$(echo "0" | update-alternatives --config python2  | grep 2.7 | cut -c3 )
echo "$tmp\n" | update-alternatives --config python2

echo -e "\n${RED}${python2 -version}\n${NC}"

echo -e "${BLUE}\nChange runner from python to python2${NC}"
cd $HOME/mqtt-malaria
# edit runner to python2
sed -i "s/python/python2/g" malaria 

# MQTT Malaria help
# ./malaria -h

# run MQTT Malaria
# ./malaria publish -t -n 100 -P 10 -T 5

echo -e "${YELLOW}\nEnd MQTT Malaria configuration${NC}"


# Configuring IoT-Flock tool

echo -e "${BLUE}\nInstall IoT-Flock dependencies${NC}"
# Install Iot-Flock dependencies
# Removed from list: qt5-default wireshark
# Error libqtsql.so.5 install libqt5sql5 deb package
sudo apt-get install -y libtins-dev libpcoap-dev libssl-dev cmake libboost-all-dev mesa-utils freeglut3-dev sqlite libqt5sql5
python2 -m pip install -y CoAPthon
# python3 -m pip install CoAPthon

# # Download and install qt
# # https://web.stanford.edu/dept/cs_edu/resources/qt/install-linux
# echo -e "${BLUE}\nDownload qt version 5.12.3${NC}"
# wget https://download.qt.io/archive/qt/5.12/5.12.3/qt-opensource-linux-x64-5.12.3.run 
# chmod +x qt-opensource-linux-x64-5.12.3.run 
# ./qt-opensource-linux-x64-5.12.3.run

# install qt
# open qt and build the project
# copy db2 to folder build
# Run IoT-Flock GUI to make the simulation
# Run IoT-Flock Console to run the simulation
# Use wireshark to capture the traffic


# Clean dependencies 
apt autoremove -y