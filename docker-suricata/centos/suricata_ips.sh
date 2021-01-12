#!/bin/bash

function  init_centos() {
    export LANG en_US.UTF-8
  ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone
  curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  yum makecache && yum -y update && yum -y install wget cmake3 cmake
}

function install_deps() {
    yum -y install autoconf automake libtool pkgconfig \
        rust cargo file file-devel \
        gcc gcc-c++ git hiredis-devel \
        jansson-devel jq lua-devel libyaml-devel zlib-devel \
        libnfnetlink-devel libnetfilter_queue-devel \
        libnet-devel  libcap-ng-devel \
        libevent-devel libmaxminddb-devel \
        libpcap-devel  libprelude-devel \
        lz4-devel make nspr-devel nss-devel nss-softokn-devel \
        pcre-devel python3 python3-pip python3-devel \
        which  && \
        yum clean all

  yum install -y libpcap zlib libyaml \
    jansson-devel pcre-devel lua-devel \
    libmaxminddb-devel epel-release  libnetfilter_queue-devel nss-devel \
    libyaml-devel zlib-devel && \
        yum clean all

  yum install -y flex bisson kernel-devel
}


function install_cargo() {
  mkdir -p /root/.cargo/
    cat > /root/.cargo/config <<- EOF

[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'tuna'

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

EOF

/usr/bin/cargo install cbindgen && \
    ln -sf /root/.cargo/bin/cbindgen /usr/bin/cbindgen

pip3 install Pyyaml -i https://pypi.tuna.tsinghua.edu.cn/simple

}

function install_luajit() {
  cd /srv

    wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/LuaJIT-2.0.5.tar.gz && \
  tar -xzvf LuaJIT-2.0.5.tar.gz && cd LuaJIT-2.0.5 && make && make install
}

function install_hyperscan(){

  cd /srv

  LIB_TOOL_DIR='https://code.aliyun.com/rapidinstant/ids-tools/raw/master/docs/install-suricata/'

  ## 安装 hyperscan ; https://www.cnblogs.com/yanhai307/p/10770821.html

  wget $LIB_TOOL_DIR/ragel-6.10.tar.gz && \
      tar -zxf ragel-6.10.tar.gz && cd ragel-6.10 && \
      ./configure && make && make install

  cd ..

  wget $LIB_TOOL_DIR/boost_1_69_0.tar.gz && \
      tar -zxf boost_1_69_0.tar.gz && cd boost_1_69_0 && ./bootstrap.sh && ./b2 --with-iostreams --with-random install && ldconfig
  cd ..

  wget $LIB_TOOL_DIR/hyperscan-5.2.1.tar.gz && tar -zxf hyperscan-5.2.1.tar.gz && \
      cd hyperscan-5.2.1 && \
      mkdir cmake-build && cd cmake-build  && cmake -DBUILD_SHARED_LIBS=on -DCMAKE_BUILD_TYPE=Release .. && \
      make -j8 && make install && ldconfig
  cd ..

}

function install_pfring(){
  ln -sf $(find /usr/src/kernels/ -maxdepth 1 | grep el7.x86_64) /lib/modules/3.10.0-1127.el7.x86_64/build
  wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/PF_RING-7.8.0.tar.gz  && \
tar -xf PF_RING-7.8.0.tar.gz && \
    cd PF_RING-7.8.0 && make -j2 && cd kernel && make install && \
    insmod pf_ring.ko && \
    cd ../userland/lib && ./configure  &&  make install && \
    cd ../libpcap && ./configure && make install &&  ldconfig
}

function download_suricata() {
    cd /srv && git clone https://github.com/OISF/suricata.git --depth=1 && \
        cd suricata && \
            git clone https://github.com/OISF/libhtp.git --depth=1 && \
        cd suricata-update && \
            curl -L \
            https://github.com/OISF/suricata-update/archive/master.tar.gz | \
              tar zxf - --strip-components=1
}


function install_suricata() {
    cd /srv/suricata && ./autogen.sh && \
  LIBS="-lrt" ./configure  \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --enable-pfring \
  --with-libpfring-includes=/usr/local/pfring/include \
  --with-libpfring-libraries=/usr/local/pfring/lib \
  --enable-geoip  \
  --enable-luajit \
  --with-libluajit-includes=/usr/local/include/luajit-2.0/ \
  --with-libluajit-libraries=/usr/local/lib/ \
  --with-libhs-includes=/usr/local/include/hs/ \
  --with-libhs-libraries=/usr/local/lib/ \
  --enable-profiling --enable-nfqueue


make clean && make -j 2 && make install && ldconfig
make install-conf

cat > /etc/ld.so.conf.d/local.conf <<- EOF

/usr/local/lib
EOF

}

function changelog() {
cat << EndOfCL
    # 01.06.2021 - First commit
EndOfCL
}

function usage() {
cat << EndOfHelp
    Usage: $0 <func_name> <args> | tee $0.log
    Commands - are case insensitive:
        All - <username_optional> - Execs QEMU/SeaBios/KVM, username is optional
        QEMU - Install QEMU from source,
            DEFAULT support are x86 and x64, set ENV var QEMU_TARGERS=all to install for all arches
        SeaBios - Install SeaBios and repalce QEMU bios file
        Libvirt <username_optional> - install libvirt, username is optional
EndOfHelp
}

case "$COMMAND" in
'base')
    install_deps
    ;;
'all')
    echo 'install all'
    ;;
'pfring')
    install_pfring;;
'luajit')
    install_luajit;;
'cargo')
    install_cargo;;
'suricata')
    download_suricata;
    install_suricata ;
    ;;
*)
    usage;;
esac


