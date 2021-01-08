
export LANG en_US.UTF-8
ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum makecache && yum -y update && yum -y install wget cmake3

yum -y install autoconf automake libtool pkgconfig \
        rust cargo file file-devel \
        gcc gcc-c++ git hiredis-devel hyperscan-devel \
        jansson-devel jq lua-devel libyaml-devel zlib-devel \
        libnfnetlink-devel libnetfilter_queue-devel \
        libnet-devel  libcap-ng-devel \
        libevent-devel libmaxminddb-devel \
        libpcap-devel  libprelude-devel \
        lz4-devel make nspr-devel nss-devel nss-softokn-devel \
        pcre-devel  python3 python3-pip python3-devel \
        which  && \
        yum clean all

yum install -y libpcap zlib libyaml libpcap-devel \
  jansson-devel pcre-devel lua-devel \
  libmaxminddb-devel epel-release  libnetfilter_queue-devel nss-devel \
  libyaml-devel zlib-devel luajit-devel

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


cd /src && git clone https://github.com/OISF/suricata.git --depth=1 && \
        cd suricata && \
            git clone https://github.com/OISF/libhtp.git --depth=1 && \
        cd suricata-update && \
            curl -L \
            https://github.com/OISF/suricata-update/archive/master.tar.gz | \
              tar zxf - --strip-components=1

wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/PF_RING-7.8.0.tar.gz  && \
tar -xf PF_RING-7.8.0.tar.gz && cd PF_RING-7.8.0 && make && cd kernel \
    && make install && \
    cd ../userland/lib && ./configure  &&  make install && \
    cd ../libpcap && ./configure && make install &&  ldconfig

wget -c -N https://code.aliyun.com/rapidinstant/ids-tools/raw/master/datas/LuaJIT-2.0.5.tar.gz && \
  tar -xzvf LuaJIT-2.0.5.tar.gz && cd LuaJIT-2.0.5 && make && make install

cd /src/suricata && ./autogen.sh && \
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

cat > /etc/ld.conf.d/local.conf <<- EOF

/usr/local/lib
EOF


