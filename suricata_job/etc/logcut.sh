#!/bin/bash

if [ ! -d /data/suricata-ips/old ]; then
   mkdir -p /data/suricata-ips/old
fi

function suricata_logcut
{
  cd /data/suricata-ips && \
  mv eve.json suricata-eve.json && \
  ps -ef | grep suricata | grep -v grep | awk '{print $2}' | xargs kill -HUP && \
  tar czf /data/suricata-ips/old/suricata-logs-$(date +%Y%m%d%H).tar.gz suricata-eve.json && \
  rm -rf suricata-eve.json
}

suricata_logcut