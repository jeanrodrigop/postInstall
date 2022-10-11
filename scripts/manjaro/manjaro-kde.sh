#!/bin/bash
 
#  Personal script for automate linux post installation 
#  Author: Jean Rodrigo
#  ----------------------------------------------------
#  HOW TO USE?
#  $ sudo chmod +x manjaro-cinnamon.sh && ./manjaro-cinnamon.sh
  
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

# MIRROR CONFIGURATION
fast_mirror() {
    echo -e "${GREEN}[INFO] - Setting fastest mirrors${NO_COLOR}"

    (sudo pacman-mirrors --fasttrack 5 && sudo pacman-mirrors --geoip) > /dev/null 2>> error.log
}

# UPDATE AND UPGRADE
update_repositories() {
    echo -e "${GREEN}[INFO] - Applying update and upgrade${NO_COLOR}"
    
    (sudo pacman -Sy archlinux-keyring --noconfirm && sudo pacman -Syyu --noconfirm) > /dev/null 2>> error.log
}

# LIST PACKAGES TO INSTALL
# REPO PACKAGES
PACMAN_APPS=(
    snapd
    loupe
    fastfetch
    gparted
    htop
    git
    vim
    vlc
    unrar
    vlc-plugins-all
    kdenlive
    obs-studio
    7zip
    easyeffects
    lsd
    tmux
    steam
    lutris
    discord
    ttf-montserrat
    ttf-firacode-nerd
    ttf-cascadia-code-nerd
    ttf-meslo-nerd-font-powerlevel10k
)

# AUR PACKAGES
PAMAC_APPS=(
    google-chrome
    visual-studio-code-bin
)

# FLATPAK PACKAGES
FLATPAK_APPS=(
    com.google.Chrome
    net.codelogistics.webapps
)

# LIST PACKAGES TO REMOVE
REMOVE_APPS=(
    gwenview
    elisa
    firefox
)

# INSTALLING PACKAGES FROM REPO
install_pacman_packages() {
    echo -e "${GREEN}[INFO] - Installing packages with pacman${NO_COLOR}"
  
    sudo pacman -S --noconfirm "${PACMAN_APPS[@]}" > /dev/null 2>> error.log
}


# INSTALLING PACKAGES FROM AUR
install_pamac_packages() {
    echo -e "${GREEN}[INFO] - Installing packages with pamac${NO_COLOR}"
  
    pamac install --noconfirm "${PAMAC_APPS[@]}" > /dev/null 2>> error.log
}

# INSTALLING PACKAGES FROM FLATPAK
install_flatpak_apps() {
    echo -e "${GREEN}[INFO] - Installing packages from flatpak${NO_COLOR}"
  
    local -r flatpak_app=("${FLATPAK_APPS[@]}")

    for fapp in "${flatpak_app[@]}"; do
        flatpak install -y "$fapp" > /dev/null 2>> error.log
    done
}

# SNAP CONFIG
config_snap() {
    echo -e "${GREEN}[INFO] - Configuring snap${NO_COLOR}"

    sudo systemctl enable --now snapd.socket > /dev/null 2>> error.log
    sudo systemctl enable --now snapd.apparmor > /dev/null 2>> error.log
    sudo systemctl enable --now snapd.service > /dev/null 2>> error.log
    sudo systemctl restart snapd > /dev/null 2>> error.log

    sudo ln -s /var/lib/snapd/snap /snap > /dev/null 2>> error.log
}

# INSTALLING PACKAGES FROM SNAP
install_snap_apps() {
    echo -e "${GREEN}[INFO] - Installing snap packages${NO_COLOR}"

    sudo snap install code --classic > /dev/null 2>> error.log
}

# REMOVE APPs
remove_apps() {
    echo -e "${GREEN}[INFO] - Removing selected apps${NO_COLOR}"
  
    sudo pacman -R --noconfirm "${REMOVE_APPS[@]}" > /dev/null 2>> error.log
}

# SYSTEM CLEAN 
system_clean(){
    echo -e "${GREEN}[INFO] - Cleaning cache${NO_COLOR}"

    (sudo pacman -Rns $(pacman -Qqdt) --noconfirm && sudo pacman -Sc --noconfirm) > /dev/null 2>> error.log
}

# TRIM SSD
ssd_trim(){
    echo -e "${GREEN}[INFO] - SSD trimming${NO_COLOR}"
    
    sudo systemctl enable fstrim.timer --now > /dev/null 2>> error.log
}

# PERSONAL CONFIGURATION FILES
personal_configs(){
    echo -e "${GREEN}[INFO] - Copying personal configuration files${NO_COLOR}"

    cat configs/plasma-org.kde.plasma.desktop-appletsrc > $HOME/.config/plasma-org.kde.plasma.desktop-appletsrc
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
fast_mirror
update_repositories
install_pacman_packages
install_pamac_packages
#install_flatpak_apps
config_snap
install_snap_apps
remove_apps
system_clean
ssd_trim
personal_configs
reload_fonts_cache
create_aliases

# Ending
echo -e "${GREEN}[INFO] - FINISHED, REBOOT THE SYSTEM!${NO_COLOR}"
exit
