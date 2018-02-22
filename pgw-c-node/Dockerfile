FROM ergw/ergw-gtp-c-node:master
RUN apk update && apk add bash gettext
ADD pgw-c-node.config.templ /config/
ADD docker-entrypoint.sh /
