#!/bin/bash
# set -x # uncomment to enable debug

#####    Packages required: jq, bc
#####    Solana Validator Monitoring Script to be used with Telegraf / Grafana / InfluxDB
#####    Fetching data from Solana validators, outputs metrics in Influx Line Protocol on stdout
#####    Created: 13 Dec 2024 by logkeeper.io. Forked from https://github.com/stakeconomy/solanamonitoring.
#####    Fixed issues with solana latest versions. 2.1.5+
#####    Added help script which generates all required config files.

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
