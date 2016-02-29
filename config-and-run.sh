#!/bin/bash
set -e

function iptoid() {
  # strip first component to make it smaller
  IP=${1#*.}
  IPNUM=0
  for (( i=0 ; i<3 ; ++i )); do
      ((IPNUM+=${IP%%.*}*$((256**$((2-${i}))))))
      IP=${IP#*.}
  done
  echo $IPNUM 
}

export MY_IP=$(ip a show dev eth0 | awk '/ inet / {print $2}' | cut -d/ -f1)
export SERVER_ID=$(iptoid $MY_IP)

echo "Starting kafka broker with the following config:"
echo "ZOOKEEPER_URLS: $ZOOKEEPER_URLS"
echo "MY_IP: $MY_IP"
echo "SERVER_ID: $SERVER_ID"

# Substitute vars in configuration file
# two times because of nested vars
envsubst < /opt/kafka/config/server-template.properties | envsubst \
    > /opt/kafka/config/server.properties

echo "CONFIG:"
cat /opt/kafka/config/server.properties

echo
echo

exec /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
