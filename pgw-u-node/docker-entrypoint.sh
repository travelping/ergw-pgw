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


# configuration parameter validation
[ -z "$PGW_S5U_IPADDR" ] && exit_msg "PGW_S5U_IPADDR is not set"
[ -z "$PGW_S5U_IFACE" ] && exit_msg "PGW_S5U_IFACE is not set"
[ -z "$PGW_CLIENT_IP_NET" ] && exit_msg "PGW_CLIENT_IP_NET is not set"

export PGW_S5U_IPADDR_ERL=`ip_to_erlang $PGW_S5U_IPADDR`
export PGW_CLIENT_IP_NET_ERL=`net_to_erlang $PGW_CLIENT_IP_NET`

# create the config from template
envsubst < /config/pgw-u-node.config.templ > /etc/ergw-gtp-u-node/ergw-gtp-u-node.config

exec "$@"
