#!/bin/bash

# exit with message
exit_msg () {
	echo $1
	exit 1
}

# creates erlang notation of ip address without netmask
# 192.168.10.1/24 -> 192,168,10,1
ip_to_erlang() {
    echo $1 | sed 's/\./,/g' - | sed 's/\/.*$//g' - | sed 's/.*/{\0}/g' -
}

# creates erlang notation of network
# 192.168.10.1/24 -> {192, 168, 10, 1}, 24
net_to_erlang() {
    echo $1 | sed -e 's/\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\/\([0-9]\{1,2\}\)/{\1, \2, \3, \4}, \5/' - | sed 's/.*/{\0}/g' -
}


# convert domain name
# apn.example.net -> [<<"apn">>,<<"example">>,<<"net">>]
apn_to_erlang () {
  APN=""
  IFS='.' read -ra LABEL <<< $1
  for i in "${LABEL[@]}"; do
    if [ -z "$APN" ] ; then
      APN="[<<\"$i\">>"; 
    else
      APN+=",<<\"$i\">>"
    fi
  done
  APN+="]"
  echo $APN
}


# configuration parameter validation
# TODO: simplify by some generic parse function
[ -z "$PGW_S5C_IPADDR" ] && exit_msg "PGW_S5C_IPADDR is not set"
[ -z "$PGW_S5C_IFACE" ] && exit_msg "PGW_S5C_IFACE is not set"
[ -z "$PGW_CLIENT_IPADDR_START" ] && exit_msg "PGW_CLIENT_IPADDR_START is not set"
[ -z "$PGW_CLIENT_IPADDR_END" ] && exit_msg "PGW_CLIENT_IPADDR_END is not set"
[ -z "$PGW_CLIENT_PRIMARY_DNS" ] && exit_msg "PGW_CLIENT_PRIMARY_DNS is not set"
[ -z "$PGW_CLIENT_SECONDARY_DNS" ] && exit_msg "PGW_CLIENT_SECONDARY_DNS is not set"
[ -z "$PGW_CLIENT_PRIMARY_NBNS" ] && exit_msg "PGW_CLIENT_PRIMARY_NBNS is not set"
[ -z "$PGW_CLIENT_SECONDARY_NBNS" ] && exit_msg "PGW_CLIENT_SECONDARY_NBNS is not set"
[ -z "$PGW_APN" ] && exit_msg "PGW_APN is not set"

export PGW_S5C_IPADDR_ERL=`ip_to_erlang $PGW_S5C_IPADDR`
export PGW_CLIENT_IPADDR_START_ERL=`ip_to_erlang $PGW_CLIENT_IPADDR_START`
export PGW_CLIENT_IPADDR_END_ERL=`ip_to_erlang $PGW_CLIENT_IPADDR_END`
export PGW_CLIENT_PRIMARY_DNS_ERL=`ip_to_erlang $PGW_CLIENT_PRIMARY_DNS`
export PGW_CLIENT_SECONDARY_DNS_ERL=`ip_to_erlang $PGW_CLIENT_SECONDARY_DNS`
export PGW_CLIENT_PRIMARY_NBNS_ERL=`ip_to_erlang $PGW_CLIENT_PRIMARY_NBNS`
export PGW_CLIENT_SECONDARY_NBNS_ERL=`ip_to_erlang $PGW_CLIENT_SECONDARY_NBNS`
export PGW_APN_ERL=`apn_to_erlang $PGW_APN`

# create the config from template
envsubst < /config/pgw-c-node.config.templ > /etc/ergw-gtp-c-node/ergw-gtp-c-node.config

exec "$@"
