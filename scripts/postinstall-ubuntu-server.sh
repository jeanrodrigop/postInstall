#!/usr/bin/env bash
#
# ubuntu-server-postinstall.sh - Install and configure programs for my personal use (Ubuntu server)
#
# Autor:         Jean Rodrigo
#
# ------------------------------------------------------------------------ #
#
# HOW TO USE?
#   $ ./ubuntu-server-postinstall.sh
#
# ----------------------------- VARIABLES ----------------------------- #
set -e

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

##DEB SOFTWARES TO INSTALL
PROGRAMS_TO_INSTALL=(
  
  git
  wget
  curl
  htop
  neofetch
  gdebi
  gdebi-core 
  rar
  unrar 
  p7zip-full
  p7zip-rar
  gzip
  snapd
  
)

# ---------------------------------------------------------------------- #

## Downloading and installing external programs ##
install_debs(){
# Installing programs from apt
echo -e "${GREEN}[INFO] - Installing programs from repositories${NO_COLOR}"

for program_name in ${PROGRAMS_TO_INSTALL[@]}; do
  sudo apt install "$program_name" -y
done
# Install dependencies
sudo apt-get install -f -y
}
## Installing Snap packages ##
install_snaps(){
echo -e "${GREEN}[INFO] - Installing snap packages${NO_COLOR}"
sudo snap install SNAPNAME
}


# -------------------------------------------------------------------------- #
# ------------------------------ POST-INSTALL ------------------------------ #
## Finalizing, updating and cleaning ##
system_clean(){
apt_update -y
sudo apt clean -y
sudo apt autoclean -y
sudo apt autoremove -y
}

# -------------------------------------------------------------------------- #
# ----------------------------- EXTRA CONFIGS ------------------------------ #
extra_config(){
#Creating aliases in ~/.bashrc file
#sudo echo "alias updf='sudo apt update && sudo apt full-upgrade -y'" >> ~/.bashrc
#sudo echo "alias updc='sudo apt-get autoclean -y && sudo apt-get clean -y && sudo apt-get autoremove -y'" >> ~/.bashrc
#Changing current swappiness value 
sudo echo "vm.swappiness=10"  >> /etc/sysctl.conf
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

apt_locks
tests_internet
apt_update
add_archi386
just_apt_update
install_debs
#install_snaps
apt_update
system_clean
extra_config
check_apps

## finalização
  echo -e "${GREEN}[INFO] - Script finished, installation complete! :)${NO_COLOR}"
  echo -e "${GREEN}[INFO] - Restart the system!${NO_COLOR}"