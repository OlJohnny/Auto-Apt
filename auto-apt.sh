#!/usr/bin/env bash
# github.com/OlJohnny | 2019
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace         # uncomment the previous statement for debugging

### set absolute path for cron compatibility ###
PATH=/usr/bin:/bin:/usr/sbin:/sbin

### check for root privilges ###
if [[ "${EUID}" -ne 0 ]]
then
  echo -e "\e[91mPlease run as root.\e[39m Root privileges are needed to add, update and remove packages"
  exit
fi


### check if run with 'manual' option ###
if [[ -z "${1+x}" ]]
then
	interactive=0
else
	interactive=1
fi


### execute stuff ###
if [[ "${interactive}" == 1 ]]
then
	echo -e "\e[96mNormal Argument Provided, Semi-Automated removing, update, upgrade, install, autoremove...\e[0m"
	echo -e "\e[96m<$(date +"%T")> Removing Standard Desktop Applications...\e[0m"
	apt remove --purge libreoffice* thunderbird*
	echo -e "\e[96m<$(date +"%T")> Updating Package List...\e[0m"
	apt update > /dev/null
	apt list --upgradeable
	echo -e "\e[96m<$(date +"%T")> Upgrading Packages...\e[0m"
	apt upgrade
	echo -e "\e[96m<$(date +"%T")> Installing Recommended Packages...\e[0m"
	apt install nano htop software-properties-common linux-headers-generic net-tools iptables make build-essential git php curl whiptail
	echo -e "\e[96m<$(date +"%T")> Removing Old Packages...\e[0m"
	apt autoremove
	echo -e "\e[96m<$(date +"%T")> Exiting...\e[0m"
else
	echo -e "\e[96mNo Normal Argument Provided, Executing Automated update, upgrade, autoremove...\e[0m"
	echo -e "\e[96m<$(date +"%T")> Updating Package List...\e[0m"
	apt update
	echo -e "\e[96m<$(date +"%T")> Upgrading Packages...\e[0m"
	apt upgrade -y
	echo -e "\e[96m<$(date +"%T")> Removing Old Packages...\e[0m"
	apt autoremove -y
	echo -e "\e[96m<$(date +"%T")> Exiting...\e[0m"
fi
