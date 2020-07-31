#!/usr/bin/env bash
set -eo pipefail
http () {
	local path="${1}"
	if [ -n "${ELASTIC_USERNAME}" ] && [ -n "${ELASTIC_PASSWORD}" ]; then
		BASIC_AUTH="-u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}"
	else
		BASIC_AUTH=''
	fi
	curl -XGET -s -k --fail ${BASIC_AUTH} http://es-master.monitoring:9200${path}
}
cleanup () {
while true ; do
	local master="$(http "/_cat/master?h=node" || echo "")"
	if [[ $master == "es-master.monitoring"* && $master != "${NODE_NAME}" ]]; then
		echo "This node is not master."
		break
	fi
	echo "This node is still master, waiting gracefully for it to step down"
	sleep 1
done
exit 0
}
trap cleanup SIGTERM
sleep infinity &
wait $!
