#!/usr/bin/env bash
## ---------------------------------------------------------------------- ##
##  postinstall.sh - Personal script for automate linux post installation 
##  Autor: Jean Rodrigo
## ---------------------------------------------------------------------- ##
##  HOW TO USE?
##  $ ./postinstall.sh
## ----------------------------- VARIABLES ------------------------------ ##
set -e

##URLS

URL_GOOGLE_CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"


##DIRECTORIES AND FILES
DOWNLOADS_DIRECTORY="./Programs"
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
## Removing occasional locks from apt ##
apt_locks(){
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
}
## Adding/Confirming 32-bit architecture ##
add_archi386(){
sudo dpkg --add-architecture i386
}
## Updating repositories ##
just_apt_update(){
sudo apt update -y
}

## Downloading and installing external programs ##

install_debs(){

echo -e "${GREEN}[INFO] - Downloading .deb packages${NO_COLOR}"

mkdir $DOWNLOADS_DIRECTORY
wget -c "$URL_GOOGLE_CHROME"       -P "$DOWNLOADS_DIRECTORY"

## Installing downloaded packages .deb in latest session ##
echo -e "${GREEN}[INFO] - Installing downloaded packages .deb${NO_COLOR}"
sudo dpkg -i $DOWNLOADS_DIRECTORY/*.deb
}

## Packages to install
PROGRAMS_TO_INSTALL=(
  snapd
  flatpak
  gnome-software-plugin-flatpak
  dpkg
  gdebi
  gdebi-core 
  gparted
  wget
  curl
  btop
  neofetch
  vim
  vlc
  unzip
  p7zip
  unrar
)

# Installing programs from apt
install_packages(){
  echo -e "${GREEN}[INFO] - Installing programs from repositories${NO_COLOR}"

  for program_name in ${PROGRAMS_TO_INSTALL[@]}; do
    sudo apt install "$program_name" -y
  done
}

## Set flathub repository
flat_repo(){
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

## Installing Flatpak packages ##
install_flatpaks(){

  echo -e "${GREEN}[INFO] - Installing flatpak packages${NO_COLOR}"

flatpak install flathub org.qbittorrent.qBittorrent -y
flatpak install flathub org.flameshot.Flameshot -y
}

## Installing Snap packages ##

install_snaps(){

echo -e "${GREEN}[INFO] - Installing snap packages${NO_COLOR}"

#sudo apt install snapd
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
sudo echo "alias updf='sudo apt update && sudo apt full-upgrade -y && flatpak update -y && sudo snap refresh'" >> ../.bashrc
sudo echo "alias updc='sudo apt-get autoclean -y && sudo apt-get clean -y && sudo apt-get autoremove -y'" >> ../.bashrc

#Changing current swappiness value 
sudo echo "vm.swappiness=10"  >> /etc/sysctl.conf

source $BASHRC
}

# -------------------------------------------------------------------------------- #
# ------------------------------- RUNNING ---------------------------------------- #
apt_locks
tests_internet
apt_update
add_archi386
just_apt_update
install_debs
install_packages
flat_repo
apt_update
install_flatpaks
install_snaps
apt_update
system_clean
extra_config

## finalização
  echo -e "${GREEN}[INFO] - Script finished, installation complete! :)${NO_COLOR}"
