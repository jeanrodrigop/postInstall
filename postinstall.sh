#!/bin/bash
## ---------------------------------------------------------------------- ##
##  postinstall.sh - Personal script for automate linux post installation 
##  Autor: Jean Rodrigo
## ---------------------------------------------------------------------- ##
##  HOW TO USE?
##  $ ./postinstall.sh
## ---------------------------------------------------------------------- ##
set -e

## COLORS
RED='\033[1;91m'
GREEN='\033[1;92m'
BLUE='\033[34m'
NO_COLOR='\033[0m'

## URLs   
URL_MINT="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/mint.sh"
URL_UBUNTU="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/ubuntu.sh"
URL_USERVER="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/ubuntu-server.sh"
URL_FEDORA="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/fedora.sh"
URL_MANJARO="https://raw.githubusercontent.com/jeanrodrigop/postInstall/main/scripts/manjaro.sh"

## DIRECTORIES
NOSNAP="/etc/apt/preferences.d/nosnap.pref" #linux mint snap unlock

## FUNCTIONS
# Download post install script for Linux Mint
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
post_manjaro(){
    curl -s "$URL_MANJARO" | bash -s --
}
# Exit program
exit_program(){
    echo "Exiting..."
}
# Unlock snaps for Linux Mint
mint_snap(){
    if [ -f "$NOSNAP" ] ; then
        read -p "## LINUX MINT FIRST RUN NEED RESTART, THEN RUN SCRIPT AGAIN [PRESS ENTER]" t1
        rm "$NOSNAP"
        sudo reboot
    else
        echo -e "${GREEN}[NOSNAP REMOVED] RUNNING POST INSTALL${NO_COLOR}" 
        post_mint
    fi
}

## RUNNING POST INSTALL
PS3="Select an option: "
options=("Linux-Mint" "Ubuntu" "Ubuntu-Server" "Fedora" "Manjaro" "Exit")
select menu in "${options[@]}";
do
    clear
    echo -e "\nYou selected $menu"
    if [[ "${menu}" == "Linux-Mint" ]]; then
        clear
        mint_snap
    elif [[ "${menu}" == "Ubuntu" ]]; then
        clear
        post_ubuntu
    elif [[ "${menu}" == "Ubuntu-Server" ]]; then
        clear
        post_userver
    elif [[ "${menu}" == "Fedora" ]]; then
        clear
        post_fedora   
    elif [[ "${menu}" == "Manjaro" ]]; then
        clear
        post_manjaro
    elif [[ "${menu}" == "Exit" ]]; then
        clear
        exit_program
        break
    else
        echo "Option not available!"
    fi 
done
