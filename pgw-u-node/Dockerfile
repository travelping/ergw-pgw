FROM ergw/ergw-gtp-u-node
RUN apt-get update && apt-get -y install iptables
ADD pgw-u-node.config.templ /config/
ADD docker-entrypoint.sh /
