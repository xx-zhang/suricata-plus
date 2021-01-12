#!/bin/bash 

# 获取最新的最权威的全部规则集;进行收集

mkdir -p /opt/suri_main_rule && cd /opt/suri_main_rule && \
    git clone https://github.com/suricata-rules/suricata-rules && \
    wget https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.tar.gz && tar xf emerging.rules.tar.gz && \
    git clone https://github.com/ptresearch/AttackDetection && \
    git clone https://code.aliyun.com/rapidinstant/web-attack-rules.git

# git clone https://github.com/travisbgreen/hunting-rules 
# git clone https://github.com/jasonish/suricata-trafficid

# suricata-update list-sources 可以查看付费的很多规则集。