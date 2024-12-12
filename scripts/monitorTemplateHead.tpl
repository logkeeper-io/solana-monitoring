#!/bin/bash
# set -x # uncomment to enable debug

#####    Packages required: jq, bc
#####    Solana Validator Monitoring Script v.0.14 to be used with Telegraf / Grafana / InfluxDB
#####    Fetching data from Solana validators, outputs metrics in Influx Line Protocol on stdout
#####    Created: 14 Jan 18:28 CET 2021 by Stakeconomy.com. Forked from original Zabbix nodemonitor.sh script created by Stakezone
#####    For support post your questions in the #monitoring channel in the Solana discord server

#####    CONFIG    ##################################################################################################
configDir="${configDir}" # the directory for the config files, eg.: /home/user/.config/solana
##### optional:        #
identityPubkey="${identityPub}"      # identity pubkey for the validator, insert if autodiscovery fails
voteAccount="${votePub}"         # vote account address for the validator, specify if there are more than one or if autodiscovery fails
additionalInfo="on"    # set to 'on' for additional general metrics like balance on your vote and identity accounts, number of validator nodes, epoch number and percentage epoch elapsed
binDir="${solanaBinDir}"
rpcURL="${rpcUrl}"              # default is localhost with port number autodiscovered, alternatively it can be specified like http://custom.rpc.com:port
format="SOL"           # amounts shown in 'SOL' instead of lamports
now=$(date +%s%N)      # date in influx format
timezone="UTC"            # time zone for epoch ends metric
#####  END CONFIG  ##################################################################################################
