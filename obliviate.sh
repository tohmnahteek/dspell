#!/bin/bash

#
# curl and jq is required 
#

SCOPE="channels"

if [ "$1" = "-g" ]; then
	SCOPE="guilds"
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")

CLIENT_FILE="$SCRIPT_DIR/client.json"

read -p "Enter channel: " CHANNEL

if [[ ! -f "$CLIENT_FILE" ]]; then
	read -p "Enter author: " AUTHOR
	read -sp "Enter token: " TOKEN
	echo
else
	AUTHOR=$(jq -r '.author' "$CLIENT_FILE")
	TOKEN=$(jq -r '.token' "$CLIENT_FILE")
fi

while true; do
	RESPONSE=$(curl -H "Authorization: $TOKEN"  "https://discord.com/api/v9/$SCOPE/$CHANNEL/messages/search?author_id=$AUTHOR")

	TOTAL_RESULTS=$(echo "$RESPONSE" | jq -r '.total_results')

	if [ "$TOTAL_RESULTS" -eq 0 ]; then
		break
	fi

	echo "$RESPONSE" | jq -c '.messages[]' | while read -r msg; do
		ID=$(echo "$msg" | jq -r '.[0].id')
		CHANNEL_ID=$(echo "$msg" | jq -r '.[0].channel_id')
		curl -X DELETE -H "Authorization: $TOKEN" "https://discord.com/api/v9/channels/$CHANNEL_ID/messages/$ID"
		sleep 5
	done
	echo
	
	sleep 120
done
