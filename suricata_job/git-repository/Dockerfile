FROM centos:8

USER root
ENV LANG en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo && \
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo

RUN yum makecache && yum -y install epel-release
WORKDIR /root

RUN dnf --enablerepo=epel -y install nginx fcgiwrap supervisor git git-core

ADD ./nginx.conf /etc/nginx/nginx.conf
ADD ./vhosts /etc/nginx/vhosts
ADD ./supervisor_git.conf /etc/supervisor/supervisord.conf

#ADD ./repository /repository
RUN chmod 755 -R /repository

CMD ['/usr/bin/supervisord', '-c', '/etc/supervisor/supervisord.conf']
