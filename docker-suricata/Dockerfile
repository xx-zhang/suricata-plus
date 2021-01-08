FROM ubuntu:18.04
MAINTAINER xx-zhang <actanble@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV SURICATA_VERSION="5.0.0"

ADD sources.list /etc/apt/sources.list
RUN apt-get -yqq update
RUN apt-get -y install curl wget git zip unzip

# IDS 前提的一些安装的辅助包
RUN apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev \
build-essential autoconf automake libtool libpcap-dev libnet1-dev \
libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev \
pkg-config libcap-ng0 make libmagic-dev libjansson-dev libjansson4 pkg-config

# GEO 依赖
# RUN apt-get install libgeoip1 libgeoip-dev

## IPS 需要增加的编译条件
RUN apt-get -y install libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0

## 修复 Update 
RUN apt-get install rustc cargo -y

RUN cd /root/ && wget http://luajit.org/download/LuaJIT-2.0.5.tar.gz && \
    tar -zxf LuaJIT-2.0.5.tar.gz && \
    cd LuaJIT-2.0.5 && make && make install

# 安装 libhtp
RUN cd /root/ && wget https://github.com/OISF/libhtp/archive/0.5.31.tar.gz && \
    tar -zxf 0.5.31.tar.gz && cd libhtp-0.5.31/ && ./autogen.sh && ./configure && make && make install

## 安装 hyperscan ; https://www.cnblogs.com/yanhai307/p/10770821.html
RUN cd /root/ && wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz && \
    tar -zxf ragel-6.10.tar.gz && cd ragel-6.10 && \
    ./configure && make && make install

RUN cd /root/ && wget http://downloads.sourceforge.net/project/boost/boost/1.69.0/boost_1_69_0.tar.gz && \
    tar -zxf boost_1_69_0.tar.gz && cd boost_1_69_0 && ./bootstrap.sh && ./b2 --with-iostreams --with-random install && ldconfig

RUN wget https://codeload.github.com/intel/hyperscan/tar.gz/v5.2.1 && tar -zxf hyperscan-5.2.1.tar.gz && \
    cd hyperscan-5.2.1 && \
    mkdir cmake-build && cd cmake-build  && cmake -DBUILD_SHARED_LIBS=on -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && make install && ldconfig

## 安装 pfring
RUN apt-get install build-essential bison flex linux-headers-$(uname -r) -y
RUN cd /root/ && wget https://codeload.github.com/ntop/PF_RING/tar.gz/7.4.0 && \
    tar -zvf PF_RING-7.4.0.tar.gz && cd PF_RING-7.4.0 && make && cd kernel && make install && \
    cd ../userland/lib && ./configure --prefix=/usr/local/pfring  &&  make install && \
    cd ../libpcap-1.8.1/ && ./configure && make install &&  ldconfig

RUN cd /root/ && \
    wget https://www.openinfosecfoundation.org/download/suricata-${SURICATA_VERSION}.tar.gz && \
    tar -zxf suricata-${SURICATA_VERSION}.tar.gz && cd suricata-${SURICATA_VERSION} && \
    ./configure \
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
    --enable-profiling && \
    make && make install && ldconfig
    ## --enable-nfqueue --enable-geoip
#RUN rm -rf /root/*
# ldconfig Error
#RUN ln -sv `find / -type f -name "libpfring.so*" | grep /usr/local/` /usr/lib/libpfring.so.1
#RUN ln -sv `find / -type f -name "libluajit-5.1.so*" | grep /usr/local/` /usr/liblibhs.so.5

WORKDIR /root/



