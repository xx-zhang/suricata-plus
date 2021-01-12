#!/bin/bash

if [ ! -d /var/log/suricata/old ]; then
   mkdir -p /var/log/suricata/old
fi

function suricata_logcut
{
  cd /var/log/suricata/ && \
  mv eve.json suricata-eve.json && \
  ps -ef | grep suricata | grep -v grep | awk '{print $2}' | xargs kill -HUP && \
  tar czf /var/log/suricata/old/suricata-logs-$(date +%Y%m%d%H).tar.gz suricata-eve.json && \
  rm -rf suricata-eve.json
}

suricata_logcut