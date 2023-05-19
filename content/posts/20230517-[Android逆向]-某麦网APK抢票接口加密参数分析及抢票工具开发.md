---
title: "[Android逆向] 某麦网APK抢票接口加密参数分析及抢票工具开发"
date: 2023-05-17T10:45:07Z

description: 
tags: [
  "draft"
]
issueId: 21
---

# 0x00 概述

针对大麦网部分演唱会门票仅能在app渠道抢票的问题，本文研究了APK的抢票接口并编写了抢票工具。本文介绍的顺序为环境搭建、抓包、trace分析、接口参数获取、rpc调用实现，以及最终的功能实现。通过阅读本文，你将学到反抓包技术破解、Frida hook、jadx apk逆向技术，并能对淘系APP的运行逻辑有所了解。本文仅用于学习交流，严禁用于非法用途。

**关键词**： frida, 大麦网, Android逆向
先放成功截图：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b7c8e2be-cf53-432f-9a33-9960a66f715e)

# 0x01 缘起

疫情结束的2023年5月，大家对出去玩都有点疯狂，歌手们也扎堆开演唱会。演唱会虽多，票却一点也不好抢，抢五月天的门票难度不亚于买五一的高铁票。所以想尝试找一些脚本来辅助抢票，之前经常用selenium和request做一些小爬虫来搞定自动化的工作，所以在 [MakiNaruto/Automatic_ticket_purchase](https://github.com/MakiNaruto/Automatic_ticket_purchase)  的基础上改了改，实现抢票功能。但是大麦网实在太**狡猾**了，改完爬虫才发现几乎所有的热门演唱会只允许在app购买，所以就需要利用APP实现接口自动化。

本着能省事则省事的原则，笔者在文章 [[Android] 基于Airtest实现大麦网app自动抢票程序](https://github.com/m2kar/m2kar.github.io/issues/20) 中用自动化测试技术实现了抢票程序，但是速度太慢，几乎不能用。果然捷径往往不好走，因此继续尝试分析大麦网apk的api接口。

# 0x02 环境

- windows 10
- 大麦网 apk 版本8.5.4 (2023-04-26)
- bluestacks 5.11.56.1003 p64
- adb 31.0.2
- Root Checker 6.5.3
- wireshark 4.0.5
- frida 16.0.19
- jadx-gui 1.4.7

# 0x03 bluestacks 环境搭建

目前Android模拟器竞品很多，选择Bluestacks **5**是因为它能和windows的hyper-v完美兼容，root过程也相对简单。

## 首先需要root Bluestacks环境。

1. 下载安装Bluestacks。
2. 运行Bluestacks Multi-instance Manager，发现默认安装的版本为Android Pie 64bit版本，即Android 9.0。此时退出bluestack所有程序。
  ![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/674ae190-5f7d-4f23-9c26-b38242ebc496)
3. 关闭bluestack后编辑bluestacks配置文件， `%programdata%\BlueStacks_nxt\bluestacks.conf`
 > 由于作者安装时C盘空间不足，真实的`bluestacks.conf`在`D:\BlueStacks_nxt\bluestacks.conf`，大家也根据实际情况调整
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/fa99b25a-6105-48db-9b14-8a6175b141a4)

4. 在配置文件中查找root关键词，对应值修改为1，共两处。
```conf
bst.feature.rooting="1"
bst.instance.Pie64.enable_root_access="1"
```
  ![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/074afb2c-f29d-4d92-bb4f-91f9827e8e45)

5. 启动bluestack模拟器，安装 `Root Checker` APP，点击验证root，即可发现root已成功。
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/8f26602e-101f-4f02-ae48-e63766810d25)

> 上述 root 过程主要参考了 https://appuals.com/root-bluestacks/ ，部分地方做了改正，在此感谢原文作者。

## 打开 adb调试

1. bluestack设置-高级中打开Adb调试，并记录下端口

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/d4165eb6-960a-4c19-bad7-5115548b04a5)

2. 打开主机命令行，运行 `adb connect localhost:6652`，端口号修改为上一步的端口号，即可连接。再运行`adb devices`，如有对应设备则连接成功。
3. 进入adb shell，执行su进入root权限，命令行标识由`$`变为`#`，即表示adb 进入root权限成功。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/e8f2f0c5-7df1-4226-9f16-a5d5d2a8cb2b)

# 0x02 frida环境搭建

frida是大名鼎鼎的动态分析的hook神器，用它可以直接访问修改二进制的内存、函数和对象，非常方便。它对于Android的支持也是很完美。

frida的运行采用C/S架构，客户端为电脑端的开发环境，服务器端为Android，均需对应部署搭建。
## 客户端环境搭建(Windows)
firda客户端基于python3开发，因此首先需要配置好python3的运行环境，然后执行 `pip install frida-tools`即可完成安装。运行 `frida --version`可验证frida版本。

```
(py3) PS E:\TEMP\damai> frida --version
16.0.19
```
## 服务器 环境搭建(Android)
环境搭建第二步是在Android模拟器中运行frida-server。这样可以让Frida通过ADB/USB调试与我们的Android模拟器连接。

1. 下载frida-server
最新的frida-server可以从 https://github.com/frida/frida/releases 下载。请注意下载与设备匹配的架构。如果您的模拟器是x86_64，请下载相应版本的frida-server。本文使用的版本为 [frida-server-16.0.18-android-x86_64.xz](https://github.com/frida/frida/releases/download/16.0.18/frida-server-16.0.18-android-x86_64.xz)
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/d9d085a1-f4dd-4873-8e95-a3a3d881d585)

2. 传入Android模拟器。

将下载后的.xz文件解压，将`frida-server`传入Android模拟器
```
adb push frida-server /data/local/tmp/
```
3. 运行 frida-server

使用adb root以root模式重新启动ADB，并通过adb shell重新进入shell的访问。进入shell后，进入我们放置frida-server的目录并为其授予执行权限：

```bash
cd /data/local/tmp/
chmod +x frida-server
```

执行：`./frida-server `，运行frida-server，并保持本shell窗口开启。

成功截图：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/92c87610-7dd7-4352-9744-7f29a504bf00)

> 有些情况下，应用程序会检测在是否在模拟器中运行，但对于大麦网app的分析暂无影响。

4. 测试是否连接成功
在window端运行frida-ps命令：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b150db94-ed85-4f8e-a3a2-c90839f263a1)

看到一堆熟悉的Android进程，我们就连接成功啦

5. 转发frida-server端口 (可选)

frida-server跑在Android端，frida需要通过连接frida-server。上一步使用adb的方式连接，frida认为是USB模式，需要`-U`命令。frida也支持依赖端口的远程连接模式，在某些场景下更加灵活。可以通过端口转发的方式实现此功能。

```
adb forward tcp:27042 tcp:27042
adb forward tcp:27043 tcp:27043
```

27042 用于与frida-server通信的默认端口号,之后的每个端口对应每个注入的进程，检查27042端口可检测 Frida 是否存在。


> 本部分主要参考了 https://learnfrida.info/java/ ， 在此感谢原文作者。

# 0x04 抓包

## 抓包及https解密方法
本章节将介绍用tcpdump+frida+wireshark实现Android的全流量抓包，能实现https解密。

惯用的Android抓包手段是用fiddler/burpsuite/mitmproxy搭建代理服务器，设置Android代理服务器并用中间人劫持的方式获取http协议流量的内容。如需对https流量解密，还需要在安卓上安装https根证书。Android9.0以后的版本对用户自定义根证书有了一些限制，抓包不再那么简单，但这难不倒技术大神们，大家可以可以参考以下几篇文章：

- [从原理到实战，全面总结 Android HTTPS 抓包](https://segmentfault.com/a/1190000041674464)
- [Android 高版本 HTTPS 抓包解决方案](https://jishuin.proginn.com/p/763bfbd5f92e)

上述的抓包方式只能抓到http协议层以上的流量，这次我们来点不一样的，用tcpdump+frida+wireshark实现Android的全流量抓包，能实现https解密。

1. 搞定tcpdump

本文基于termux安装使用tcpdump。

首先安装termux apk。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/57afcdaa-2417-4b61-8f42-7c83391f9144)

打开termux运行：

- 挂载存储
```
termux-setup-storage
## 会弹出授权框，点允许
ls ~/storage/
## 如果出现dcim, downloads等目录，即表示成功
```

 - 安装tcpdump
```
pkg install root-repo
pkg install sudo tcpdump
```

- 运行抓包

```
sudo tcpdump -i any -s 0 -w ~/storage/downloads/capture.pcap
```

- tcpdump 成功截图: 
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b42d5a4d-1384-4d90-9575-006e395d7fad)

之后就可以把downloads目录下的抓包文件拷贝到电脑上，用wireshark打开做进一步分析。

2. 解密https流量

Wireshark解密https流量的方法和原理介绍有很多，可参考以下文章，本文不再赘述。

> - https://unit42.paloaltonetworks.com/wireshark-tutorial-decrypting-https-traffic/
> - https://zhuanlan.zhihu.com/p/36669377

wireshark解密技术的重点在于拿到客户端通信的密钥日志文件(ssl key log)，像下面这种： 

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/1c7c211f-f8cd-420b-9c80-691c427c1504)

在Android中实现抓取ssl key log需要hook系统的SSL相关函数，可以用frida实现。

- 首先将下面的hook代码保存为`sslkeyfilelog.js`

```js
// sslkeyfilelog.js
function startTLSKeyLogger(SSL_CTX_new, SSL_CTX_set_keylog_callback) {
    console.log("start----")
    function keyLogger(ssl, line) {
        console.log(new NativePointer(line).readCString());
    }
    const keyLogCallback = new NativeCallback(keyLogger, 'void', ['pointer', 'pointer']);

    Interceptor.attach(SSL_CTX_new, {
        onLeave: function(retval) {
            const ssl = new NativePointer(retval);
            const SSL_CTX_set_keylog_callbackFn = new NativeFunction(SSL_CTX_set_keylog_callback, 'void', ['pointer', 'pointer']);
            SSL_CTX_set_keylog_callbackFn(ssl, keyLogCallback);
        }
    });
}
startTLSKeyLogger(
    Module.findExportByName('libssl.so', 'SSL_CTX_new'),
    Module.findExportByName('libssl.so', 'SSL_CTX_set_keylog_callback')
)

```

- 然后用frida加载运行hook
```
frida -U -l .\sslkeyfilelog.js  -f cn.damai
```
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/e0c46289-213e-4e49-821a-def3fcfc8367)

- 最后将得到的key保存到sslkey.txt，格式是下面这样的，不要掺杂别的。
```
CLIENT_RANDOM 557e6dc49faec93dddd41d8c55d3a0084c44031f14d66f68e3b7fb53d3f9586d 886de4677511305bfeaee5ffb072652cbfba626af1465d09dc1f29103fd947c997f6f28962189ee809944887413d8a20
CLIENT_RANDOM e66fb5d6735f0b803426fa88c3692e8b9a1f4dca37956187b22de11f1797e875 65a07797c144ecc86026a44bbc85b5c57873218ce5684dc22d4d4ee9b754eb1961a0789e2086601f5b0441c35d76c448

```

用wireshark打开tcpdump抓包获得的pcap文件，在wireshark首选项-protocols-TLS中，设置 (Pre)-Master-Secret log filename为上述sslkey.txt。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/30197b16-e429-4b9b-bb32-e18be8b1952e)

即可实现https流量的解密。

> 本部分主要参考了 https://www.52pojie.cn/thread-1405917-1-1.html ，向原作者表示感谢

## 流量分析

在上述步骤中拿到了解密后的流量，我们就能对大麦网的流量做进一步分析了。

### 大麦网的API流

在此铺垫一下，通过前期对大麦网PC端和移动端H5的分析，大麦网购票的工作流程大概为：

1. 获得详情：接口为`mtop.alibaba.damai.detail.getdetail`。基于某演出的id(itemId)获得演出的详细信息，包括详情、场次、票档(SkuId)价位及状态信息，
2. 构建订单：接口为`mtop.trade.order.build.h5`。发送 演出id+数量+票档id(`itemId_count_skuId`)，得到提交订单所需的表单信息，包括观众、收货地址等。
3. 提交订单：接口为`mtop.trade.order.create.h5`。对上一步构建订单得到的表单参数作出修改后，发送给服务器，得到最后的订单提交结果和支付信息。

### apk流量分析

首先用过滤器`http && tcp.port==443`，得到所有https流量。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/ce1f9928-cc83-4305-886e-f0c70bb9ec40)

- [ ]  TODO 未完待续


# 0x05 trace分析



# 0x06 hook得到接口参数


# 0x07 通过rpc调用


# 0x08 踩坑经历花絮


# 0x09 总结

[1]: 

<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/21)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#21](https://github.com/m2kar/m2kar.github.io/issues/21)