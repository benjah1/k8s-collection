#!/bin/bash
set -e
set -x
cp /etc/kafka-configmap/log4j.properties /etc/kafka/
KAFKA_BROKER_ID=${HOSTNAME##*-}
SEDS=("s/#init#broker.id=#init#/broker.id=$KAFKA_BROKER_ID/")
LABELS="kafka-broker-id=$KAFKA_BROKER_ID"
ANNOTATIONS=""
printf '%s\n' "${SEDS[@]}" | sed -f - /etc/kafka-configmap/server.properties > /etc/kafka/server.properties.tmp
[ $? -eq 0 ] && mv /etc/kafka/server.properties.tmp /etc/kafka/server.properties
ln -s /etc/kafka/server.properties /etc/kafka/server.properties.$POD_NAME

