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


# Auto detect values
solana_bin_dir="$(which solana|awk -F "bin" '{print $1}')bin"
solana_rpc_url="http://api.testnet.solana.com"
solana_config_dir="$HOME/.config/solana"

influx_database="solana"
influx_url="https://"
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
"Telegraf Influx Db Url:" 7 1 "${influx_url}" 7 30 70 70 \
"Telegraf InfluxDb Database:" 8 1 "${influx_database}" 8 30 70 70 \
"Telegraf InfluxDb Username:" 9 1 "" 9 30 70 70 \
"Telegraf InfluxDb Password:" 10 1 "" 10 30 70 70 \
2>&1 1>&3)

# Get dialog's exit status
return_value=$?

# Close file descriptor 3
exec 3>&-

# Act on the exit status
case $return_value in
  $DIALOG_OK)
    echo "$result" > test.txt
    binDir=$(head -n 1 test.txt |tail -1)
    rpcUrl=$(head -n 2 test.txt |tail -1)
    identityPub=$(head -n 3 test.txt |tail -1)
    votePub=$(head -n 4 test.txt |tail -1)
    configDir=$(head -n 5 test.txt |tail -1)
    export solanaBinDir=$binDir
    export rpcUrl=$rpcUrl
    export identityPub=$identityPub
    export votePub=$votePub
    export configDir=$configDir
    cat monitorTemplateHead.tpl | envsubst > head.sh
    cat head.sh > final.sh
    cat monitorTemplateBody.tpl >> final.sh
    rm head.sh
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
