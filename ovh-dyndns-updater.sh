#!/bin/bash

# Remember to add the cron:
# */5 * * * * /path/to/ovh-dyndns-updater.sh

DOMAIN=""
USERNAME=""
PASSWORD=""

LOG_FILE="/var/log/update-dyndns-ovh.log"
LOG_TIMESTAMP=$(date +%s)

IPV4_DNS=$(dig +short A $DOMAIN)
IPV6_DNS=$(dig +short AAAA $DOMAIN)

IPV4_CURRENT=$(curl -4 -s https://api.ipify.org)
IPV6_CURRENT=$(curl -6 -s https://api64.ipify.org)

UPDATE_RESULT=""

if [[ "$IPV4_DNS" == "" || "$IPV4_CURRENT" == "" ]]; then
    UPDATE_RESULT+="Got an empty response for IPV4_DNS and/or IPV4_CURRENT (IPV4_DNS: $IPV4_DNS IPV4_CURRENT: $IPV4_CURRENT). Skipping IPv4 update.\n"
elif [[ "$IPV4_DNS" != "$IPV4_CURRENT" ]]; then
    UPDATE_RESULT+="Found a different IPv4. IPV4_DNS: $IPV4_DNS IPV4_CURRENT: $IPV4_CURRENT. Updating IPv4 DNS...\n"
    UPDATE_RESULT+=$(curl -s "https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=$DOMAIN&myip=$IPV4_CURRENT" -u "$USERNAME:$PASSWORD")"\n"
else
    UPDATE_RESULT+="IPv4 is already up to date.\n"
fi

if [[ "$IPV6_DNS" == "" || "$IPV6_CURRENT" == "" ]]; then
    UPDATE_RESULT+="Got an empty response for IPV6_DNS and/or IPV6_CURRENT (IPV6_DNS: $IPV6_DNS IPV6_CURRENT: $IPV6_CURRENT). Skipping IPv6 update.\n"
elif [[ "$IPV6_DNS" != "$IPV6_CURRENT" ]]; then
    UPDATE_RESULT+="Found a different IPv6. IPV6_DNS: $IPV6_DNS IPV6_CURRENT: $IPV6_CURRENT. Updating IPv6 DNS...\n"
    UPDATE_RESULT+=$(curl -s "https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=$DOMAIN&myip=$IPV6_CURRENT" -u "$USERNAME:$PASSWORD")"\n"
else
    UPDATE_RESULT+="IPv6 is already up to date.\n"
fi

echo "$LOG_TIMESTAMP: UPDATE_RESULT: $UPDATE_RESULT" >> "$LOG_FILE"
