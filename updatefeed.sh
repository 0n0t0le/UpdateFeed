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

# ICO settings
ICO_ADDRESS="3CWicRKHQqcj1N6fT1pC9J3hUzHw1KyPv3"
ICO_TOKENS=45120000

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

function getGoldMgPrice {
	local XAUOZ=`curl -s 'http://data-asg.goldprice.org/GetData/USD-XAU/1' | jq -r '.[0]' | cut -d ',' -f 2`
	local GRAMM_IN_OZ=31.1034768
	XAUMG=$(echo "scale=10 ; $XAUOZ / $GRAMM_IN_OZ / 1000" | bc)
}

function getIcoBalance {
	#ICO_BALANCE=`curl -s 'http://btc.blockr.io/api/v1/address/balance/3CWicRKHQqcj1N6fT1pC9J3hUzHw1KyPv3?confirmations=2' | jq -r '.data.balance'`
	ICO_BALANCE=600.18
}

function getBtcUsdPrice {
	BTC_USD=`curl -s 'https://btc-e.com/api/3/ticker/btc_usd-btc_btc?ignore_invalid=1' | jq -r '.btc_usd.last'`
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
getGoldMgPrice
getIcoBalance
getBtcUsdPrice

# Calc
GOLOS_USD=$(echo "scale=10 ; $ICO_BALANCE * $BTC_USD / $ICO_TOKENS" | bc)
GBG_GOLOS=$(echo "scale=3 ; $XAUMG / $GOLOS_USD" | bc)

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
