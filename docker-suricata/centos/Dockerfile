FROM centos:centos7.9.2009 as build

USER root
ENV LANG en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
    curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
RUN yum makecache
RUN yum -y update
RUN yum -y install wget cmake3
WORKDIR /root

RUN yum -y install \
        autoconf \
        automake \
        cargo \
        file \
        file-devel \
        gcc \
        gcc-c++ \
        git \
        hiredis-devel \
        hyperscan-devel \
        jansson-devel \
        jq \
        lua-devel \
        libtool \
        libyaml-devel \
        libnfnetlink-devel \
        libnetfilter_queue-devel \
        libnet-devel \
        libcap-ng-devel \
        libevent-devel \
        libmaxminddb-devel \
        libpcap-devel \
        libprelude-devel \
        libtool \
        lz4-devel \
        make \
        nspr-devel \
        nss-devel \
        nss-softokn-devel \
        pcre-devel \
        pkgconfig \
        python3-devel \
        python3-yaml \
        rust \
        which \
        zlib-devel && \
        yum clean all

ADD cargo.config /root/.cargo/config
RUN /usr/bin/cargo install cbindgen && \
    ln -sf /root/.cargo/bin/cbindgen /usr/bin/cbindgen
RUN pip3 install Pyyaml -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /src

RUN git clone https://github.com/OISF/suricata.git --depth=1 && \
        cd suricata && \
            git clone https://github.com/OISF/libhtp.git --depth=1 && \
        cd suricata-update && \
            curl -L \
            https://github.com/OISF/suricata-update/archive/master.tar.gz | \
              tar zxf - --strip-components=1

WORKDIR /src/suricata
RUN ./autogen.sh
RUN ./configure \
        --prefix=/usr \
        --disable-shared \
        --disable-march-native \
        --enable-lua

ARG CORES=1
RUN make -j "${CORES}"
RUN make install install-conf DESTDIR=/fakeroot

# TODO 主要环境。
FROM centos:centos7.9.2009
USER root
ENV LANG en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root

RUN yum -y install \
        autoconf \
        automake \
        cargo \
        file \
        file-devel \
        gcc \
        gcc-c++ \
        hiredis-devel \
        hyperscan-devel \
        jansson-devel \
        jq \
        lua-devel \
        libtool \
        libyaml-devel \
        libnfnetlink-devel \
        libnetfilter_queue-devel \
        libnet-devel \
        libcap-ng-devel \
        libevent-devel \
        libmaxminddb-devel \
        libpcap-devel \
        libprelude-devel \
        libtool \
        lz4-devel \
        nspr-devel \
        nss-devel \
        nss-softokn-devel \
        pcre-devel \
        pkgconfig \
        rust \
        which \
        zlib-devel && \
        yum clean all

COPY --from=build /fakeroot /
COPY ./update.yaml /etc/suricata/update.yaml
COPY ./docker-entrypoint.sh /
COPY ./suricata.logrotate /etc/logrotate.d/suricata

RUN suricata-update update-sources && \
        suricata-update enable-source oisf/trafficid && \
        suricata-update --no-test --no-reload && \
        /usr/bin/suricata -V

RUN useradd --system --create-home suricata && \
        chown -R suricata:suricata /etc/suricata && \
        chown -R suricata:suricata /var/log/suricata && \
        chown -R suricata:suricata /var/lib/suricata && \
        chown -R suricata:suricata /var/run/suricata && \
        echo "suricata ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/suricata && \
        cp -a /etc/suricata /etc/suricata.dist && \
        chmod 600 /etc/logrotate.d/suricata

VOLUME /var/log/suricata
VOLUME /var/lib/suricata
VOLUME /etc/suricata

ENTRYPOINT ["/docker-entrypoint.sh"]