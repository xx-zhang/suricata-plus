# 搭建参考
- [centos nginx git http server](https://www.cnblogs.com/fantesy84/p/6410984.html)


## docker 使用
```bash

docker run -itd -p 1180:80 --name=git-server \
  -v /git:/repository \
  registry.cn-beijing.aliyuncs.com/actanble/git-http-server:dev  \
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
```