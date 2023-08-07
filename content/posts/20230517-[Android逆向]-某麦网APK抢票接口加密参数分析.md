---
title: "[Android逆向] 某麦网APK抢票接口加密参数分析"
date: 2023-05-17T10:45:07Z

description: 
tags: [
  "移动端安全"
]
issueId: 21
---

# **[Android逆向] 某麦网APK抢票接口加密参数分析**

🎉 本文已被[吾爱破解论坛](https://www.52pojie.cn)评为精华帖。[[链接]](https://www.52pojie.cn/thread-1789310-1-1.html)
✨ 本文已被[看雪论坛](https://bbs.kanxue.com)评为优秀帖。[[链接]](https://bbs.kanxue.com/thread-277342.htm)


# 0x00 概述

针对某麦网部分演唱会门票仅能在app渠道抢票的问题，本文研究了APK的抢票接口并编写了抢票工具。本文介绍的顺序为环境搭建、抓包、trace分析、接口参数获取、rpc调用实现，以及最终的功能实现。通过阅读本文，你将学到反抓包技术破解、Frida hook、jadx apk逆向技术，并能对淘系APP的运行逻辑有所了解。本文仅用于学习交流，严禁用于非法用途。

**关键词**： frida, damai.cn, Android逆向
先放成功截图：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b7c8e2be-cf53-432f-9a33-9960a66f715e)

# 0x01 缘起

疫情结束的2023年5月，大家对出去玩都有点疯狂，歌手们也扎堆开演唱会。演唱会虽多，票却一点也不好抢，抢五月天的门票难度不亚于买五一的高铁票。所以想尝试找一些脚本来辅助抢票，之前经常用selenium和request做一些小爬虫来搞定自动化的工作，所以在 [MakiNaruto/Automatic_ticket_purchase](https://github.com/MakiNaruto/Automatic_ticket_purchase)  的基础上改了改，实现抢票功能。但是某麦网实在太**狡猾**了，改完爬虫才发现几乎所有的热门演唱会只允许在app购买，所以就需要利用APP实现接口自动化。

本着能省事则省事的原则，笔者在文章 [[Android] 基于Airtest实现某麦网app自动抢票程序](https://github.com/m2kar/m2kar.github.io/issues/20) 中用自动化测试技术实现了抢票程序，但是速度太慢，几乎不能用。果然捷径往往不好走，因此继续尝试分析某麦网apk的api接口。

# 0x02 环境

- windows 10
- cn.damai apk 版本8.5.4 (2023-04-26)
- bluestacks 5.11.56.1003 p64
- adb 31.0.2
- Root Checker 6.5.3
- wireshark 4.0.5
- frida 16.0.19
- jadx-gui 1.4.7

# 0x03 环境搭建
## bluestacks 环境搭建
目前Android模拟器竞品很多，选择Bluestacks **5**是因为它能和windows的hyper-v完美兼容，root过程也相对简单。

### 首先需要root Bluestacks环境。

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

### 打开 adb调试

1. bluestack设置-高级中打开Adb调试，并记录下端口

  ![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/d4165eb6-960a-4c19-bad7-5115548b04a5)

2. 打开主机命令行，运行 `adb connect localhost:6652`，端口号修改为上一步的端口号，即可连接。再运行`adb devices`，如有对应设备则连接成功。
3. 进入adb shell，执行su进入root权限，命令行标识由`$`变为`#`，即表示adb 进入root权限成功。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/e8f2f0c5-7df1-4226-9f16-a5d5d2a8cb2b)

## frida环境搭建

frida是大名鼎鼎的动态分析的hook神器，用它可以直接访问修改二进制的内存、函数和对象，非常方便。它对于Android的支持也是很完美。

frida的运行采用C/S架构，客户端为电脑端的开发环境，服务器端为Android，均需对应部署搭建。
### 客户端环境搭建(Windows)
firda客户端基于python3开发，因此首先需要配置好python3的运行环境，然后执行 `pip install frida-tools`即可完成安装。运行 `frida --version`可验证frida版本。

```
(py3) PS E:\TEMP\damai> frida --version
16.0.19
```
### 服务器 环境搭建(Android)
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

  > 有些情况下，应用程序会检测在是否在模拟器中运行，但对某麦网app的分析暂无影响。

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

  27042是用于与frida-server通信的默认端口号,之后的每个端口对应每个注入的进程，检查27042端口可检测 Frida 是否存在。


  > 本部分主要参考了 https://learnfrida.info/java/ ， 在此感谢原文作者。

# 0x04 抓包

## 抓包及https解密方法
本章节将介绍用tcpdump+frida+wireshark实现Android的全流量抓包，能实现https解密。

惯用的Android抓包手段是用fiddler/burpsuite/mitmproxy搭建代理服务器，设置Android代理服务器并用中间人劫持的方式获取http协议流量的内容。如需对https流量解密，还需要在安卓上安装https根证书。Android9.0以后的版本对用户自定义根证书有了一些限制，抓包不再那么简单，但这难不倒技术大神们，大家可以可以参考以下几篇文章：

- [从原理到实战，全面总结 Android HTTPS 抓包](https://segmentfault.com/a/1190000041674464)
- [Android 高版本 HTTPS 抓包解决方案](https://jishuin.proginn.com/p/763bfbd5f92e)

上述的抓包方式只能抓到http协议层以上的流量，这次我们来点不一样的，用tcpdump+frida+wireshark实现Android的全流量抓包，能实现https解密。

### 1. 搞定tcpdump

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
pkg install tcpdump
pkg install tsu
```

- 运行抓包

```
sudo tcpdump -i any -s 0 -w ~/storage/downloads/capture.pcap
```

- tcpdump 成功截图: 
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b42d5a4d-1384-4d90-9575-006e395d7fad)

之后就可以把downloads目录下的抓包文件拷贝到电脑上，用wireshark打开做进一步分析。

### 2. 解密https流量

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

- 最后，抓包结束后将得到的key保存到sslkey.txt，格式是下面这样的，不要掺杂别的。

```
CLIENT_RANDOM 557e6dc49faec93dddd41d8c55d3a0084c44031f14d66f68e3b7fb53d3f9586d 886de4677511305bfeaee5ffb072652cbfba626af1465d09dc1f29103fd947c997f6f28962189ee809944887413d8a20
CLIENT_RANDOM e66fb5d6735f0b803426fa88c3692e8b9a1f4dca37956187b22de11f1797e875 65a07797c144ecc86026a44bbc85b5c57873218ce5684dc22d4d4ee9b754eb1961a0789e2086601f5b0441c35d76c448

```

在运行Frida Hook获取sslkey的同时，运行tcpdump抓包。抓包中依次测试获取详情页、选择价位、提交订单等操作，并对应记录下执行操作的时间，方便后续分析。

抓包完成后，用wireshark打开tcpdump抓包获得的pcap文件，在wireshark首选项-protocols-TLS中，设置 (Pre)-Master-Secret log filename为上述sslkey.txt。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/30197b16-e429-4b9b-bb32-e18be8b1952e)

即可实现https流量的解密。

> 本部分主要参考了 https://www.52pojie.cn/thread-1405917-1-1.html ，向原作者表示感谢

## 流量分析

在上述步骤中拿到了解密后的流量，我们就能对某麦网的流量做进一步分析了。

### 某麦网的API流

在此铺垫一下，通过前期对某麦网PC端和移动端H5的分析，某麦网购票的工作流程大概为：

1. 获得详情：接口为`mtop.alibaba.damai.detail.getdetail`。基于某演出的id(itemId)获得演出的详细信息，包括详情、场次、票档(SkuId)价位及状态信息，
2. 构建订单：接口为`mtop.trade.order.build.h5`。发送 演出id+数量+票档id(`itemId_count_skuId`)，得到提交订单所需的表单信息，包括观众、收货地址等。
3. 提交订单：接口为`mtop.trade.order.create.h5`。对上一步构建订单得到的表单参数作出修改后，发送给服务器，得到最后的订单提交结果和支付信息。

### apk流量分析

首先用过滤器`http && tcp.dstport==443`，得到向服务器发送的https包，如下图：

![https包](https://github.com/m2kar/m2kar.github.io/assets/16930652/ce1f9928-cc83-4305-886e-f0c70bb9ec40)

可以看到大量向服务器请求的数据包，但其中有很多干扰的图片请求，因为修改过滤器把图片过滤一下。过滤器：`http && tcp.dstport==443 and !(http.request.uri contains ".webp" or http.request.uri contains ".jpg" or http.request.uri contains ".png")` 

结果清爽了很多。

#### 订单构建(order.build)

根据之前记录的操作的时间，以及对网页版的分析结果，笔者注意到了下图的这条流量：

![订单创建包](https://github.com/m2kar/m2kar.github.io/assets/16930652/10ff344a-ee60-4eb4-a0da-5447d1cdc34e)

然后我们右键选择这条流量包，点击追踪http流，可以看到对应的响应包。

![追踪流](https://github.com/m2kar/m2kar.github.io/assets/16930652/1acd1ae8-d7ed-4df4-bef4-c99ad6647583)

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/61724496-f60c-4501-a28c-0e8cf0ecb468)

响应包里有些中文使用了UTF-8编码，可以点击右下角的`Show data as`，选择UTF-8，便可以正常显示。此时可以点击另存为，保存为txt文件，方便后续分析。

![请求包内容](https://github.com/m2kar/m2kar.github.io/assets/16930652/e2398d11-2da8-4461-8719-94a652143d0b)

订单构建的请求包中核心的数据部分为图中青色圈出来的部分，使用URL解码后为：

```
{"buyNow":"true","buyParam":"716435462268_2_5005943905715","exParams":"{\"atomSplit\":\"1\",\"channel\":\"damai_app\",\"coVersion\":\"2.0\",\"coupon\":\"true\",\"seatInfo\":\"\",\"umpChannel\":\"10001\",\"websiteLanguage\":\"zh_CN_#Hans\"}"}
```

buyParam为最核心的部分，拼接方式为演出id+数量+票档id。其他部分只需照抄。

请求包中还包含大量的各种加密参数、ID，而破解实现自动购票脚本的关键就在于如何通过代码的方式拿到这些加密参数。

订单构建的响应包为订单提交表单的各项参数，用于生成“确认订单”的表单。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/628bec87-c60b-450f-93a7-380ec51bbad3)

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/32cf7a2f-1a9b-42bf-b5ab-9bbf696729cb)


#### 订单提交(order.create)

按照同样的方式可以找到订单提交包，订单提交包的API路径为`/gw/mtop.trade.order.create`，

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/990b1661-c675-4c17-ba65-664f6aafe0e9)

其中青色圈出来的部分为data发送的核心数据，对数据用URL解码后为：

```
{"feature":"{\"gzip\":\"true\"}","params":"H4sIAAAAAAA.................AAWk3NKAAA\n"}
```

看起来像是把原始数据用gzip压缩后又使用了base64编码，尝试解码：

```python
import base64
import gzip
import json

# 解码后变为python dict
decode_data=base64.b64decode(params_str.replace("\\n",""))
decompressed_data=gzip.decompress(decode_data).decode("utf-8")
params=json.loads(decompressed_data)

with open("reverse\order.create-params.json","w") as f:
    json.dump(params,f,indent=2)
```

解码成功，存到`order.create-params.json`,

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/b4fad1b9-9943-4eac-ba78-84eee3620cee)

解码后发现order.create发送的data参数和order.build请求返回的结果很相似，增加了一些用户对表单操作的记录。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/3c59f063-3b70-451d-9ce6-b09d533bcdf4)

order.create请求的header中的各种加密参数和order.build一致。

order.create请求的返回结果中包含了订单创建是否成功的结果以及支付链接。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/7aef0ac4-3d91-4ed9-a736-85ba62ae559c)


# 0x05 trace分析
通过前面对流量的分析，我们已经知道客户端向服务器发送的核心数据和加密参数，核心数据的拼接相对简单，但加密参数怎么获得还比较困难。因此，下面要开始分析加密参数的生成方法。本章节主要采用frida trace动态分析和jadx静态分析相结合的方式，旨在找到加密参数生成的核心函数和输入输出数据的格式。

根据文章 ( [app安卓逆向x-sign，x-sgext，x_mini_wua，x_umt加密参数解析](https://blog.csdn.net/qq_44130722/article/details/126621134) )，其中数据包的加密参数和本文的某麦网很类似，而且提到了 mtopsdk.security.InnerSignImpl 生成的加密函数，本文也参考了这篇文章的思路进行分析。

## 跟踪 InnerSignImpl

运行`frida-trace -U -j "*InnerSignImpl*!*" 大麦`，执行选座提交订单的操作，发现确实有结果输出：

```
(py3) PS E:\TEMP\damai> frida-trace -U -j "*InnerSignImpl*!*" 大麦
Instrumenting...
InnerSignImpl$1.$init: Loaded handler at "E:\\TEMP\\damai\\__handlers__\\mtopsdk.security.InnerSignImpl_1\\_init.js"
....此处省略...
InnerSignImpl.init: Loaded handler at "E:\\TEMP\\damai\\__handlers__\\mtopsdk.security.InnerSignImpl\\init.js"
Started tracing 27 functions. Press Ctrl+C to stop.
           /* TID 0x144f */
  6725 ms  InnerSignImpl.getUnifiedSign("<instance: java.util.HashMap>", "<instance: java.util.HashMap>", "23781390", null, true)
  6726 ms     | InnerSignImpl.convertInnerBaseStrMap("<instance: java.util.Map, $className: java.util.HashMap>", "23781390", true)
  6726 ms     | <= "<instance: java.util.Map, $className: java.util.HashMap>"
  6727 ms     | InnerSignImpl.getMiddleTierEnv()
  6727 ms     | <= 0
  6737 ms  <= "<instance: java.util.HashMap>"
```

点击发送请求时，调用了InnerSignImpl.getUnifiedSign函数。但是输入参数和数据参数均为HashMap类型，结果中未显示具体内容。从结果输出中猜测frida-trace是通过对需要hook的函数在__handlers__下生成js文件，并调用js文件进行hook操作的，因此笔者修改了“__handlers__\mtopsdk.security.InnerSignImpl\getUnifiedSign.js”，使其能正确输出HashMap类型。
```js
// __handlers__\mtopsdk.security.InnerSignImpl\getUnifiedSign.js

{onEnter(log, args, state) {
 // 增加了HashMap2Str函数，将HashMap类型转换为字符串
    function HashMap2Str(params_hm) {
      var HashMap=Java.use('java.util.HashMap');
      var args_map=Java.cast(params_hm,HashMap);
      return args_map.toString();
  };
     // 当调用函数时，输出函数参数
    log(`InnerSignImpl.getUnifiedSign(${HashMap2Str(args[0])},${HashMap2Str(args[1])},${args[2]},${args[3]})`);
  }, onLeave(log, retval, state) {
      function HashMap2Str(params_hm) {
        var HashMap=Java.use('java.util.HashMap');
        var args_map=Java.cast(params_hm,HashMap);
        return args_map.toString();	};
    if (retval !== undefined) {
     // 当函数运行结束时，输出函数结果
      log(`<= ${HashMap2Str(retval)}`);
    } }}
```

再次运行frida-trace，输出的结果已经可以看到具体内容了：
```
(py3) PS E:\TEMP\damai> frida-trace -U -j "*InnerSignImpl*!*" 大麦
        ......
Started tracing 27 functions. Press Ctrl+C to stop.
           /* TID 0x15ab */
  2653 ms  InnerSignImpl.getUnifiedSign({data={"itemId":"719193771661","performId":"211232892","skuParamListJson":"[{\"count\":1,\"price\":36000,\"priceId\":\"251592963\"}]","dmChannel":"*@damai_android_*","channel_from":"damai_market","appType":"1","osType":"2","calculateTag":"0_0_0_0","source":"10101","version":"6000168"}, deviceId=null, sid=13abe677c5076a4fa3382afc38a96a04, uid=2215803849550, x-features=27, appKey=23781390, api=mtop.damai.item.calcticketprice, utdid=ZF3KUN8khtQDAIlImefp4RYz, ttid=10005890@damai_android_8.5.4, t=1684828096, v=2.0},{pageId=, pageName=},23781390,null)
  2654 ms     | InnerSignImpl.convertInnerBaseStrMap("<instance: java.util.Map, $className: java.util.HashMap>", "23781390", true)
  2655 ms     | <= "<instance: java.util.Map, $className: java.util.HashMap>"
  2655 ms     | InnerSignImpl.getMiddleTierEnv()
  2655 ms     | <= 0
  2662 ms  <= {x-sgext=JA2qmBOxRVDxFRzca3r9BZibqJqvn7uerZOriayYu4mpnKCeoJiunKGZu5qqyfmaqJqhmvqYr5n8zPyJqImpmbvLrImomqidu5m7m7uYu5u7mLuYu5u7m7ubqYmtiaiJqImoiaiJqImoiaiJu8+7iaCf/cypnruaqJqomruau5j8y7uau4mgiaiJqInf6fDIu5o=, x-umt=+D0B/05LPEvOgwKIQ1x+SeV5wNE6NzOo, x-mini-wua=atASnVJw3vGX1Tw3Y/zDaVZkDUbLxOxtlUmgDOnIjMTBcMPMqQJLpnxoOWEL53Fq/OPcQZiMpDXWNvDz8UQkI5mtkZvIcDN1oxZnuH0M22LHKar4rnO/xm4LtAiniKgYtfgMGK3stXuCmvtE4raIhROimslSk7hCkxaL/DYuLzBLYwXmNyr9UZi1g, x-sign=azG34N002xAAK0H9KwNr3txWFMxzW0H7ROfkLQK+Db7ueJHktR/yP/0TcdPFzoYf36zd9lJYMsHCmYX3EcoFnJPMk2pxu0H7QbtB+0}
```

可以看到返回结果中包含了 `x-sgext`,`x-umt`,`x-mini-wua`,`x-sign` 等加密参数。至此，前面的一大堆分析也算有了小的收获。但对比流量分析结果中的发送参数，还是缺失了很多参数。下面我们继续跟踪，找出剩下的参数。

## 跟踪 mtopsdk
调研发现淘系的apk都包含mtopsdk，猜想会不会有公开的官方文档描述mtopsdk的使用方法，因此我们就找到了 [【阿里云mtopsdk Android接入文档】](https://help.aliyun.com/apsara/agile/v_3_5_0_20210228/emas/development-guide/android.html)  。其中介绍了请求构建的流程为，笔者重点关注了请求构建和发送的部分：

```java
// 3. 请求构建
// 3.1生成MtopRequest实例
MtopRequest request = new MtopRequest();
// 3.2 生成MtopBuilder实例
MtopBuilder builder = instance.build(MtopRequest request, String ttid);
// 4. 请求发送
// 4.2 异步调用
ApiID apiId = builder.addListener(new MyListener).asyncRequest();

```

因此我们不妨大胆一些，直接跟踪所有对mtopsdk中函数的调用。

```
(py3) PS E:\TEMP\damai> frida-trace -U -j "*mtopsdk*!*" 大麦
```

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/95ff2d41-9fd6-4ed6-aeb9-4bba0547261c)

输出的结果大概有2000行，直接看太费劲，我们复制到文本编辑器里做进一步分析。

我们按照阿里的官方文档介绍的流程，对应可以找到在输出的trace中找到一些关键的日志。

```bash
# MtopRequest初始化
  3249 ms  MtopRequest.$init()
  3249 ms  MtopRequest.setApiName("mtop.trade.order.build")
  3249 ms  MtopRequest.setVersion("4.0")
  3249 ms  MtopRequest.setNeedSession(true)
  3249 ms  MtopRequest.setNeedEcode(true)
  3249 ms  MtopRequest.setData("{\"buyNow\":\"true\",\"buyParam\":\"7191937661_1_51826442779\",\"exParams\":\"{\\\"atomSplit\\\":\\\"1\\\",\\\"channel\\\":\\\"damai_app\\\",\\\"coVersion\\\":\\\"2.0\\\",\\\"coupon\\\":\\\"true\\\",\\\"seatInfo\\\":\\\"\\\",\\\"umpChannel\\\":\\\"10001\\\",\\\"websiteLanguage\\\":\\\"zh_CN_#Hans\\\"}\"}")

# MtopBuilder初始化
  3251 ms  MtopBuilder.$init("<instance: mtopsdk.mtop.intf.Mtop>", "<instance: mtopsdk.mtop.domain.MtopRequest>", null)

# MtopBuilder发送异步请求
3268 ms  MtopBuilder.asyncRequest()

# 参数构建
3301 ms     |    |    | InnerProtocolParamBuilderImpl.buildParams("<instance: mtopsdk.framework.domain.MtopContext>")
3391 ms     |    |    | <= "<instance: java.util.Map, $className: java.util.HashMap>",{wua=CofS_+7HCuvRCdz1EN8ICI6A4ZBCJwgY1hi+Bsivjcijs8GggmUxLQQUVTEQ5mYYtPuV7R2QNG5JEONIJRfmzjxFXMrs9AHdepIuqoJJJAyewWALprRnjIAu75t47Tm/RU9xRi7IEo9w0P2aCquLzf7uhiO8JEDSRK/ZdVhURBbof7reFtzEBoYYeIPgnwz7CL3kRlbyqyJcYKxO7ZmmVq1PtMXF2HGJqRSDjdv9l4mySJljIQzBmpX393L6eO1ZQVG1fpp6RaCRcFF+UgfjJXaeMFziHzfQF7KfUQZIeAJV/4GyVEE2f55RwPluOTuQubXQnq+qu41a0V5oyEOFXMoQRYFZzLOv3CjwkiIXsqJFeIHc=, x-sgext=JA0VLKcO8e9Fqqhj38VJuiwkHCUbIA8jGCwUNh0mDzYdIxQhFCcVJxskDyUedk0lHCUVJU4nGyZIc0g2HDYdJg90GDYcJRwiDyYPJA8kDyQPJA8kDyQPJA8nDyQPJQ8lDyUPJQ8lDyUPJQ82STYPLRlwSiUcNhwlHCUcNhw2HnFNNhw2Dy0PJQ8lD1JvfU42HA==, nq=WIFI, data={"buyNow":"true","buyParam":"719193771661_1_5182956442779","exParams":"{\"atomSplit\":\"1\",\"channel\":\"damai_app\",\"coVersion\":\"2.0\",\"coupon\":\"true\",\"seatInfo\":\"\",\"umpChannel\":\"10001\",\"websiteLanguage\":\"zh_CN_#Hans\"}"}, pv=6.3, sign=azG34N002xAAKiYA2sv237H04abW2iYKIxaD3GVPak+JifYV0u6VzpriFiKiP+HuuF26BzWpVTClaOIGdjtibfQ99JomGiYKJhomCi, deviceId=null, sid=13abe677c5076a4fa3382afc38a96a04, uid=2215803849550, x-features=27, x-app-conf-v=0, x-mini-wua=a3gSvx5K5/NRy/W8+fDouCSQ6VSmMK3awHwo5X+IayY7JL5SwHtiL0soynSAvCobk01qRQ2fQcTvZWakhmhA9xlNOKdwvxdA5nZ4Tno2asO5e7EvSMj6yqVYAXZZUBjZPUOBw3vpH8L2GUq9Gi6MTszU57a58+hJE2BCGTVsxhRonDw1Nnxp74Ffm, appKey=23781390, api=mtop.trade.order.build, umt=+D0B/05LPEvOgwKIQ1x+SeV5wNE6NzOo, f-refer=mtop, utdid=ZF3KUN8khtQDAIlImefp4RYz, netType=WIFI, x-app-ver=8.5.4, x-c-traceid=ZF3KUN8khtQDAIlImefp4RYz1684829318230001316498, ttid=10005890@damai_android_8.5.4, t=1684829318, v=4.0, user-agent=MTOPSDK/3.1.1.7 (Android;9;samsung;SM-S908E)}
```

笔者注意到了InnerProtocolParamBuilderImpl.buildParams函数的输出结果完全覆盖了需要的各类加密参数，其输入类型是MtopContext。从jadx逆向的apk代码中可以找到MtopContext类，即包含Mtop生命周期的各个类的一个容器。

```java
public class MtopContext {
    public ApiID apiId;
    public String baseUrl;
    public MtopBuilder mtopBuilder;
    public Mtop mtopInstance;
    public MtopListener mtopListener;
    public MtopRequest mtopRequest;
    public MtopResponse mtopResponse;
    public Request networkRequest;
    public Response networkResponse;
    public MtopNetworkProp property = new MtopNetworkProp();
    public Map<String, String> protocolParams;
    public Map<String, String> queryParams;
    public ResponseSource responseSource;
    public String seqNo;
    @NonNull
    public MtopStatistics stats;
}
```

所以现在的问题变为如何能够构建出来MtopContext，然后调用buildParams函数生成各类加密参数。

## 分析业务模块与mtopsdk的交互过程

在写本文复盘分析过程的时候，笔者发现仅依赖mtopsdk的调用过程其实已经可以得到MtopContext的全部生成逻辑了。但所谓当局者迷，笔者在当时分析的时候还是一头雾水。因此在此也介绍一下笔者的思考逻辑。

当时看着mtopsdk的调用过程，感觉很复杂。但是猜想从用户点击操作->业务代码->mtopsdk的数据流，以及模块间高内聚低耦合的原则，所以猜想模块间的调用不会很复杂，所以笔者就想分析业务代码与mtopsdk的调用逻辑。所以就想跟踪主要业务代码的trace。所以笔者继续跟踪trace，运行`frida-trace -U -j "*cn.damai*!*" 大麦 `，以分析`cn.damai`包的调用过程，在其中发现了 `NcovSkuFragment.buyNow()` 函数，看起来是和购买紧密相关的函数。又找到DMBaseMtopRequest类。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/2349df97-2e39-441a-b66a-e43e91a64ae5)

但是在这里有点卡住了，因为只找到了构建MtopRequest，并未在cn.damai的trace日志中并未发现其他对mtop的调用。

然后笔者又尝试搜索和api(order.build)相关的代码，找到了：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/c609e091-af47-4555-b925-bd3940416e12)

然而并没有多大用处。

然后，作者又读了大量的源代码，终于定位到了 `com.taobao.tao.remotebusiness.MtopBussiness`这个关键类。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/ed0df1c1-ce0f-4e4e-89d7-02e9bc75742b)

笔者本以为com.taobao开头的代码不是那么重要，所以最开始把这个类完全忽略了。但通过对源码的阅读，发现这个类是motpsdk中MtopBuilder类的子类，主要负责管理业务代码和Mtopsdk的交互。

因此我们继续通过trace跟踪MtopBussiness类。运行`frida-trace -U -j "*!*buyNow*" -j "com.taobao.tao.remotebusiness.MtopBusiness!*" -j "*MtopContext!*" -j "*mtopsdk.mtop.intf.MtopBuilder!*" 大麦`

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/56d6ee8d-9395-45b9-bf3e-23461e4850d9)

现在业务代码和mtopsdk的交互就很清晰了，红色的部分是业务代码的函数，绿色的部分是mtopsdk的函数。

# 0x06 hook得到接口参数

通过以上对trace的分析，已经知道了具体执行的操作，因此我们可以使用frida编写js代码，直接调用APK中的类，实现功能调用。

先展示一个简单的示例，用于构建一个自定义的MtopRequest 类:

```js
// new_request.js
Java.perform(function () {
    const MtopRequest = Java.use("mtopsdk.mtop.domain.MtopRequest");
    let myMtopRequest = MtopRequest.$new();
    myMtopRequest.setApiName("mtop.trade.order.build");
    //item_id + count + ski_id  716435462268_1_5005943905715
    myMtopRequest.setData("{\"buyNow\":\"true\",\"buyParam\":\"716435462268_1_5005943905715\",\"exParams\":\"{\\\"atomSplit\\\":\\\"1\\\",\\\"channel\\\":\\\"damai_app\\\",\\\"coVersion\\\":\\\"2.0\\\",\\\"coupon\\\":\\\"true\\\",\\\"seatInfo\\\":\\\"\\\",\\\"umpChannel\\\":\\\"10001\\\",\\\"websiteLanguage\\\":\\\"zh_CN_#Hans\\\"}\"}")
    myMtopRequest.setNeedEcode(true);
    myMtopRequest.setNeedSession(true);
    myMtopRequest.setVersion("4.0");
    console.log(`${myMtopRequest}`)
});
```
再使用运行命令 `frida -U -l .\reverse\new_request.js 大麦`，以在某麦Apk中执行js hook代码。运行之后即可输出笔者自己构建的MtopRequest实例。（frida真的很奇妙！）

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/13d32747-5e05-4fee-a0af-c4ea9c0cc5d8)

有了上面的结果，下面继续完善这个示例，添加MtopBussiness的构建过程和输出过程

```js
        //引入Java中的类
	const MtopBusiness = Java.use("com.taobao.tao.remotebusiness.MtopBusiness");
	const MtopBuilder = Java.use("mtopsdk.mtop.intf.MtopBuilder");
	// let RemoteBusiness = Java.use("com.taobao.tao.remotebusiness.RemoteBusiness");
	const MethodEnum = Java.use("mtopsdk.mtop.domain.MethodEnum");
	const MtopListenerProxyFactory = Java.use("com.taobao.tao.remotebusiness.listener.MtopListenerProxyFactory");
	const System = Java.use('java.lang.System');
	const ApiID = Java.use("mtopsdk.mtop.common.ApiID");
	const MtopStatistics = Java.use("mtopsdk.mtop.util.MtopStatistics");
	const InnerProtocolParamBuilderImpl = Java.use('mtopsdk.mtop.protocol.builder.impl.InnerProtocolParamBuilderImpl');

	// create MtopBusiness
	let myMtopBusiness = MtopBusiness.build(myMtopRequest);
	myMtopBusiness.useWua();
	myMtopBusiness.reqMethod(MethodEnum.POST.value);
	myMtopBusiness.setCustomDomain("mtop.damai.cn");
	myMtopBusiness.setBizId(24);
	myMtopBusiness.setErrorNotifyAfterCache(true);
	myMtopBusiness.reqStartTime = System.currentTimeMillis();
	myMtopBusiness.isCancelled = false;
	myMtopBusiness.isCached = false;
	myMtopBusiness.clazz = null;
	myMtopBusiness.requestType = 0;
	myMtopBusiness.requestContext = null;
	myMtopBusiness.mtopCommitStatData(false);
	myMtopBusiness.sendStartTime = System.currentTimeMillis();

	let createListenerProxy = myMtopBusiness.$super.createListenerProxy(myMtopBusiness.$super.listener.value);
	let createMtopContext = myMtopBusiness.createMtopContext(createListenerProxy);
	let myMtopStatistics = MtopStatistics.$new(null, null); //创建一个空的统计类
	createMtopContext.stats.value = myMtopStatistics;
	myMtopBusiness.$super.mtopContext.value = createMtopContext;
	createMtopContext.apiId.value = ApiID.$new(null, createMtopContext);

	let myMtopContext = createMtopContext;
	myMtopContext.mtopRequest.value = myMtopRequest;
	let myInnerProtocolParamBuilderImpl = InnerProtocolParamBuilderImpl.$new();
	let res = myInnerProtocolParamBuilderImpl.buildParams(myMtopContext);
	console.log(`myInnerProtocolParamBuilderImpl.buildParams => ${HashMap2Str(res)}`)
```

再次执行`frida -U -l .\reverse\new_request.js 大麦`，输出结果如下图，此时已能根据笔者任意构建的请求data输出其他加密参数：

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/53a239e1-38e8-471b-9be8-584f8c9dba0f)

对于order.create的原理类似，此处不再赘述。

## 补充说明

通过frida调用Apk中的Java类有时候会出现找不到类的情况，原因可能是classloader没有正确加载。可以在js代码前的最前面加上下面的代码，指定正确的classloader，即可解决该问题

```js
Java.perform(function () {
    //get real classloader
    //from http://www.lixiaopeng.top/article/63.html
    var application = Java.use("android.app.Application");
    var classloader;
    application.attach.overload('android.content.Context')
        .implementation = function (context) {
            var result = this.attach(context); // run attach as it is
            classloader = context.getClassLoader(); // get real classloader
            Java.classFactory.loader = classloader;
            return result;
        }
});
```

## frida hook 的强大功能

通过frida操纵Java类的功能实在过于强大，安全人员可以执行以下操作：

1.  *打印函数输入输出*。通过hook函数，以实现打印函数的输入输出结果。
操作代码可以在jadx右键菜单可以很方便的生成。

  ![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/c741ef2d-a144-4187-8233-bc2ae81ee4a1)

  ```js
let LocalInnerSignImpl = Java.use("mtopsdk.security.LocalInnerSignImpl");
LocalInnerSignImpl["$init"].implementation = function (str, str2) {
    console.log(`LocalInnerSignImpl.$init is called: str=${str}, str2=${str2}`);
    this["$init"](str, str2);
};

  ```
2. *修改已有的类和函数*。
3. *定义新类和新函数*。
4. *主动生成类的实例或调用函数*。
5. *RPC调用*。通过RPC调用提供python编程接口。

# 0x07 通过rpc调用

前文提到frida的一个特性是可以通过rpc调用提供python编程接口。

一个简单的示例：
```python
import frida

def on_message(message, data):
    if message["type"] == "send":
        print("[*] {0}".format(message["payload"]))
    else:
        print(message)

# hook代码
jscode = """
rpc.exports = {
    testrpc: function (a, b) { return a + b; },
};  """

def start_hook():
# 开始hook
    process = frida.get_usb_device().attach("大麦")
    script = process.create_script(jscode)
    script.on("message", on_message)
    script.load()
    return script

script = start_hook()
# 调用hook代码
print(script.exports.testrpc(1, 2))

# >>> 输出
# 3
```

frida使用rpc的方法也很简单，仅需使用rpc.exports，将对应的函数暴露出来，就能被python调用。

完整的代码就是将上一章的代码封装为函数，并通过rpc对外提供接口，就可以了。为避免侵权，本文不贴出完整利用代码。

代码封装完成后测了一下，平均一次调用的时间为0.024秒，完全可以达到抢票的要求。

# 0x08 提示和技巧

参考大家经常问的问题以及评论区大佬的思路,总结一些提示和技巧.

## 编码格式细节
很多朋友出现服务端返回"非法签名的情况",是由于细节的问题.

order.build和order.create接口的具体编码规则很细节,比如一些空格,引号,是否urlEncode等等. python requests包自己的封装格式可能和和大麦apk不兼容,因此最后出来的包实质是差别比较大. 

解决措施:
1. 用wireshark抓apk发包和自己代码发的包,分析区别
2. 尝试一层一层解apk发的包,然后再重新打包,看是否能和之前保持一致
3. request的post内容不要用dict,用文本.
4. 编码多用字符串拼接.
5. header里的字段名大小写/顺序最好保持一致.
6. create发送的data是在build的返回值做了一些编辑
7. 
## 禁用spdy
感谢 @IWasSleeping 
参考: https://github.com/m2kar/m2kar.github.io/issues/21#issuecomment-1634733885

对于mtopsdk ssl的抓包可以通过屏蔽掉spdy协议，关闭spdy ssl和全局的spdy来实现让APP通过http协议，来方便任何安卓版本实现简单抓包，通过hook的方式：

    let SwitchConfig = Java.use("mtopsdk.mtop.global.SwitchConfig");
    SwitchConfig["isGlobalSpdySslSwitchOpen"].implementation = function () {
        console.log(`SwitchConfig.isGlobalSpdySslSwitchOpen is called`);
        let result = this["isGlobalSpdySslSwitchOpen"]();
        console.log(`SwitchConfig.isGlobalSpdySslSwitchOpen result=${result}`);
        return false;
    };
    
    SwitchConfig["isGlobalSpdySwitchOpen"].implementation = function () {
        console.log(`SwitchConfig.isGlobalSpdySwitchOpen is called`);
        let result = this["isGlobalSpdySwitchOpen"]();
        console.log(`SwitchConfig.isGlobalSpdySwitchOpen result=${result}`);
        return false;
    };
通过主动调用的方式：

    var SwitchConfig = Java.use('mtopsdk.mtop.global.SwitchConfig')
    var config = SwitchConfig.getInstance();
    config.setGlobalSpdySslSwitchOpen(false);
    config.setGlobalSpdySwitchOpen(false);

## 滑动验证码
感谢: @svcvit 
参考: https://github.com/m2kar/m2kar.github.io/issues/21#issuecomment-1635989770

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/3512f3fb-8876-4007-ac53-c76b7697d6bc)

滑块过了，原理：FAIL_SYS_USER_VALIDATE的时候，返回头里有个location，用浏览器打开这个url，滑动，获取cookies，装入request里，就可以了。效果参考下方。

代码参考：https://github.com/kuxigua/TaoBaoSpider/blob/02fd1dc437c1b0fd49fc64bfbedd6c070d9e21e5/AntiReptile/imgCodeHandle.py

## traceid
> 请问header中的x-c-traceid是怎么构建的，rpc返回的对象中这个值是空的

```
utdid = "ZHmSZ78mpAEDALjcMTWN1YHF"
timestamp = int(time.time() * 1000)
padded_number = format(int(number), "04")
f71332q = "122782"
x_c_traceid = str(utdid) + (str(timestamp)) + (str(padded_number)) + (str(f71332q))
```
感谢 @nobewp 


# 0x09 踩坑经历花絮
## 关于wiresharkhelper

txthinking放出了一个抓包辅助工具[wiresharkhelper](https://github.com/txthinking/wiresharkhelper)，看视频介绍很诱人很方便，但是实测是要收费的。本人穷，所以就没用他的方法。然而也是因为这个才开始尝试用frida工具得到https的密钥，发现了frida这个神器。

## 关于Cookie
细心的朋友可能发现发送的请求头里是包含cookie的，但是本文没有介绍。其实笔者本来是再继续找cookie的，但是发现把`InnerProtocolParamBuilderImpl.buildParams`函数的参数填进去之后，就已经能正常获取服务器的返回值了，所以就没继续搞cookie

## 关于MtopStatistics

MtopStatistics是mtopsdk里比较重要的一个类，用来跟踪用户的操作记录状态，可能有助于判断用户是否是机器人。但笔者尝试自己构建MtopStatistics失败，所以直接生成了一个空的MtopStatistics类，好在也没对服务器的正常返回造成影响。

## 如何获取票价信息

这里笔者是直接用的某麦网Web端PC版，网页中有一段json，包含静态的描述信息和动态的场次、余票信息。

## 如何脱离模拟器运行

目前是需要模拟器一直运行着的，而且仅能用一个人的账户。这对于个人使用是完全够用的。如何能脱离模拟器，而且增加并发用户数量还需要继续研究。目前时间不允许，暂时不再继续此问题的研究。

## 还是抢不到票

虽然流程全都搞定，而且对于非热门场次抢票完全没有问题。但对于热门场次，官方可能还是增加了或明或暗的检测机制。比如有些是淘票票限定渠道，在对特权用户开放抢票一段时间后才会对其他人，但开放状态仅从网页端无法判断，导致脚本会提前开抢，被系统提前拦截。或者有的场次明明第一时间开抢，却还是一直提示请求失败。这个还需要进一步踩坑理解某麦网的机制。

## BP链接
这篇公众号文章( https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzA4MDEzMTg0OQ==&action=getalbum&album_id=2885498232984993792#wechat_redirect ) 介绍了某麦网的bp链接及使用方式，可以跳过票档选择直接进入订单确认页面。后续可以尝试用于自动抢票。

如：
```
- 毛不易 -  5月27日 上海站
1、五层480 x 1张
https://m.damai.cn/app/dmfe/h5-ultron-buy/index.html?buyParam=718707599799_1_5008768308765&buyNow=true&exParams=%257B%2522channel%2522%253A%2522damai_app%2522%252C%2522damai%2522%253A%25221%2522%252C%2522umpChannel%2522%253A%2522100031004%2522%252C%2522subChannel%2522%253A%2522damai%2540damaih5_h5%2522%252C%2522atomSplit%2522%253A1%257D&spm=a2o71.project.sku.dbuy&sqm=dianying.h5.unknown.value

2、五层480 x 2张
https://m.damai.cn/app/dmfe/h5-ultron-buy/index.html?buyParam=718707599799_2_5008768308765&buyNow=true&exParams=%257B%2522channel%2522%253A%2522damai_app%2522%252C%2522damai%2522%253A%25221%2522%252C%2522umpChannel%2522%253A%2522100031004%2522%252C%2522subChannel%2522%253A%2522damai%2540damaih5_h5%2522%252C%2522atomSplit%2522%253A1%257D&spm=a2o71.project.sku.dbuy&sqm=dianying.h5.unknown.value
```


# 0x10 总结

本文完整的记录了笔者对于Apk与服务器交互API的解析过程，包括环境搭建、抓包、trace分析、hook、rpc调用。本文对于淘系Apk的分析可以提供较多参考。本文算是笔者第一次深入且成功的用动态+静态分析结合的方式，借助神器frida+jadx，成功破解Apk，因此本文的记录也较为细致的记录了作者的思考过程，可以给新手提供参考。

本文也有一些不足之处，如无法脱离模拟器运行、仅能单用户、抢票成功率仍不高等。对于这些问题，如果未来作者有时间，会再回来填坑。

本文作者为m2kar，原文发表在 [`https://github.com/m2kar/m2kar.github.io/issues/21`](https://github.com/m2kar/m2kar.github.io/issues/21) ，转载请注明出处。

分享一个tg讨论组， https://t.me/+IbWm3n0o1KlkMTg1 ,感谢 @svcvit 

最后，欢迎大家在issue评论区或tg讨论组多多提出问题相互交流。

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