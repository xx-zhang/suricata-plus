FROM alpine

RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata
	
ENV SURICATA_VERSION=6.0.3
#
# Include dist
ADD dist /root/dist/
#
# Install packages
#RUN sed -i 's/dl-cdn/dl-2/g' /etc/apk/repositories && \
RUN    apk -U add \
                 ca-certificates \
                 curl \
                 file \
                 geoip \
                 hiredis \
                 jansson \
                 libcap-ng \
                 libmagic \
		 libmaxminddb \
                 libnet \
                 libnetfilter_queue \
                 libnfnetlink \
                 libpcap \
                 luajit \
                 lz4-libs \
                 musl \
                 nspr \
                 nss \
                 pcre \
                 yaml \
                 wget \
                 automake \
                 autoconf \
                 build-base \
                 cargo \
                 file-dev \
                 geoip-dev \
                 hiredis-dev \
                 jansson-dev \
                 libtool \
                 libcap-ng-dev \
                 luajit-dev \
		 libmaxminddb-dev \
                 libpcap-dev \
                 libnet-dev \
                 libnetfilter_queue-dev \
                 libnfnetlink-dev \
                 lz4-dev \
                 nss-dev \
                 nspr-dev \
                 pcre-dev \
                 python3 \
                 rust \
                 yaml-dev && \
#
# We need latest libhtp[-dev] which is only available in community
    apk -U add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
               libhtp \
               libhtp-dev && \
#
# Upgrade pip, install suricata-update to meet deps, however we will not be using it 
# to reduce image (no python needed) and use the update script.
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir suricata-update && \
#
# Get and build Suricata
    mkdir -p /opt/builder/ && \
    wget https://www.openinfosecfoundation.org/download/suricata-${SURICATA_VERSION}.tar.gz && \
    tar xvfz suricata-${SURICATA_VERSION}.tar.gz --strip-components=1 -C /opt/builder/ && \
    rm suricata-${SURICATA_VERSION}.tar.gz && \
    cd /opt/builder && \
    ./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--mandir=/usr/share/man \
	--localstatedir=/var \
	--enable-non-bundled-htp \
	--enable-nfqueue \
        --enable-rust \
	--disable-gccmarch-native \
	--enable-hiredis \
	--enable-geoip \
	--enable-gccprotect \
	--enable-pie \
	--enable-luajit && \
    make && \
    make check && \
    make install && \
    make install-full && \
#
# Setup user, groups and configs
    addgroup -g 2000 suri && \
    adduser -S -H -u 2000 -D -g 2000 suri && \
    chmod 644 /etc/suricata/*.config && \
    cp /root/dist/suricata.yaml /etc/suricata/suricata.yaml && \
    cp /root/dist/*.bpf /etc/suricata/ && \
    mkdir -p /etc/suricata/rules && \
    cp /opt/builder/rules/* /etc/suricata/rules/ && \
#
# Download the latest EmergingThreats ruleset, replace rulebase and enable all rules
    cp /root/dist/update.sh /usr/bin/ && \
    chmod 755 /usr/bin/update.sh && \
    update.sh OPEN && \
#
# Clean up
    apk del --purge \
                 automake \
                 autoconf \
                 build-base \
                 cargo \
                 file-dev \
                 geoip-dev \
                 hiredis-dev \
                 jansson-dev \
                 libtool \
                 libhtp-dev \
                 libcap-ng-dev \
                 luajit-dev \
                 libpcap-dev \
		 libmaxminddb-dev \
                 libnet-dev \
                 libnetfilter_queue-dev \
                 libnfnetlink-dev \
                 lz4-dev \
                 nss-dev \
                 nspr-dev \
                 pcre-dev \
		 python3 \
                 rust \
                 yaml-dev && \
    rm -rf /opt/builder && \
    rm -rf /root/* && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*
#
# Start suricata
STOPSIGNAL SIGINT
CMD SURICATA_CAPTURE_FILTER=$(update.sh $OINKCODE) && exec suricata -v -F $SURICATA_CAPTURE_FILTER -i enp0s8



