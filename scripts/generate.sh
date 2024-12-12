#!/bin/bash

# inputbox - demonstrate the input dialog box with redirection

# Define the dialog exit status codes
: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}
: ${DIALOG_BACK_TITLE="Solana Monitoring Configuration"}
: ${DIALOG_LABEL_TITLE="Please Enter the values or keep what was found on your system automatically"}

dependencies=("jq" "bc" "sudo" "dialog" "envsubst" "telegraf")

CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
DARK_RED='\033[38;5;88m'
DARK_GREEN='\033[38;5;22m'
RESET='\033[0m'

clean () {
  rm -rf form.txt
  rm -rf monitor.sh
}

checkDistr() {
  distrName=$(grep -i ubuntu /etc/os-release)
  if [ -z "${distrName}" ]; then
    echo -e "${DARK_RED}Distributive is not supported. Only works in Ubuntu.${RESET}"
    exit 1
  fi
}

checkSolana() {
  solanaCheck=$(which solana)
  if [ -z "$solanaCheck" ]; then
    echo -e "${DARK_RED}Solana CLI is not installed. Please follow the instructions to install. ${CYAN}https://docs.anza.xyz/cli/install/ ${RESET}"
    exit 1
  fi
}

checkDeps() {
  exitCode=0
  for pkg in "${dependencies[@]}"; do
    output=$(which "$pkg")
    if [ -z "$output" ]; then
      echo -e "${CYAN}$pkg ${DARK_RED}is NOT installed.${RESET}"
      exitCode=1
    else
      echo -e "${CYAN}$pkg ${DARK_GREEN}is installed.${RESET}"
    fi
  done
  if [ $exitCode -ne 0 ]; then
      echo -e "${DARK_RED}Dependencies failed. Exiting.${RESET}"
      echo -e "${DARK_GREEN}To Install execute:>${MAGENTA}apt install jq bc sudo dialog gettext-base gpg${RESET}"
      echo -e "${DARK_GREEN}To Install telegraf please try:>${MAGENTA}apt install telegraf${DARK_GREEN} otherwise follow the instructions ${CYAN}(https://docs.influxdata.com/telegraf/v1/install/)${RESET}"
      exit 1
  fi
  sleep 1
}

checkDistr
checkSolana
checkDeps
clean
# Auto detect values
solana_bin_dir="$(which solana|awk -F "bin" '{print $1}')bin"
solana_rpc_url="http://api.testnet.solana.com"
solana_config_dir="$HOME/.config/solana"

influx_database="solana"
influx_url="https://"

telegraf_script_path=$(pwd)
telegraf_check_interval="1m"
telegraf_check_timeout="1m"
telegraf_user=$(grep "telegraf" /etc/passwd|awk -F ":" '{print $1}')
# Duplicate (make a backup copy of) file descriptor 1 
# on descriptor 3
exec 3>&1
 
# Generate the dialog box while running dialog in a subshell
result=$(dialog --backtitle "${DIALOG_BACK_TITLE}" --title "${DIALOG_BACK_TITLE}" \
--form "\n${DIALOG_LABEL_TITLE}" 25 180 16 \
"Solana bin dir:" 1 1 "${solana_bin_dir}" 1 25 70 70 \
"Solana RPC Url:" 2 1 "${solana_rpc_url}" 2 25 70 70 \
"Validator public key:" 3 1 "" 3 25 70 70 \
"Vote public key:" 4 1 "" 4 25 70 70 \
"Solana Config Dir:" 5 1 "${solana_config_dir}" 5 25 70 70 \
"Telegraf Influx Db Url:" 7 1 "${influx_url}" 7 35 70 70 \
"Telegraf InfluxDb Database:" 8 1 "${influx_database}" 8 35 70 70 \
"Telegraf InfluxDb Username:" 9 1 "" 9 35 70 70 \
"Telegraf InfluxDb Password:" 10 1 "" 10 35 70 70 \
"Telegraf Solana check interval:" 11 1 "${telegraf_check_interval}" 11 35 10 10 \
"Telegraf Solana check timeout:" 12 1 "${telegraf_check_timeout}" 12 35 10 10 \
"Telegraf user:" 13 1 "${telegraf_user}" 13 35 70 70 \
"Node Name:" 14 1 "MyValidatorNodeName" 14 35 70 70 \
2>&1 1>&3)

# Get dialog's exit status
return_value=$?

# Close file descriptor 3
exec 3>&-

# Act on the exit status
case $return_value in
  $DIALOG_OK)
    echo "$result" > form.txt
    binDir=$(head -n 1 form.txt |tail -1)
    rpcUrl=$(head -n 2 form.txt |tail -1)
    identityPub=$(head -n 3 form.txt |tail -1)
    votePub=$(head -n 4 form.txt |tail -1)
    configDir=$(head -n 5 form.txt |tail -1)
    influxUrl=$(head -n 6 form.txt |tail -1)
    influxDb=$(head -n 7 form.txt |tail -1)
    influxUsername=$(head -n 8 form.txt |tail -1)
    influxPassowrd=$(head -n 9 form.txt |tail -1)
    monitorCommand="${telegraf_script_path}/monitor.sh"
    interval=$(head -n 10 form.txt |tail -1)
    timeout=$(head -n 11 form.txt |tail -1)
    nodeName=$(head -n 13 form.txt |tail -1)
    telegrafUSer=$(head -n 12 form.txt |tail -1)
    export solanaBinDir=$binDir
    export rpcUrl=$rpcUrl
    export identityPub=$identityPub
    export votePub=$votePub
    export configDir=$configDir
    export influxUrl=$influxUrl
    export influxDb=$influxDb
    export influxUsername=$influxUsername
    export influxPassowrd=$influxPassowrd
    export monitorCommand=$monitorCommand
    export interval=$interval
    export timeout=$timeout
    export nodeName=$nodeName
    cat templates/monitorTemplateHead.tpl | envsubst > head.sh
    cat head.sh > monitor.sh
    cat templates/monitorTemplateBody.tpl >> monitor.sh
    cat templates/telegraf-conf.tpl | envsubst > telegraf.conf
    rm head.sh
    mv telegraf.conf /etc/telegraf/telegraf.conf
    ;;
  $DIALOG_CANCEL)
    echo "Cancel pressed.";;
  $DIALOG_HELP)
    echo "Help pressed.";;
  $DIALOG_EXTRA)
    echo "Extra button pressed.";;
  $DIALOG_ITEM_HELP)
    echo "Item-help button pressed.";;
  $DIALOG_ESC)
    if test -n "$result" ; then
      echo "$result"
    else
      echo "ESC pressed."
    fi
    ;;
esac
clear
echo -e "\n======================================================"
echo -e "       Monitoring Script"
echo -e "======================================================"
echo -e "${CYAN}$(pwd)/monitor.sh${RESET}"
echo -e "\n"

echo -e "======================================================"
echo -e "     Telegraf Configuration File"
echo -e "======================================================"
echo -e "${CYAN}/etc/telegraf/telegraf.conf${RESET}"
echo -e "\n"

echo -e "======================================================"
echo -e "Please add the following line to the /etc/sudoers file"
echo -e "======================================================"
echo -e "${CYAN}${telegrafUSer} ALL=(ALL) NOPASSWD:ALL${RESET}"
echo -e "\n"

echo -e "======================================================"
echo -e "  Start Telegraf Service"
echo -e "======================================================"
echo -e "${CYAN}systemctl start telegraf${RESET}"
echo -e "\n"


echo -e "======================================================"
echo -e "  Telegraf logs"
echo -e "======================================================"
echo -e "${CYAN}/var/log/telegraf/telegraf.log${RESET}"
echo -e "\n"
#clean


