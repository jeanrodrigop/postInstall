#!/usr/bin/env bash
#
# mint-postinstall.sh - Install and configure programs for my personal use (linuxMint)
#
# Autor:         Jean Rodrigo
#
# ------------------------------------------------------------------------ #
#
# HOW TO USE?
#   $ ./mint-postinstall.sh
#
# ----------------------------- VARIABLES ----------------------------- #
set -e

##URLS

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
URL_ANYDESK="https://download.anydesk.com/linux/anydesk_6.2.0-1_amd64.deb"
URL_TEAMVIEWER="https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.33.7_amd64.deb"


##DIRECTORIES AND FILES

DOWNLOADS_DIRECTORY="./Programs"
NOSNAP="/etc/apt/preferences.d/nosnap.pref"
BASHRC="$HOME/.bashrc"


#COLORS

RED='\e[1;91m'
GREEN='\e[1;92m'
NO_COLOR='\e[0m'


#FUNCTIONS

# Update repositories and upgrade system

apt_update(){
  sudo apt update && sudo apt dist-upgrade -y
}

# -------------------------------------------------------------------------------- #
# -----------------------------TESTS AND REQUIREMENTS----------------------------- #

# Internet test
tests_internet(){
if ! ping -c 1 1.1.1.1 -q &> /dev/null; then
  echo -e "${RED}[ERROR] - Your computer does not have an Internet connection. Check the network.${NO_COLOR}"
  exit 1
else
  echo -e "${GREEN}[INFO] - Internet connection ok!${NO_COLOR}"
fi
}

# ------------------------------------------------------------------------------ #

## Adding/Confirming 32-bit architecture ##
add_archi386(){
sudo dpkg --add-architecture i386
}
## Updating repositories ##
just_apt_update(){
sudo apt update -y
}
## Linux Mint Snap permission ##
mint_snap(){
#sudo rm /etc/apt/preferences.d/nosnap.pref
#reboot
#
if [ -f "$NOSNAP" ] ; then
    rm "$NOSNAP"
    sudo reboot
else
    echo -e "${GREEN}[NOSNAP REMOVED]${NO_COLOR}" 
fi
}
## Removing LibreOffice ##
remove_office(){
sudo apt remove --purge libreoffice* -y
}

##DEB SOFTWARES TO INSTALL

PROGRAMS_TO_INSTALL=(
  
  gparted
  timeshift
  git
  wget
  curl
  ubuntu-restricted-extras
  mint-meta-codecs
  htop
  neofetch
  gdebi
  gdebi-core 
  rar
  unrar 
  p7zip-full
  p7zip-rar
  gzip
  #virtualbox
  snapd
  ttf-mscorefonts-installer 
  
)

# ---------------------------------------------------------------------- #

## Downloading and installing external programs ##

install_debs(){

echo -e "${GREEN}[INFO] - Downloading .deb packages${NO_COLOR}"

mkdir $DOWNLOADS_DIRECTORY
wget -c "$URL_GOOGLE_CHROME"       -P "$DOWNLOADS_DIRECTORY"
wget -c "$URL_ANYDESK"             -P "$DOWNLOADS_DIRECTORY"
wget -c "$URL_TEAMVIEWER"          -P "$DOWNLOADS_DIRECTORY"

## Installing downloaded packages .deb in latest session ##
echo -e "${GREEN}[INFO] - Installing downloaded packages .deb${NO_COLOR}"
sudo dpkg -i $DOWNLOADS_DIRECTORY/*.deb

# Installing programs from apt
echo -e "${GREEN}[INFO] - Installing programs from repositories${NO_COLOR}"

for program_name in ${PROGRAMS_TO_INSTALL[@]}; do
  sudo apt install "$program_name" -y
done

}
## Installing Flatpak packages ##
install_flatpaks(){

  echo -e "${GREEN}[INFO] - Installing flatpak packages${NO_COLOR}"

#flatpak install flathub org.onlyoffice.desktopeditors -y
flatpak install flathub org.qbittorrent.qBittorrent -y
flatpak install flathub org.flameshot.Flameshot -y
#flatpak install flathub com.raggesilver.BlackBox -y
#flatpak install flathub ro.fxdata.taskmonitor.viewer
}

## Installing Snap packages ##

install_snaps(){

echo -e "${GREEN}[INFO] - Installing snap packages${NO_COLOR}"

sudo snap install code --classic
sudo snap install snap-store
#sudo snap install multipass

}


# -------------------------------------------------------------------------- #
# ------------------------------ POST-INSTALL ------------------------------ #


## Finalizing, updating and cleaning ##

system_clean(){

apt_update -y
flatpak update -y
sudo apt clean -y
sudo apt autoclean -y
sudo apt autoremove -y
}


# -------------------------------------------------------------------------- #
# ----------------------------- EXTRA CONFIGS ------------------------------ #

extra_config(){
#Creating aliases in ~/.bashrc file
sudo echo "alias updf='sudo apt update && sudo apt full-upgrade -y'" >> ../.bashrc
sudo echo "alias updc='sudo apt-get autoclean -y && sudo apt-get clean -y && sudo apt-get autoremove -y'" >> ../.bashrc

#Changing current swappiness value 
sudo echo "vm.swappiness=10"  >> /etc/sysctl.conf

#Extra config
sudo dpkg-reconfigure gparted git
sudo fc-cache -f -v

source $BASHRC
}

# -------------------------------------------------------------------------- #
# -------------------------- CHECK INSTALLED APPS -------------------------- #

check_apps(){
#Clear screen
clear

#Check installed APT programs
echo -e "${GREEN}[INFO] - Checking installed repositories packages${NO_COLOR}"
for program_name in ${PROGRAMS_TO_INSTALL[@]}; do
  if ! dpkg -l | grep -q $program_name; then 
    echo "[NOT INSTALLED] - $program_name"
  else
    echo "[INSTALLED] - $program_name"
  fi
done
}

# -------------------------------------------------------------------------------- #
# ------------------------------- RUNNING ---------------------------------------- #

mint_snap
tests_internet
apt_update
add_archi386
remove_office
just_apt_update
install_debs
install_flatpaks
install_snaps
apt_update
system_clean
extra_config
check_apps

## finalização

  echo -e "${GREEN}[INFO] - Script finished, installation complete! :)${NO_COLOR}"
  echo -e "${GREEN}[INFO] - Restart the system!${NO_COLOR}"