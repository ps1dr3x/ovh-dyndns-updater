#!/bin/bash

# Remember to add the cron:
# */5 * * * * /path/to/ovh-dyndns-updater.sh

DOMAIN=""
USERNAME=""
PASSWORD=""

LOG_FILE="/var/log/ovh-dyndns-updater.log"
NOW=$(date "+%d-%m-%y_%H:%M:%S")

IPV4_DNS=$(dig +short A $DOMAIN)
IPV6_DNS=$(dig +short AAAA $DOMAIN)

IPV4_CURRENT=$(curl -4 -s https://api.ipify.org)
IPV6_CURRENT=$(curl -6 -s https://api64.ipify.org)

UPDATE_RESULT=""

if [[ "$IPV4_DNS" == "" || "$IPV4_CURRENT" == "" ]]; then
    UPDATE_RESULT+="Empty response for IPV4_DNS and/or IPV4_CURRENT (IPV4_DNS: $IPV4_DNS IPV4_CURRENT: $IPV4_CURRENT), IPv4 update skipped. "
elif [[ "$IPV4_DNS" != "$IPV4_CURRENT" ]]; then
    UPDATE_RESULT+="Found a different IPv4. IPV4_DNS: $IPV4_DNS IPV4_CURRENT: $IPV4_CURRENT. "
    UPDATE_RESULT+="DNS update request's result: "$(curl -s "https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=$DOMAIN&myip=$IPV4_CURRENT" -u "$USERNAME:$PASSWORD")" "
else
    UPDATE_RESULT+="IPv4 is already up to date. "
fi

if [[ "$IPV6_DNS" == "" || "$IPV6_CURRENT" == "" ]]; then
    UPDATE_RESULT+="Empty response for IPV6_DNS and/or IPV6_CURRENT (IPV6_DNS: $IPV6_DNS IPV6_CURRENT: $IPV6_CURRENT), IPv6 update skipped. "
elif [[ "$IPV6_DNS" != "$IPV6_CURRENT" ]]; then
    UPDATE_RESULT+="Found a different IPv6. IPV6_DNS: $IPV6_DNS IPV6_CURRENT: $IPV6_CURRENT. "
    UPDATE_RESULT+="DNS update request's result: "$(curl -s "https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=$DOMAIN&myip=$IPV6_CURRENT" -u "$USERNAME:$PASSWORD")""
else
    UPDATE_RESULT+="IPv6 is already up to date."
fi

echo "$NOW: UPDATE_RESULT: $UPDATE_RESULT" >> "$LOG_FILE"
