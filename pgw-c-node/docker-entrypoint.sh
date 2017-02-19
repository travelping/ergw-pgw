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

parse_generic () {
  #echo parsing ${1}=${!1}
  [ -n "${!1}" ] || ( echo "env variable $1 is not set"; false )
}

parse_ip_addr () {
  #TODO: some more validation for IP addresses
  parse_generic $1 && eval export ${1}_ERL=\"$(ip_to_erlang ${!1})\"
}

parse_apn () {
  parse_generic $1 || return 1
  printf -v ${1}_ERL "$(apn_to_erlang ${!1})"
  export ${1}_ERL
}



# configuration parameter validation


VALIDATION_ERROR=""

parse_generic PGW_S5C_IFACE || VALIDATION_ERROR=1
parse_apn PGW_APN || VALIDATION_ERROR=1

PARAMS_IPADDR="
    PGW_S5C_IPADDR
    PGW_CLIENT_IPADDR_START
    PGW_CLIENT_IPADDR_END
    PGW_CLIENT_PRIMARY_DNS
    PGW_CLIENT_SECONDARY_DNS
    PGW_CLIENT_PRIMARY_NBNS
    PGW_CLIENT_SECONDARY_NBNS
  "
for var in $PARAMS_IPADDR; do
  parse_ip_addr $var || VALIDATION_ERROR=1
done

[ -n "$VALIDATION_ERROR" ] && exit_msg "Exiting due to missing configuration parameters"



# create the config from template
envsubst < /config/pgw-c-node.config.templ > /etc/ergw-gtp-c-node/ergw-gtp-c-node.config

exec "$@"
