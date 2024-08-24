#!/bin/bash
# ---------------------------------------------------------------------- #
#  Personal script for automate linux post installation 
#  Author: Jean Rodrigo
# ---------------------------------------------------------------------- #
#  HOW TO USE?
#  $ sudo chmod +x manjaro.sh
#  $ ./manjaro.sh
# ----------------------------- VARIABLES ------------------------------ #
set -e

# COLORS
RED='\e[1;91m'
GREEN='\e[1;92m'
NO_COLOR='\e[0m'

## FUNCTIONS
echo -e "${GREEN}[INFO] - Initializing Manjaro Post Install Script${NO_COLOR}"
# -------------------------------------------------------------------------------- #
# ------------------------------TEST AND REQUIREMENTS----------------------------- #
# Internet test
internet_test() {
    echo -e "${GREEN}[INFO] - Testing Internet connection${NO_COLOR}"
    
    if ! ping -c 1 1.1.1.1 -q &> /dev/null; then
        echo -e "${RED}[ERROR] - Your computer does not have an Internet connection. Check the network.${NO_COLOR}"
        exit 1
    else
        echo -e "${GREEN}[INFO] - Internet connection ok!${NO_COLOR}"
    fi
}

# Mirror config
fast_mirror() {
    echo -e "${GREEN}[INFO] - Setting fastest mirrors${NO_COLOR}"

    sudo pacman-mirrors --fasttrack 5 && sudo pacman-mirrors --geoip
}

# Update repositories and upgrade system
update_repositories() {
    echo -e "${GREEN}[INFO] - Updating repositories${NO_COLOR}"
    
    sudo pacman -Syyu --noconfirm
}

# PACKAGES TO INSTALL
PACMAN_APPS=(
    snapd
    plank
    loupe
    neofetch
    vim
    vlc
    unrar
    lsd
    ttf-firacode-nerd
    ttf-cascadia-code-nerd
    ttf-meslo-nerd-font-powerlevel10k
)

FLATPAK_APPS=(
    com.google.Chrome
)

SNAP_APPS=(
    code --classic
)

REMOVE_APPS=(
    thunderbird
    vivaldi
    hexchat
    gimp
    pix
    celluloid
    mpv
    lollypop
)

# Installing packages from pacman
install_pacman_packages() {
    echo -e "${GREEN}[INFO] - Installing programs from pacman${NO_COLOR}"
  
    sudo pacman -S --noconfirm "${PACMAN_APPS[@]}"
}

# Installing apps from flatpak
install_flatpak_apps() {
    echo -e "${GREEN}[INFO] - Installing programs from Flatpak${NO_COLOR}"
  
    local -r flatpak_app=("${FLATPAK_APPS[@]}")

    for fapp in "${flatpak_app[@]}"; do
        flatpak install -y "$fapp"
    done
}

# Installing apps from snap
install_snap_apps() {
    echo -e "${GREEN}[INFO] - Installing programs from Snap${NO_COLOR}"
  
    local -r snap_app=("${SNAP_APPS[@]}")

    for sapp in "${snap_app[@]}"; do
        sudo snap install -y "$sapp"
    done
}

# Config snap
config_snap() {
    echo -e "${GREEN}[INFO] - Configuring snap${NO_COLOR}"
  
    sudo systemctl enable --now snapd.socket
    sudo systemctl enable --now snapd.apparmor

    sudo ln -s /var/lib/snapd/snap /snap
}

# Remove some ununsed apps
remove_apps() {
    echo -e "${GREEN}[INFO] - Removing ununsed apps${NO_COLOR}"
  
    sudo pacman -R --noconfirm "${REMOVE_APPS[@]}"
}

# Final system cleanup
system_clean(){
    echo -e "${GREEN}[INFO] - Cleaning cache${NO_COLOR}"

    sudo pacman -Rns $(pacman -Qqdt) --noconfirm && sudo pacman -Sc --noconfirm
}

ssd_trim(){
    echo -e "${GREEN}[INFO] - SSD trimming${NO_COLOR}"
    
    sudo systemctl enable fstrim.timer --now
}

reload_fonts_cache(){
    echo -e "${GREEN}[INFO] - Reloading fonts cache${NO_COLOR}"
    
    sudo fc-cache -f
}

# -------------------------------------------------------------------------- #
# ----------------------------- EXTRA CONFIGS ------------------------------ #
extra_config(){
# Creating aliases in .bashrc file
cat >>"$HOME/.bashrc" << EOF

alias updf="sudo pacman -Syu && flatpak update -y && sudo snap refresh"
alias updc="sudo pacman -Sc"
alias fdns="resolvectl flush-caches"

# LSD 
if [ -x "$(command -v lsd)" ]; then
alias ls="lsd"
fi

EOF

}

# -------------------------------------------------------------------------- #
# ------------------------------- RUNNING ---------------------------------- #

internet_test
fast_mirror
update_repositories
install_pacman_packages
install_flatpak_apps
config_snap
install_snap_apps
remove_apps
system_clean
ssd_trim
reload_fonts_cache
extra_config

# Ending
echo -e "${GREEN}[INFO] - Script completed, reboot the system! :)${NO_COLOR}"
exit
