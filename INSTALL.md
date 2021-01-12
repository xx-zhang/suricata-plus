# 安装指南

> 参考官方文档和 `fedara` 构建者的过程

## install hyperscsan
```bash

LIB_TOOL_DIR='https://code.aliyun.com/rapidinstant/ids-tools/raw/master/docs/install_suricata'

## 安装 hyperscan ; https://www.cnblogs.com/yanhai307/p/10770821.html

wget $LIB_TOOL_DIR/ragel-6.10.tar.gz && \
    tar -zxf ragel-6.10.tar.gz && cd ragel-6.10 && \
    ./configure && make && make install

wget $LIB_TOOL_DIR/boost_1_69_0.tar.gz && \
    tar -zxf boost_1_69_0.tar.gz && cd boost_1_69_0 && ./bootstrap.sh && ./b2 --with-iostreams --with-random install && ldconfig

RUN wget $LIB_TOOL_DIR/hyperscan-5.2.1.tar.gz && tar -zxf hyperscan-5.2.1.tar.gz && \
    cd hyperscan-5.2.1 && \
    mkdir cmake-build && cd cmake-build  && cmake -DBUILD_SHARED_LIBS=on -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && make install && ldconfig
```

## install pfring 
```bash
# https://blog.csdn.net/qq_31507523/article/details/110092228 
cd PF_RING
make
# 这里可能会报错
# 说找不到……3.10.0-1127.el7.x86_64/build
# 上面已经显示过我的内核文件头为3.10.0-1160.6.1……
# 这个错是因为build是个软连接，连接的是3.10.0-1127.el7.x86_64版本的文件头，但系统没有这个文件头，需要手动更改
# 所以要更改一下kernel文件里面的软连接如下：
ln -s /usr/src/kernels/3.10.0-1160.6.1.el7.x86_64 /lib/modules/3.10.0-1127.el7.x86_64/build -f

make 
cd kernel 
make && make install

# 加载pf_ring模块
insmod pf_ring.ko

# Libpfring和Libpcap安装
cd ../userland/lib
./configure && make && make install
cd ../libpcap 
./configure && make && make install

# 运行验证是否成功
cd ../examples && make
./pfcount -i eth0


wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/LuaJIT-2.0.5.tar.gz && \
  tar -xzvf LuaJIT-2.0.5.tar.gz && cd LuaJIT-2.0.5 && make && make install 
  
```

## 增加hyperscan 
```bash

## 安装 hyperscan ; https://www.cnblogs.com/yanhai307/p/10770821.html
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz && \
    tar -zxf ragel-6.10.tar.gz && cd ragel-6.10 && \
    ./configure && make && make install
cd .. 

wget http://downloads.sourceforge.net/project/boost/boost/1.69.0/boost_1_69_0.tar.gz && \
    tar -zxf boost_1_69_0.tar.gz && cd boost_1_69_0 && ./bootstrap.sh && ./b2 --with-iostreams --with-random install && ldconfig
cd ..

wget https://codeload.github.com/intel/hyperscan/tar.gz/v5.2.1 && tar -zxf hyperscan-5.2.1.tar.gz && \
    cd hyperscan-5.2.1 && \
    mkdir cmake-build && cd cmake-build  && cmake -DBUILD_SHARED_LIBS=on -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && make install && ldconfig

cd ..

# SURICATA 
    --with-libhs-includes=/usr/local/include/hs/ \
    --with-libhs-libraries=/usr/local/lib/ \
```


## 编译suricata

```bash
# http://www.ntop.org/guides/pf_ring/thirdparty/suricata.html 

wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/suricata-6.0.1.tar.gz && \
# LIBS="-lrt -lnuma"

LIBS="-lrt" ./configure \
  --enable-geoip  \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --enable-pfring \
  --with-libpfring-includes=/usr/local/pfring/include \
  --with-libpfring-libraries=/usr/local/pfring/lib \
  --enable-luajit \
  --with-libluajit-includes=/usr/local/include/luajit-2.0/ \
  --with-libluajit-libraries=/usr/local/lib/ \
  --with-libhs-includes=/usr/local/include/hs/ \
  --with-libhs-libraries=/usr/local/lib/ \
  --enable-profiling \
  --enable-nfqueue
  
make clean && make && make install && ldconfig
make install-vhosts

cat > /etc/ld.vhosts.d/local.vhosts <<- EOF

/usr/local/lib 
EOF 

```

## pfring 运行
```bash

suricata -c /etc/suricata/suricata-ips.yaml -l /data/suricata-alerts -q 0 -D 
  
suricata -c /etc/suricata/suricata.yaml -s ips-http.rules -q 0

suricata -c /etc/suricata/suricata-ips.yaml -q 0 -D 
```

## IPS 模式
```bash

iptables -I INPUT -j NFQUEUE
iptables -I OUTPUT -j NFQUEUE

/usr/bin/suricata --pfring-int=eth0 --pfring-cluster-id=99 --pfring-cluster-type=cluster_flow -c /etc/suricata/suricata.yaml

# IPS 模式。
/usr/bin/suricata \
  --pfring-cluster-id=99 \
  --pfring-cluster-type=cluster_flow \
  -c /etc/suricata/suricata-ips.yaml -l /data/suricata-ips \
  -q 0 -D 

```
### suricata-ips 配置
```
//默认为0队列 
sudo iptables -I FORWARD -j NFQUEUE --queue-num 0 
sudo iptables -I INPUT -j NFQUEUE --queue-num 0 
sudo iptables -I OUTPUT -j NFQUEUE --queue-num 0

//也可指定协议 
sudo iptables -I INPUT -p tcp -j NFQUEUE --queue-num 0 
sudo iptables -I OUTPUT -p tcp -j NFQUEUE --queue-num 0

//同时指定端口号 
sudo iptables -I INPUT -p tcp --sport 80 -j NFQUEUE --queue-num 0 
sudo iptables -I OUTPUT -p tcp --dport 80 -j NFQUEUE --queue-num 0

//也可按照物理接口号指定 
sudo iptables -I FORWARD -i eth0 -o docker0 -j NFQUEUE 
sudo iptables -I FORWARD -i docker0 -o eth0 -j NFQUEUE

```

## tewt-rules
```
drop http any any -> 192.168.122.110 any (msg:"suricata-alert:Select Attack!!";content:"select";nocase;sid:800001;rev:1;) 
reject http any any -> 192.168.31.100 any (msg:" suricata-alert:Union Attack!!";content:"union";nocase;sid:800002;rev:1;) 
reject http any any -> 192.168.31.100 any (msg:" suricata-alert:SQL Injection Attack tries!!";content:"and";nocase;sid:800003;rev:1;) 
reject http any any -> 192.168.31.100 any (msg:" suricata-alert:SQL Injection Attack tries!!";content:"and";http_uri;nocase;sid:800004;rev:1;)
```