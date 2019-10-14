FROM debian:buster-slim

ARG AMAZON_CORRETTO_URL=https://d3pxv6yz143wms.cloudfront.net/11.0.3.7.1/amazon-corretto-11.0.3.7.1-linux-x64.tar.gz
ARG DEBIAN_MIRROR=mirrors.ustc.edu.cn

LABEL MAINTAINER="Jarrod Quan <jarrodquan@gmail.com>"

ENV LANG=zh_CN.UTF-8
ENV TZ=Asia/Shanghai
ENV JAVA_HOME=/usr/local/lib/amazon-corretto-11

#更新镜像源并升级所有软件包
RUN set DEBIAN_FRONTEND=noninteractive \
  && sed -i "s/deb.debian.org/${DEBIAN_MIRROR}/g" /etc/apt/sources.list \
  && sed -i "s/security.debian.org/${DEBIAN_MIRROR}/g" /etc/apt/sources.list \
  && apt-get update \
  && apt-get upgrade -y

#添加国际化和时区支持
RUN apt-get install --no-install-recommends -y apt-utils locales tzdata \
  && sed -i "s/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/" /etc/locale.gen \
  && locale-gen

#移除不必要的软件
RUN apt-get remove --purge -y apt-utils \
  && apt-get autoremove -y \
  && apt-get autoclean \
  && unset DEBIAN_FRONTEND=noninteractive

#获取并配置Amazon Corretto 11
ADD ${AMAZON_CORRETTO_URL} /usr/local/lib/amazon-corretto-11.tar.gz
RUN mkdir -p /usr/local/lib/amazon-corretto-11 \
  && tar -zxf /usr/local/lib/amazon-corretto-11.tar.gz -C /usr/local/lib/amazon-corretto-11 \
  && mv /usr/local/lib/amazon-corretto-11/amazon-corretto-11.0.3.7.1-linux-x64/* /usr/local/lib/amazon-corretto-11 \
  && rm -rf /usr/local/lib/amazon-corretto-11.tar.gz /usr/local/lib/amazon-corretto-11/amazon-corretto-11.0.3.7.1-linux-x64 \
  && ln -s ${JAVA_HOME}/bin/java /usr/local/bin/java \
  && ln -s ${JAVA_HOME}/bin/javac /usr/local/bin/javac

CMD ["/bin/bash"]