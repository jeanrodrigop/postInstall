#!/usr/bin/env bash
## ---------------------------------------------------------------------- ##
##  postinstall.sh - Personal script for automate linux post installation 
##  Autor: Jean Rodrigo
## ---------------------------------------------------------------------- ##
##  HOW TO USE?
##  $ ./postinstall.sh
## ----------------------------- VARIABLES ------------------------------ ##
set -e

BASHRC="$HOME/.bashrc"

#COLORS
RED='\e[1;91m'
GREEN='\e[1;92m'
NO_COLOR='\e[0m'

#FUNCTIONS
echo -e "${GREEN}[INFO] - Fedora Post Install Script...${NO_COLOR}"
# -------------------------------------------------------------------------------- #
# ------------------------------TEST AND REQUIREMENTS----------------------------- #
# Internet test
internet_test(){
  if ! ping -c 1 1.1.1.1 -q &> /dev/null; then
    echo -e "${RED}[ERROR] - Your computer does not have an Internet connection. Check the network.${NO_COLOR}"
    exit 1
  else
    echo -e "${GREEN}[INFO] - Internet connection ok!${NO_COLOR}"
  fi
}

# Fastest mirror config
fast_mirror(){
  echo -e "${GREEN}[INFO] - Set fast mirror config${NO_COLOR}"
  sudo echo "max_parallel_downloads=10"  >> /etc/dnf/dnf.conf
  sudo echo "fastestmirror=True"  >> /etc/dnf/dnf.conf
  sudo echo "deltarpm=True"  >> /etc/dnf/dnf.conf
}

fusion_repo(){
  echo -e "${GREEN}[INFO] - Installing fusion repositories${NO_COLOR}"
  sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
  sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
}

# Update repositories and upgrade system
repo_update(){
  echo -e "${GREEN}[INFO] - Updating repositories${NO_COLOR}"
  sudo dnf update -y && sudo dnf upgrade -y --refresh
}

# -------------------------------------------------------------------------- #
## SOFTWARES TO INSTALL
PROGRAMS_TO_INSTALL=(
  snapd
  flatpak
  gparted
  git
  code
  htop
  neofetch
  vim
  wget
  curl
  vlc
  unzip
  p7zip
  p7zip-plugins
  unrar
  fedora-workstation-repositories
)

# Installing programs from repositories
install_dnf(){
  echo -e "${GREEN}[INFO] - Installing programs from repositories${NO_COLOR}"

  for program_name in ${PROGRAMS_TO_INSTALL[@]}; do
    sudo dnf install "$program_name" -y
  done
}

chrome_install(){
  sudo dnf config-manager --set-enabled google-chrome
  sudo dnf install google-chrome-stable -y
}

remove_firefox(){
  sudo dnf remove -y firefox
}

snap_symbolic(){
  sudo ln -s /var/lib/snapd/snap /snap
}

## Set flathub repository
flat_repo(){
  echo -e "${GREEN}[INFO] - Adding flatpak repositories${NO_COLOR}"
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

multimedia_plugins(){
  echo -e "${GREEN}[INFO] - Installing multimedia codecs${NO_COLOR}"
  sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
  sudo dnf install -y lame\* --exclude=lame-devel
  sudo dnf group upgrade -y --with-optional Multimedia --allowerasing
}

firmware_update(){
  echo -e "${GREEN}[INFO] - Updating firmwares${NO_COLOR}"
  sudo fwupdmgr get-devices -y
  sudo fwupdmgr refresh -y --force 
  sudo fwupdmgr get-updates -y 
  sudo fwupdmgr update -y

  reboot
}

# -------------------------------------------------------------------------- #
# ------------------------------ POST-INSTALL ------------------------------ #
## Finalizing, updating and cleaning ##
system_clean(){
  sudo dnf clean all
}

# -------------------------------------------------------------------------- #
# ----------------------------- EXTRA CONFIGS ------------------------------ #
extra_config(){
  #Creating aliases in ~/.bashrc file
  sudo echo "alias updf='sudo dnf update -y && sudo dnf upgrade -y --refresh'" >> ../.bashrc

  #Changing current swappiness value
  sudo echo "vm.swappiness=10"  >> /etc/sysctl.conf

  source $BASHRC
}

# -------------------------------------------------------------------------------- #
# ------------------------------- RUNNING ---------------------------------------- #

internet_test
fast_mirror
fusion_repo
repo_update
install_dnf
chrome_install
remove_firefox
snap_symbolic
flat_repo
multimedia_plugins
repo_update
system_clean
extra_config
firmware_update

## finalização
  echo -e "${GREEN}[INFO] - Script completed, reboot the system! :)${NO_COLOR}"
