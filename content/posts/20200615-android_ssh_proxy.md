---
title: "把旧安卓打造为家用开机棒"
date: 2020-06-15
description: ""
tags: ["termux","linux","ssh","运维"]
categories: ["运维"]
draft: true
---

# 把旧安卓打造为家用开机棒

## 背景

## 硬件

魅族


## 软件

Android 5.1


termux

版本限定

root

开发者模式

不休眠

## 代理

### 远程端口转发

ssh config

autossh

### 升级版：解决端口占用问题

```bash
#! bash

set -x
set -e

if [ -z $PROXY_INTERVAL ];then
  PROXY_INTERVAL=60
fi

echo "=======================init proxy=========================="
while : ; do
  sshd
  rand_port=$(shuf -i 50040-50060 -n 1) ;
  echo "$rand_port" | ssh proxy1.isrc "cat >m2-ssh-port.txt" ;
  ssh -vNC -R 0.0.0.0:$rand_port:localhost:2222 proxy1.isrc ;
  sleep $PROXY_INTERVAL ;
  echo "=======================restart proxy=========================="
  echo "restart proxy1.isrc `date`" ;
done;
```

**连接命令：**

```bash
ssh -o "ProxyJump proxy.isrc" -p $(ssh proxy.isrc cat m2-ssh-port.txt) localhost
```

-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
