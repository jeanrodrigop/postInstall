#!/bin/bash
 
#  Personal script for automate linux post installation 
#  Author: Jean Rodrigo
#  ----------------------------------------------------
#  HOW TO USE?
#  $ sudo chmod +x opensuse-kde.sh && ./opensuse-kde.sh
  
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

    sudo zypper ref > /dev/null 2>> error.log
}

# UPDATE AND UPGRADE
update_repositories() {
    echo -e "${GREEN}[INFO] - Applying update and upgrade${NO_COLOR}"
    
    (sudo zypper up -y && sudo zypper dup -y) > /dev/null 2>> error.log
}

# LIST PACKAGES TO INSTALL
# REPO PACKAGES
REPO_APPS=(
    flatpak
    plank
    loupe
    fastfetch
    fastfetch-bash-completion
    fastfetch-zsh-completion
    gparted
    htop
    btop
    git
    vim
    nano
    curl
    wget
    vlc
    unrar
    easyeffects
    flameshot
    remmina
    freerdp
    freerdp2
    lsd
    tmux
    steam
    discord
    free-ttf-fonts
)

# FLATPAK PACKAGES
FLATPAK_APPS=(
    com.raggesilver.BlackBox
    de.swsnr.turnon
)

# LIST PACKAGES TO REMOVE
REMOVE_APPS=(
    kate
    skanlite
    gwenview
    MozillaFirefox
    MozillaFirefox-branding-openSUSE
    konversation
    okular
)

# INSTALLING PACKAGES FROM REPO
install_repo_packages() {
    echo -e "${GREEN}[INFO] - Installing packages from repositories${NO_COLOR}"
  
    sudo zypper in -y "${REPO_APPS[@]}" > /dev/null 2>> error.log
}

# INSTALLING PACKAGES FROM FLATPAK
install_flatpak_apps() {
    echo -e "${GREEN}[INFO] - Installing packages from flatpak${NO_COLOR}"
    
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo > /dev/null 2>> error.log

    local -r flatpak_app=("${FLATPAK_APPS[@]}")

    for fapp in "${flatpak_app[@]}"; do
        sudo flatpak install -y "$fapp" > /dev/null 2>> error.log
    done
}

# APPLYING EXTRA REPOSITEORIES
extra_repos() {
    echo -e "${GREEN}[INFO] - Applying extra repositories${NO_COLOR}"

    sudo zypper ar --refresh https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed snappy > /dev/null 2>> error.log
    sudo zypper --gpg-auto-import-keys refresh > /dev/null 2>> error.log
    sudo zypper dup -y --from snappy > /dev/null 2>> error.log

    sudo zypper ar -cfp 90 https://packman.opensuse.net.br/openSUSE_Tumbleweed/ packman > /dev/null 2>> error.log
    sudo zypper --gpg-auto-import-keys refresh > /dev/null 2>> error.log
    sudo zypper dup -y --from packman --allow-vendor-change > /dev/null 2>> error.log
}

# REMOVE APPs
remove_apps() {
    echo -e "${GREEN}[INFO] - Removing selected apps${NO_COLOR}"
  
    sudo zypper rm -y "${REMOVE_APPS[@]}" > /dev/null 2>> error.log
}

# INSTALL RPM PACKAGES
rpm_install() {
    echo -e "${GREEN}[INFO] - Installing Google Chrome${NO_COLOR}"
    
    # GOOGLE CHROME
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm > /dev/null 2>> error.log
    sudo rpm -ivh google-chrome-stable_current_x86_64.rpm > /dev/null 2>> error.log
    sudo rm google-chrome-stable_current_x86_64.rpm > /dev/null 2>> error.log

    # VSCODE
    wget https://vscode.download.prss.microsoft.com/dbazure/download/stable/6609ac3d66f4eade5cf376d1cb76f13985724bcb/code-1.98.0-1741124844.el8.x86_64.rpm > /dev/null 2>> error.log
    sudo rpm -ivh code-*.rpm > /dev/null 2>> error.log
    sudo rm code-*.rpm > /dev/null 2>> error.log
}

# SYSTEM CLEAN 
system_clean(){
    echo -e "${GREEN}[INFO] - Cleaning cache${NO_COLOR}"

    sudo zypper cc > /dev/null 2>> error.log
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
alias zp="zypper"
alias updf="sudo zypper refresh && sudo zypper up -y && sudo zypper dup -y"

# LSD 
if [ -x "$(command -v lsd)" ]; then
alias ls="lsd"
fi

EOF
}

# RUNNING SCRIPT
internet_test
remove_apps
fast_mirror
update_repositories
extra_repos
install_repo_packages
install_flatpak_apps
system_clean
ssd_trim
reload_fonts_cache
create_aliases
rpm_install

# ENDING
echo -e "${GREEN}[INFO] - FINISHED, REBOOT THE SYSTEM!${NO_COLOR}"
exit
