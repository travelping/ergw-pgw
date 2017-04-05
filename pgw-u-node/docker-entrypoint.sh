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


parse_generic () {
	#echo parsing ${1}=${!1}
	[ -n "${!1}" ] || ( echo "env variable $1 is not set"; false )
}

parse_ip_net () {
	#TODO: some more validation for IP networks
	parse_generic $1 && eval export ${1}_ERL=\"$(net_to_erlang ${!1})\"
}

parse_ip_addr () {
	#TODO: some more validation for IP addresses
	parse_generic $1 && eval export ${1}_ERL=\"$(ip_to_erlang ${!1})\"
}

VALIDATION_ERROR=""

parse_ip_addr PGW_S5U_IPADDR || VALIDATION_ERROR=1
parse_generic PGW_S5U_IFACE || VALIDATION_ERROR=1
parse_ip_net PGW_CLIENT_IP_NET || VALIDATION_ERROR=1

[ -n "$VALIDATION_ERROR" ] && exit_msg "Exiting due to missing configuration parameters"

# create the config from template
envsubst < /config/pgw-u-node.config.templ > /etc/ergw-gtp-u-node/ergw-gtp-u-node.config

# unload gtp module as reset; will be reloaded on start of application
#rmmod gtp

exec "$@"
