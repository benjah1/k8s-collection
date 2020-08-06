#!/bin/bash
set -e
set -x
[ ! -d /var/lib/zookeeper/data ] && mkdir -m 770 /var/lib/zookeeper/data && chgrp $(stat -c '%g' /var/lib/zookeeper) /var/lib/zookeeper/data
[ -z "$ID_OFFSET" ] && ID_OFFSET=1
export ZOOKEEPER_SERVER_ID=$((${HOSTNAME##*-} + $ID_OFFSET))
echo "${ZOOKEEPER_SERVER_ID:-1}" | tee /var/lib/zookeeper/data/myid
cp -Lur /etc/kafka-configmap/* /etc/kafka/
[ ! -z "$PZOO_REPLICAS" ] && [ ! -z "$REPLICAS" ] && {
	sed -i "s/^server\\./#server./" /etc/kafka/zookeeper.properties
	for N in $(seq $PZOO_REPLICAS); do echo "server.$N=pzoo-$(( $N - 1 )).pzoo.$POD_NAMESPACE.svc.cluster.local:2888:3888:participant" >> /etc/kafka/zookeeper.properties; done
	for N in $(seq $(( $REPLICAS - $PZOO_REPLICAS ))); do echo "server.$(( $PZOO_REPLICAS + $N ))=zk-$(( $N - 1 )).zk.$POD_NAMESPACE.svc.cluster.local:2888:3888:participant" >> /etc/kafka/zookeeper.properties; done
}
ln -s /etc/kafka/zookeeper.properties /etc/kafka/zookeeper.properties.scale-$REPLICAS.$POD_NAME

