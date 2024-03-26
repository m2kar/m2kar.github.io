---
title: "[技术分享]套娃之arm架构下的MacBook通过parallels+rosetta安装Linux amd64版本的IDA Pro"
date: 2024-03-25T13:39:45Z

description: 
tags: []
issueId: 26
---

# 前言
苹果公司在MacBook这种生产力平台使用无疑是个伟大且大胆的创新，经过几年的软件生态环境的改善，各种常用工具基本都能在mac下运行。但仍有些闭源发布的软件仍需要在amd64架构下的Linux环境中才能运行，比如本文中的IDA Pro 7.6版，因此整理一下踩坑记录，可供相关需求的同学参考。

**划重点**：arm环境下运行amd64程序;ldd跨架构运行

# 环境和工具
- MacBook with M3 chip
- parallels Desktop 19
- IDA Pro 8.3 for Linux 安装包

# 支持amd64的Linux环境
parallels是Mac生态下非常好用的虚拟机软件，但之前的版本仅支持运行arm架构的虚拟机，不支持amd64的程序。在parallels的v19版本之后，基于[苹果官方提供的支持](https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta), parallels推出了[在arm虚拟机中运行amd64程序的能力](https://kb.parallels.com/en/129871)，并提供了一套配置好了的ubuntu 22.04虚拟机镜像。

因此，我们只需要点击创建虚拟机，下载Ubuntu with x86_emulation，即可获得amd64的模拟运行环境。如下图。
<img width="872" alt="image" src="https://github.com/m2kar/m2kar.github.io/assets/16930652/d8e4710c-c9ca-4d28-b9df-d2c1ccac175a">

# 安装IDA pro并解决各种依赖缺失
打开安装好的虚拟机，把安装包拷贝进来，在终端中运行。

```bash
sudo idapronl_xxx.run
```

但直接报错： `rosetta error: failed to open elf at /lib64/ld-linux-x86-64.so.2` 

这是因为parallel提供的虚拟机仅安装了基础了amd64的组件，仍有大量的组件缺失。比如在这里，是缺失了binutils组件。

因此作者安装了amd64架构下的binutils，注意使用`:amd64`选择安装的目标架构

```
sudo apt-get update
sudo apt-get install binutils:amd64
```

然后，安装程序顺利进行，作者将idapro安装在/opt/idapro-8.3目录下。

尝试运行`ida64`，果然又提示各种库文件缺失。

比如以下报错提示：

```
/opt/idapro-8.3/ida64: error while loading shared libraries: libGL.so.1: cannot open shared object file: No such file or directory
```

表示缺失了`libGL.so.1`动态链接库，谷歌搜索后发现需要安装`libgl1-mesa-glx`库，则运行命令`sudo apt install libgl1-mesa-glx:amd64`安装amd64架构下的`libgl1-mesa-glx`库。

类似的，提示`libgthread-2.0.so.0`缺失则安装`libglib2.0-0:amd64`。提示`libSM.so.6`则安装`libsm6:amd64`和`libxext6:amd64`。提示`libfontconfig.so.1`则安装`libsm6:amd64`


# 解决Qt插件无法运行的问题

经过不断修补缺失链接库，ida不再提示缺失链接库，开始提示QT的xcb插件无法加载。如下：

```
qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
This application failed to start because no Qt platform plugin could be initialized. Reinstalling the application may fix this problem.

Available platform plugins are: eglfs, linuxfb, minimal, minimalegl, offscreen, vnc, xcb.
```

这是因为IDA安装目录下`libQt5XcbQpa.so.5`所依赖的其他链接库无法运行，将在下一章使用ldd命令分析缺失的动态链接库。

# 修改ldd使其支持分析amd64程序

通常情况下，我们选择使用ldd命令分析程序所需的动态链接库，寻找其中的缺失项。

但当运行`ldd libQt5XcbQpa.so.5`，终端却提示`not a dynamic executable`。

而尝试使用ldd分析系统自带的arm架构二进制文件时，却能正常显示。

因此猜测是ldd无法跨架构运行。ldd工具包含在libc-bin中，所以尝试使用`sudo apt install libc-bin:amd64`安装amd64架构下的ldd工具。但很不幸，由于amd64下的libc-bin和arm原生的libc-bin冲突，无法正常安装。

```
The following packages have unmet dependencies:
 libc-bin : Conflicts: libc-bin:amd64
 libc-bin:amd64 : Conflicts: libc-bin
E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages.
```

`libc-bin`看起来又像是系统比较重要的库，因此没有冒险把原本的`libc-bin`替换为amd64架构的软件。

通过进一步查阅资料，发现`ldd`程序本身其实是脚本，并非二进制程序。`/usr/bin/ldd`代码中使用`RTLDLIST`定义了使用哪个ld-linux。

```
RTLDLIST=/lib/ld-linux-aarch64.so.1
```

```ldd```是依赖于`ld-linux`动态链接库的实现的，而`ld-linux`在不同架构下对应有不同的二进制包。比如在arm下为`ld-linux-aarch64.so.1`，在amd64下为`ld-linux-x86-64.so.2`。

因此，作者尝试使用`/lib64/ld-linux-x86-64.so.2`替换掉arm架构的版本，并将程序保存为`/usr/bin/ldd-amd64`，现在可以成功运行 `ldd libQt5XcbQpa.so.5`，分析缺失的依赖项。

# 继续解决Qt插件无法运行的问题

尝试运行 `ldd-amd64 libQt5XcbQpa.so.5`，解决依赖缺失问题。

```
$ ldd-amd64 /opt/idapro-8.3/libQt5XcbQpa.so.5 
...(省略)
	/lib64/ld-linux-x86-64.so.2 (0x00007ffffffc4000)
	libdbus-1.so.3 => not found
	libxcb-util.so.1 => /lib/x86_64-linux-gnu/libxcb-util.so.1 (0x00007ffffe6b5000)
...(省略)
```
发现是`libdbus-1.so.3`缺失，搜索发现缺少了`libdbus-1-3`,于是运行安装`sudo apt install libdbus-1-3:amd64`。

终于可以顺利的反编译！

<img width="1193" alt="image" src="https://github.com/m2kar/m2kar.github.io/assets/16930652/9cc320d9-f4a7-4593-a876-176a05db4565">

# 解决idapython无法运行的问题

运行后，IDA控制台提示：
```
dlopen(/opt/idapro-8.3/plugins/idapython3_64.so): libpython3.6m.so.1.0: cannot open shared object file: No such file or directory
/opt/idapro-8.3/plugins/idapython3_64.so: can't load file
```
看起来是`idapython3_64.so`运行时无法找到`libpython3.6m.so.1.0`，导致出错。

这里推荐的方式是不改变系统里的`libpython3`和`python3`相关包，通过miniconda创建单独的python环境，并设定库搜索路径。

使用miniconda安装python3.6的环境。
```
curl -O https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh
/opt/miniconda3/bin/conda init
source ~/.bashrc
conda create --name idapy "python=3.6,<3.7"
```

设定库搜索路径
```
# 编辑.bashrc
export LD_LIBRARY_PATH="/home/parallels/miniconda3/envs/idapy/lib:$LD_LIBRARY_PATH"
```

应用环境变量后再次打开IDA，已经可以正确运行idapython。

<img width="783" alt="image" src="https://github.com/m2kar/m2kar.github.io/assets/16930652/5e58998c-df04-4b46-a892-3c20d195b30b">

# 解决乱码的缺失库的问题

本来运行的挺好，但是重启后出现以下错误：

```
$ /opt/idapro-8.3/ida
/opt/idapro-8.3/ida: error while loading shared libraries: ��: cannot open shared object file: No such file or directory
```

在给Hex-Ray官方支持发了邮件之后，重新试了一下，自己把问题解决了。。。原因是之前装的时候是已经通过miniconda配置好了python环境，但重启之后环境出了些问题。如果各位遇到类似问题，可先配置python环境，再进行安装。

# All in One

使用以下命令解决IDAPro安装时所有的依赖问题。
```
sudo apt-get update
sudo apt-get install binutils:amd64 libgl1-mesa-glx:amd64 libglib2.0-0:amd64 libsecret-1-0:amd64
sudo apt-get install libfontconfig1:amd64 libxcb-icccm4:amd64 libxcb-image0:amd64 libxcb-keysyms1:amd64 libxcb-render-util0:amd64 libxcb-render0:amd64 libxcb-shape0:amd64 libxcb-xinerama0:amd64 libxcb-xkb1:amd64 libsm6:amd64 libice6:amd64 libxkbcommon-x11-0:amd64 libxkbcommon0:amd64 libdbus-1-3:amd64

# 解决python环境的代码在此省略
```

# 总结
非常套娃的踩了安装IDA Pro的坑，在arm架构下的MacBook通过parallels+rosetta安装Linux amd64版本的IDA Pro。本技术也可以用于安装其他跨架构软件。

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
