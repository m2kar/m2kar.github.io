---
title: "[工具]EMAGNET：从Pastebin上传的泄漏数据库中捕获电子邮件地址和密码"
date: 2019-09-20T10:54:24+08:00
lastmod: 2019-09-20T10:54:24+08:00
draft: true
keywords: ["工具","EMAGNET","复现"]
description: ""
tags: []
categories: ["工具"]
author: "m2kar <m2kar.cn@gmail.com>"

---

# 介绍
Emagnet是一款非常强大的工具，其主要目的是从pastebin上传的泄漏数据库中捕获电子邮件地址和密码。当密码在pastebin.com上不在列表中时，几乎不可能找到泄露的密码。他们已被pastebin的技术人员删除，或仅仅只有个别人上传。说实话，这比在大海中捞针要容易，然后使用我们想要收集的数据在pastebin上查找过时的上传内容。

# # 安装运行

**环境**: Kali Linux

```bash
git clone https://github.com/wuseman/emagnet
cd emagnet
chmod +x emagnet*

./emagnet --emagnet
```

![1568950222186](1568950222186.png)

运行失败,提示IP被锁


## 发现邮箱

```
./emagnet -e
```

## 后台运行



![1568960925457](1568960925457.png)

## docker 运行

```dockerfile
FROM "ubuntu:18.04"
MAINTAINER "M2kar<m2kar.cn@gmail.com>"
ARG EMAGNET_VERSION=3.4
RUN apt update \
    && apt-get install -y --no-install-recommends \
        inetutils-ping \
        wget \
        curl \
        screen \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN curl https://codeload.github.com/wuseman/EMAGNET/tar.gz/${EMAGNET_VERSION} > /tmp/emagnet.tar.gz \
    && tar -xzv -f /tmp/emagnet.tar.gz -C / \
    && ln -s /EMAGNET-${EMAGNET_VERSION} /EMAGNET
WORKDIR  /EMAGNET
CMD ["/EMAGNET/emagnet","--emagnet"]

```

# TODO 目前还没有出来的结果

# 参考

1. [Github] EMAGNET https://github.com/wuseman/EMAGNET
2. EMAGNET：从Pastebin上传的泄漏数据库中捕获电子邮件地址和密码 https://www.freebuf.com/sectool/213048.html



