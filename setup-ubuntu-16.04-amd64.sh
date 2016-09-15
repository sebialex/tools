#!/bin/bash

REFRESH_RATE=60
RESOLUTIONS="1920x1080"
FORCE=

chmod +x ./*.sh

if [ -d target ]; then
   rm -rf target 
fi

mkdir target

# Create .bash_profile if it does not exist, and source .bashrc in  it
if [ ! -f ~/.bash_profile ] || [ -z "$(cat ~/.bash_profile | grep bashrc | cat)" ]; then
   echo >> ~/.bash_profile
   echo "source ~/.bashrc" >> ~/.bash_profile
fi

# Appends a line to the end of the ~/.bashrc file to export a key and its value
#  if the key is already present it won't be appended again
function export_to_bashrc {
   local key=$1
   local value=$2
   
   local result=`cat ~/.bashrc | grep "$key=" | cat`

   if [ -z "$result" ]; then
      echo >> ~/.bashrc
      echo "export $key=$value" >> ~/.bashrc
   fi
}

function add_to_path {
   local key=$1
   
   local result=`cat ~/.bashrc | grep "PATH" | grep $key | cat`
   if [ -z "$result" ]; then
      echo >> ~/.bashrc
      echo "export PATH=\$PATH:\$$key" >> ~/.bashrc
   fi
}


./apt-update.sh

sudo apt-get upgrade -y
sudo apt-get install -y apt apt-transport-https ca-certificates

# Docker
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Sources
echo; echo "Copying bash aliases"; echo 
sudo cp -f my-sources.list /etc/apt/sources.list.d/


sudo apt update

# Install tools
sudo apt install -y git vim tree htop traceroute terminator shellcheck gpg2
sudo apt install -y chromium-browser gitkraken shutter konsole krusader ffmpeg gtk-recordmydesktop
sudo apt install -y postgresql postgresql-contrib postgresql-client pgadmin3
sudo apt install -y python-pip build-essential libssl-dev python2.7-dev libxml2-dev libxslt1-dev

# Docker 
sudo apt-get purge lxc-docker
apt-cache policy docker-engine
sudo apt install -y docker-engine


# Install Java
sudo apt-get install -y openjdk-8-jdk
export_to_bashrc "JAVA_HOME" "/usr/lib/jvm/java-8-openjdk-amd64"
add_to_path "JAVA_HOME/bin"

# Install Maven
sudo apt install -y maven
export_to_bashrc "MAVEN_OPTS" "\"-Xmx2g -XX:MaxPermSize=256m\""
export_to_bashrc "M2_HOME" "/usr/share/maven"
add_to_path "M2_HOME/bin"

# PostgreSQL
#echo "\password postgres" | sudo -u postgres psql postgres
#sudo -u postgres createdb sonarqube

# Install NodeJS
if [ -z $(node --version | grep "^v[0-9]*" | cat) ] || [ "$FORCE" ]; then
   curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
   sudo apt install -y nodejs
   sudo apt-get install -y build-essential
else
   echo "Node already installed: $(node --version)"
fi

# Install Microsoft Code
if [ -z $(code --version | grep "^[0-9]*" | cat) ] || [ "$FORCE" ]; then
   cd target 
   MS_CODE_DIR=ms-code
   MS_CODE_URL=https://go.microsoft.com/fwlink/?LinkID=760868

   mkdir $MS_CODE_DIR
   cd $MS_CODE_DIR
   wget -O code.deb $MS_CODE_URL 
   sudo dpkg -i code.deb
   sudo apt-get install -f -y
   cd ..
   rm -rf $MS_CODE_DIR
   cd ..
else
   echo "MS Code already installed: $(code --version)"
fi

# Add resolutions if they do not exist, mostly for VMs
for resolution in $RESOLUTIONS
do    
    echo "Attemtping to add resolution: $resolution" 
    if [ -z "$(xrandr -q | grep $resolution | cat)" ]; then
        WIDTH=`echo $resolution | cut -d'x' -f1`
        HEIGHT=`echo $resolution | cut -d'x' -f2`
        NEW_MODE=`sudo cvt $WIDTH $HEIGHT $REFRESH_RATE | grep Modeline | sed -e "s/^Modeline //"`
        sudo xrandr --newmode $NEW_MODE
        DEVICE_NAME=`sudo xrandr -q | grep "connected primary" | cut -d' ' -f1`
        sudo xrandr --addmode $DEVICE_NAME $WIDTHx$HEIGHT_$REFRESH_RATE.00
    else
        echo "Resolution $resolution already present, will not add."
    fi
done

# Fingerprint
#sudo add-apt-repository ppa:fingerprint/fprint
#sudo apt-get update
#sudo apt-get upgrade -y
#sudo echo | apt-get install -y libfprint0 fprint-demo libpam-fprintd

# Set up DNS
RESOLV_CONF_FILE=/etc/resolvconf/resolv.conf.d/base
if [ ! -f $RESOLV_CONF_FILE ] || [ -z "$(cat $RESOLV_CONF_FILE | grep "8.8.8.8" | cat)" ]; then  
   echo "nameserver 8.8.8.8" | sudo tee $RESOLV_CONF_FILE > /dev/null
fi


# Aliases
echo; echo "Copying bash aliases"; echo 
cp -f bash_aliases ~/.bash_aliases

# Remove stuff
echo; echo "Removing stuff"; echo
sudo apt-get remove -y --purge libreoffice* > /dev/null
sudo apt-get clean
sudo apt-get autoremove -y

rm -rf target

