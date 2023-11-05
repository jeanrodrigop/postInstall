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
URL_FEDORA="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/fedora.sh"

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
post_fedora(){
    curl -s "$URL_FEDORA" | bash -s --
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

## RUNNING POST INSTALL
PS3="Select a option: "
options=(Linux-Mint Ubuntu Ubuntu-Server Fedora Exit)
select menu in "${options[@]}";
do
    clear
    echo -e "\nYou selected $menu"
    if [[ $menu == "Linux-Mint" ]]; then
        clear
        mint_snap
    elif [[ $menu == "Ubuntu" ]]; then
        clear
        post_ubuntu
    elif [[ $menu == "Ubuntu-Server" ]]; then
        clear
        post_userver
    elif [[ $menu == "Fedora" ]]; then
        clear
        post_fedora   
    elif [[ $menu == "Exit" ]]; then
        clear
        exit
        break;
    else
        echo "Option not available!"
    fi 
done
