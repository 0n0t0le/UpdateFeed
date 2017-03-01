#!/bin/bash

# Load env vars
source $HOME/.bash_profile

# cli_wallet --rpc-http-endpoint url
if [ -z $GOLOS_WALLET ]; then
	echo "ERROR: Golos wallet is not set"
	exit 1
fi
WALLET=$GOLOS_WALLET

# cli_wallet unlock password
if [ -z $GOLOS_PASSWORD ]; then
	echo "ERROR: Golos wallet password is not set"
	exit 1
fi
PASSWORD=$GOLOS_PASSWORD

# publish_feed nickname:
if [ -z $GOLOS_WITNESS ]; then
	echo "ERROR: Golos witness name is not set"
	exit 1
fi
NICKNAME=$GOLOS_WITNESS

function is_locked {
	LOCKED=`curl -s --data-binary '{"id":"1","method":"is_locked","params":[""]}' "$WALLET" | jq -r '.result'`
}

function checkLockAndExit {
	if [ "$EXITLOCK" = true ]; then
		echo -n "Locking wallet again..."
		curl -s --data-binary '{"id":0,"method":"lock","params":[]}' "$WALLET" > /dev/null
		echo ""
		echo "Locked."
	fi
	exit
}

function getGbgGolosPrice {
	GBG_GOLOS=$(curl -s 'http://steemul.ru/price/gbg/' | awk '{printf "%.3f", $0}')
}

is_locked
if [ "$LOCKED" == "true" ]; then
	EXITLOCK=true
	echo -n "Wallet is locked. Trying to unlock..."
	curl -s --data-binary '{"id":"1","method":"unlock","params":["'"$PASSWORD"'"]}' "$WALLET" > /dev/null
	echo ""
	is_locked
	if [ "$LOCKED" == "true" ]; then
		echo "Can't unlock wallet, exiting."
		exit 1
	else
		echo "Wallet unlocked."
	fi
else
	if [ "$LOCKED" == "false" ]; then
		EXITLOCK=false
		echo "Wallet was unlocked before."
	else
		echo "Some error. Is cli_wallet running? Exit."
		exit 1
	fi
fi


# Getting input data
getGbgGolosPrice

# Publish
BASE="1.000"
QUOTE=$GBG_GOLOS

PUB=`curl -s --data-binary '{"id":"2","method":"publish_feed","params":["'"$NICKNAME"'",{"base":"'"$BASE GBG"'", "quote":"'"$QUOTE GOLOS"'"}, true],"jsonrpc":"2.0"}' "$WALLET" | jq -r '.id'`
if [ $PUB -eq 2 ]; then
	echo "Feed was updated successfully. 'base'=${BASE} 'quote'=${QUOTE}"		
else
	echo "Some error. Feed wasn't updated."		
fi

checkLockAndExit
