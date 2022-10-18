#!/usr/bin/env bash
## ---------------------------------------------------------------------- ##
##  postinstall.sh - Personal script for automate linux post installation 
##  Autor: Jean Rodrigo
## ---------------------------------------------------------------------- ##
##  HOW TO USE?
##  $ ./postinstall.sh
## ---------------------------------------------------------------------- ##
set -e


## COLORS
RED='\e[1;91m'
GREEN='\e[1;92m'
BLUE='\e[34m'
NO_COLOR='\e[0m'


## URLs   
URL_MINT="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/mint.sh"
URL_UBUNTU="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/ubuntu.sh"
URL_USERVER="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/ubuntu-server.sh"


## DIRECTORIES
NOSNAP="/etc/apt/preferences.d/nosnap.pref" #linux mint snap unlock


## FUNCTIONS
#download post install script for linux mint
post_mint(){
    curl -s "$URL_MINT" | bash -s --
}
post_ubuntu(){
    curl -s "$URL_UBUNTU" | bash -s --
}
post_userver(){
    curl -s "$URL_USERVER" | bash -s --
}
#exit program
exit(){
    echo "Exiting..."
}
#unlock snaps for linux mint
mint_snap(){
    if [ -f "$NOSNAP" ] ; then
        read -p "##LINUX MINT FIRST RUN NEED RESTART, THEN RUN SCRIPT AGAIN[PRESS ENTER]" t1
        rm "$NOSNAP"
        sudo reboot
    else
        echo -e "${GREEN}[NOSNAP REMOVED]RUNNING POST INSTALL${NO_COLOR}" 
        post_mint
    fi
}
#ask for install more apps
more_apps(){
    read -p "\nDo you want to install more apps? [Y/N]" yn
    case $yn in
        [yY] ) read -p "Enter apps names separated by 'space': " apps_input;
            apps_array;;
        [nN] ) exit;
            ;;
    esac
}
#array for apt apps(debian/ubuntu like)
apps_array(){
    for app in ${apps_input[@]}
    do
        sudo apt install -y $app
        system_clean
        exit
    done
}
#clean system after install more apps
system_clean(){
    sudo apt clean -y
    sudo apt autoclean -y
    sudo apt autoremove -y
}


## RUNNING POST INSTALL
PS3="Select a option: "
options=(Linux-Mint Ubuntu Ubuntu-Server Exit)
select menu in "${options[@]}";
do
    clear
    echo -e "\nYou selected $menu"
    if [[ $menu == "Linux-Mint" ]]; then
        clear
        mint_snap
        more_apps
    elif [[ $menu == "Ubuntu" ]]; then
        clear
        post_ubuntu
        more_apps
    elif [[ $menu == "Ubuntu-Server" ]]; then
        clear
        post_userver
        more_apps
    elif [[ $menu == "Exit" ]]; then
        clear
        exit
        break;
    else
        echo "Option not available!"
    fi 
done
