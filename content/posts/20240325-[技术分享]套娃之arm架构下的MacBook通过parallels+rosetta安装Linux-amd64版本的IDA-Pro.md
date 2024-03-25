---
title: "[技术分享]套娃之arm架构下的MacBook通过parallels+rosetta安装Linux amd64版本的IDA Pro"
date: 2024-03-25T13:39:45Z

description: 
tags: []
issueId: 26
---

# 前言
苹果公司在MacBook这种生产力平台使用无疑是个伟大且大胆的创新，经过几年的软件生态环境的改善，各种常用工具基本都能在mac下运行。但仍有些闭源发布的软件仍需要在amd64架构下的Linux环境中才能运行，比如本文中的IDA Pro 7.6版，因此整理一下踩坑记录，可供相关需求的同学参考。

# 环境和工具
- MacBook with M3 chip
- parallels Desktop 19
- IDA Pro 8.3 for Linux 安装包

# 支持amd64的Linux环境
parallels是Mac生态下非常好用的虚拟机软件，但之前的版本仅支持运行arm架构的虚拟机，不支持amd64的程序。在parallels的v19版本之后，基于[苹果官方提供的支持](https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta), parallels推出了[在arm虚拟机中运行amd64程序的能力](https://kb.parallels.com/en/129871)，并提供了一套配置好了的ubuntu 22.04虚拟机镜像。

因此，我们只需要点击创建虚拟机，下载Ubuntu with x86_emulation，即可获得amd64的模拟运行环境。如下图。
<img width="872" alt="image" src="https://github.com/m2kar/m2kar.github.io/assets/16930652/d8e4710c-c9ca-4d28-b9df-d2c1ccac175a">

# 安装IDA pro
打开安装好的虚拟机，把安装包拷贝进来，在终端中运行。

```bash
idapronl_xxx.run
```

但直接报错： `rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2`

这是因为parallel提供的虚拟机仅安装了基础了amd64的组件，仍有大量的组件缺失。比如在这里，是缺失了binutils组件。

因此作者安装了amd64架构下的binutils，注意使用`:amd64`选择安装的目标架构

```
sudo apt-get update
sudo apt-get install binutils:amd64
```

然后，安装程序顺利进行，作者将idapro安装在/opt/idapro-8.3目录下。

尝试运行，果然又提示各种库文件缺失

# 修改ldd使其在arm下支持amd64程序
这一步做的


<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/26)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar((https://m2kar.cn)) 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请发邮件征求作者同意，并附上原文出处链接及本声明。
- **合规声明**: 本文仅限于技术交流，请读者遵守当地法律，如造成侵权、违法、犯罪行为，与本文无关。如本文侵犯到您的权利，请发邮件告知，本站将会做出适当处理。
- **作者**: m2kar
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#26](https://github.com/m2kar/m2kar.github.io/issues/26)
