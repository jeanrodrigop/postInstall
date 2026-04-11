#!/bin/bash
 
#  Personal script for automate linux post installation 
#  Author: Jean Rodrigo
#  ----------------------------------------------------
#  HOW TO USE?
#  $ sudo chmod +x cachyos.sh && ./cachyos.sh
  
# VARIABLES
set -e

# COLORS
RED='\e[1;91m'
GREEN='\e[1;92m'
NO_COLOR='\e[0m'

# INTERNET TEST
internet_test() {
    echo -e "${GREEN}[INFO] - Testing Internet connection${NO_COLOR}"
    
    if ! ping -c 1 1.1.1.1 -q &> /dev/null; then
        echo -e "${RED}[ERROR] - Your computer does not have an Internet connection. Check the network.${NO_COLOR}"
        exit 1
    else
        echo -e "${GREEN}[INFO] - Internet connection is ok!${NO_COLOR}"
    fi
}

# LIST PACKAGES TO INSTALL
# REPO PACKAGES
PACMAN_APPS=(
    vlc
    lsd
    ncdu
    htop
    7zip
    tmux
    kget
    loupe
    lutris
    discord
    gparted
    kdenlive
    obs-studio
    qbittorrent
    easyeffects
    ttf-montserrat
    vlc-plugins-all
    ttf-firacode-nerd
    ttf-cascadia-code-nerd
)

# AUR PACKAGES
PARU_APPS=(
    anydesk-bin
    google-chrome
    visual-studio-code-bin
)

# FLATPAK PACKAGES
FLATPAK_APPS=(
    #net.codelogistics.webapps
)

# LIST PACKAGES TO REMOVE
REMOVE_APPS=(
    meld
    micro
    haruna
    alacritty
    gwenview
    firefox
)

# INSTALLING PACKAGES FROM REPO
install_pacman_packages() {
    echo -e "${GREEN}[INFO] - Installing packages with pacman${NO_COLOR}"
  
    sudo pacman -S --noconfirm "${PACMAN_APPS[@]}" > /dev/null 2>> error.log
}


# INSTALLING PACKAGES FROM AUR
install_paru_packages() {
    echo -e "${GREEN}[INFO] - Installing packages with paru${NO_COLOR}"
  
    paru -S --noconfirm "${PARU_APPS[@]}" > /dev/null 2>> error.log
}

# INSTALLING PACKAGES FROM FLATPAK
install_flatpak_apps() {
    echo -e "${GREEN}[INFO] - Installing packages from flatpak${NO_COLOR}"
  
    local -r flatpak_app=("${FLATPAK_APPS[@]}")

    for fapp in "${flatpak_app[@]}"; do
        flatpak install -y "$fapp" > /dev/null 2>> error.log
    done
}

# REMOVE APPs
remove_apps() {
    echo -e "${GREEN}[INFO] - Removing selected apps${NO_COLOR}"
  
    sudo pacman -R --noconfirm "${REMOVE_APPS[@]}" > /dev/null 2>> error.log
}

# SYSTEM CLEAN 
system_clean(){
    echo -e "${GREEN}[INFO] - Cleaning cache${NO_COLOR}"

    (sudo pacman -Rns $(pacman -Qqdt) --noconfirm || true && sudo pacman -Sc --noconfirm) > /dev/null 2>> error.log
}

# TRIM SSD
ssd_trim(){
    echo -e "${GREEN}[INFO] - SSD trimming${NO_COLOR}"
    
    sudo systemctl enable fstrim.timer --now > /dev/null 2>> error.log
}

# RELOAD FONTS CACHE
reload_fonts_cache(){
    echo -e "${GREEN}[INFO] - Reloading fonts cache${NO_COLOR}"
    
    sudo fc-cache -f > /dev/null 2>> error.log
}

# CREATE ALIASES
create_aliases(){
cat >>"$HOME/.bashrc" << EOF
# PERSONAL ALIASES
alias updf="sudo pacman -Syu && flatpak update -y && sudo snap refresh && pamac update --no-confirm"
alias updc="sudo pacman -Sc"
alias fdns="resolvectl flush-caches"
alias cachegit='eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519'
alias lst="ls --tree"
alias lsa="ls -la"
alias ff="fastfetch"

# LSD 
if [ -x "$(command -v lsd)" ]; then
alias ls="lsd"
fi

EOF

}

# RUNNING SCRIPT

internet_test
install_pacman_packages
install_paru_packages
#install_flatpak_apps
remove_apps
system_clean
ssd_trim
reload_fonts_cache
create_aliases

# Ending
echo -e "${GREEN}[INFO] - FINISHED, REBOOT THE SYSTEM!${NO_COLOR}"
exit
