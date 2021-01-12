# 规则管理


## 增加 `disable` 管理生成一个管理规则集合。

## 初始当前使用的规则集

```bash
wget -c -N https://rules.emergingthreats.net/open/suricata-5.0/emerging.rules.tar.gz && \
  tar xf emerging.rules.tar.gz && mv rules/ etopen-rules && \
git clone https://github.com/suricata-rules/suricata-rules --depth=1  && \
git clone https://github.com/travisbgreen/hunting-rules  && \
 git clone https://github.com/jasonish/suricata-trafficid  && \
  git clone https://github.com/ptresearch/AttackDetection && \
git clone  https://code.aliyun.com/rapidinstant/web-attack-rules.git 

```

## 