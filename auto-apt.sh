#!/usr/bin/env bash
# github.com/OlJohnny | 2021
set -e            # exit immediately if a command exits with a non-zero status
set -u            # treat unset variables as an error when substituting
set -o pipefail   # return value of pipeline is status of last command to exit with a non-zero status
# set -o xtrace   # uncomment the previous statement for debugging

### set absolute path for cron compatibility ###
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# environment
SCRIPT_FULL=$(realpath -s $0)     # stackoverflow.com/a/11114547
SCRIPT_PATH=$(dirname $(realpath -s $0))
SCRIPT_NAME=$(basename $(realpath -s $0))
LOG_FILE="${SCRIPT_FULL}".log
MAIL_TO="admin@yourdomain.com"
MAIL_FROM="butterkeks@yourdomain.com"

# text colors
text_info="\e[96m"
text_yes="\e[92m"
text_no="\e[91m"
text_reset="\e[0m"
read_question=$'\e[93m'
read_reset=$'\e[0m'

# check for root privileges
if [[ "${EUID}" -ne 0 ]]
then
    echo -e ""${text_no}"Please run as root."${text_reset}""
    echo -e "Exiting..."
    exit 1
fi

# check if instance of script is already running, stackoverflow.com/a/45429634
if ps ax | grep ${SCRIPT_NAME} | grep --invert-match $$ | grep bash | grep --invert-match grep > /dev/null
then
    echo -e ""${text_no}"Another instance of this script is already running."${text_reset}""
    echo -e "Exiting..."
    exit 1
fi

# prepare log file
ERROR=0
smallerror=0
echo -e "From: "${MAIL_FROM}"
Subject: ERROR: auto-apt - $(hostname)" > "${LOG_FILE}"

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
	echo -e ""${text_info}"Normal Argument Provided, Semi-Automated removing, update, upgrade, install, autoremove..."${text_reset}""
	echo -e ""${text_info}"<$(date +"%T")> Removing Standard Desktop Applications..."${text_reset}""
	apt-get purge libreoffice* thunderbird*
	echo -e ""${text_info}"<$(date +"%T")> Updating Package List..."${text_reset}""
	apt-get update > /dev/null
	apt list --upgradeable
	echo -e ""${text_info}"<$(date +"%T")> Upgrading Packages..."${text_reset}""
	apt-get upgrade
	echo -e ""${text_info}"<$(date +"%T")> Installing Recommended Packages..."${text_reset}""
	apt-get install nano htop software-properties-common linux-headers-generic net-tools git curl whiptail dkms
	echo -e ""${text_info}"<$(date +"%T")> Removing Old Packages..."${text_reset}""
	apt-get autoremove
	echo -e ""${text_info}"<$(date +"%T")> Exiting..."${text_reset}""
else
	echo -e ""${text_info}"No Normal Argument Provided, Executing Automated update, upgrade, autoremove..."${text_reset}"" |& tee -a "${LOG_FILE}"
	echo -e ""${text_info}"<$(date +"%T")> Updating Package List..."${text_reset}"" |& tee -a "${LOG_FILE}"
	apt-get update |& tee -a "${LOG_FILE}"
	echo -e ""${text_info}"<$(date +"%T")> Upgrading Packages..."${text_reset}"" |& tee -a "${LOG_FILE}"
	smallerror=$(apt-get upgrade |& tee -a "${LOG_FILE}" || echo "1")
	echo "${smallerror}"
	echo -e ""${text_info}"<$(date +"%T")> Removing Old Packages..."${text_reset}"" |& tee -a "${LOG_FILE}"
	apt-get autoremove -y |& tee -a "${LOG_FILE}"
	echo -e ""${text_info}"<$(date +"%T")> Exiting..."${text_reset}"" |& tee -a "${LOG_FILE}"
	# error message handling
	smallerror=$(echo "${smallerror}" | sed '$!d')
	if [[ "${smallerror}" == 1 ]]
	then
		ERROR=1
	fi
fi

if [[ "${ERROR}" == 1 ]]
then
	cat "${LOG_FILE}" | sed --regexp-extended "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | sed --regexp-extended "s/</\n</g" | ssmtp "${MAIL_TO}"
fi
