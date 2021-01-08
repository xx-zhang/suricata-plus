# Suricata Docker镜像搭建

- [构建链接](https://cr.console.aliyun.com/repository/cn-hangzhou/rapid7/suricata/details)

## 下载
```bash 
docker pull registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:5.0.0
```

## 使用【2019-11-26-A】
```bash 
docker run -itd \
-v /opt/suricata/etc/:/opt/suricata/etc/ \
-v /opt/suricata/var/:/opt/suricata/var/ \
--net=host \
--name=suri \
registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:5.0.0 \
/opt/suricata/usr/bin/suricata \
-c /opt/suricata/etc/suricata/suricata.yaml \
-i ens32 >> /dev/null
```

## 2019-11-27 Docker
```
cd /root/ && \
    wget https://www.openinfosecfoundation.org/download/suricata-5.0.0.tar.gz && \
    tar zxvf suricata-5.0.0.tar.gz && cd suricata-5.0.0 && \
    ./configure \
        --enable-luajit \
        --with-libnss-libraries=/usr/lib \
        --with-libnss-includes=/usr/include/nss/ \
        --with-libnspr-libraries=/usr/lib \
        --with-libnspr-includes=/usr/include/nspr \
        --with-libluajit-includes=/usr/local/include/luajit-2.0/ \
        --with-libluajit-libraries=/usr/local/lib/ \
        --enable-nfqueue \
        --prefix=/opt/suricata/usr \
        --sysconfdir=/opt/suricata/etc \
        --localstatedir=/opt/suricata/var && \
    make && make install && ldconfig
```

## 2019-12-12
- 开始准备 2g 3000 条力度下得测试。


## 2019-12-10

```bash 
docker run -itd --name=suri --net=host --restart=always \
  --memory=2g --memory-swap=4g \
    -v /etc/localtime:/etc/localtime:ro \
    -v $(pwd)/suricata.yaml:/etc/suricata/suricata.yaml \
    -v $(pwd)/sruicata-4977.rules:/var/lib/suricata/rules/suricata.rules \
    -v /home/logs/log-2g-i5000:/var/log/suricata \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:alpine \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml -i p2p1
    
docker run -itd --name=suri --net=host --restart=always \
  --memory=2g \
    -v /etc/localtime:/etc/localtime:ro \
    -v $(pwd)/suricata.yaml:/etc/suricata/suricata.yaml \
    -v $(pwd)/sruicata-4977.rules:/var/lib/suricata/rules/suricata.rules \
    -v /home/logs/log-2g-i5000:/var/log/suricata \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:alpine \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml -i p2p1
```

## 2019-12-16
```bash 
docker run -itd --name=suri --net=host --restart=always \
  --memory=4g \
   --cpuset-cpus="2,3" \
   -v /etc/localtime:/etc/localtime:ro \
    -v $(pwd)/suricata_pfring.yaml:/etc/suricata/suricata.yaml \
    -v $(pwd)/suricata.bak.rules:/var/lib/suricata/rules/suricata.rules \
    -v /data/suricata/:/var/log/suricata \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:alpine \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml -i enp7s0 -D -v 
```

```bash 
docker run -itd --name=suri \
  --net=host --privileged=true --restart=always \
   -v /etc/localtime:/etc/localtime:ro \
    -v $(pwd)/suricata.yaml:/etc/suricata/suricata.yaml \
    -v $(pwd)/test.rules:/var/lib/suricata/rules/test.rules \
    -v /var/run/suricata.pid:/var/run/suricata.pid \
    -v /data/suricata/:/var/log/suricata \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:alpine \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml -i ens32 -v \
    --pidfile=/var/run/suricata.pid
```

## 2020-1-4

```bash 
docker run -itd --name=suri \
   --net=host --privileged=true --restart=always \
   -v /etc/localtime:/etc/localtime:ro \
    -v /etc/suricata/suricata_pfring.yaml:/etc/suricata/suricata.yaml \
    -v /data/suricata/:/var/log/suricata \
    -v /var/lib/suricata/rules:/var/lib/suricata/rules \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:4 \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml \
    -i ens32 -v >> /data/suricata/suricata.log 2>&1
    
docker run -itd --name=suri  \
    --net=host \
    --cap-add=net_admin --cap-add=sys_nice \
    --privileged=true \
    --restart=always   \
    -v /etc/localtime:/etc/localtime:ro    \
    -v $(pwd)/suricata.yaml:/etc/suricata/suricata.yaml   \
    -v $(pwd)/rules/:/var/lib/suricata/rules/   \
    -v /data/suricata/:/var/log/suricata   \
    registry.cn-hangzhou.aliyuncs.com/rapid7/suricata:4  \
    /usr/bin/suricata -c /etc/suricata/suricata.yaml -i enp7s0 -v
```


## 2021-1-8
- 今天回头看看，发现那时候还是很强。最近一年进步渺小。
  - NTA 这块儿一年来都没怎么积累。
