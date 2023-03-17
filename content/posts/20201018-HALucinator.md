---
title: "【论文笔记】HALucinator 虚拟化硬件层模拟启动固件"
date: 2020-10-18
draft: false
description: "HALucinator 虚拟化硬件层模拟启动固件"
tags: ["论文笔记","系统安全","固件分析","Qemu","HALucinator"]
categories: ["论文笔记"]
---

- **标题:**HALucinator: Firmware Re-hosting Through Abstraction Layer Emulation
- **作者:** Abraham A Clements, Eric Gustafson; Tobias Scharnowski; Paul Grosen; David Fritz; Christopher Kruegel and Giovanni Vigna; Saurabh Bagchi; Mathias Payer
- **来源:** USENIX Security 2020
- **链接:** https://www.usenix.org/conference/usenixsecurity20/presentation/clements
- **引用:** Clements, A. A., Gustafson, E., Scharnowski, T., Grosen, P., Fritz, D., Kruegel, C., … Payer, M. (2020). HALucinator: Firmware Re-hosting Through Abstraction Layer Emulation. *29th USENIX Security Symposium (USENIX Security 20)*, 1201–1218. USENIX Association. Retrieved from https://www.usenix.org/conference/usenixsecurity20/presentation/clements 

## 摘要

鉴于在线嵌入式设备无处不在的情况，分析其固件对于安全性，隐私性和安全性至关重要。硬件和固件之间的紧密耦合以及嵌入式系统中的多样性使得难以对固件执行动态分析。但是，固件开发人员会定期使用诸如**硬件抽象层（HAL）**之类的抽象来开发代码，以简化其工作。我们利用这些抽象作为重新托管和分析固件的基础。通过提供HAL功能的高级替代品（称为“HLE”），我们使硬件与固件脱钩。这种方法的工作方式是，首先通过二进制分析在固件样本中找到库函数，然后在全系统仿真器中提供这些函数的通用实现。我们在原型系统HALucinator中提出了这些想法，该系统可以重新托管固件，并允许虚拟设备正常使用。首先，我们介绍了现有库匹配技术的扩展，这些扩展是识别二进制固件中的库函数，减少冲突以及推断其他函数名所必需的。接下来，我们通过使用简化的处理程序和外围模型演示重新托管过程，这些过程使固件样本和芯片供应商之间的过程快速，灵活且可移植。最后，通过向**HALucinator**添加AFL模糊器，在固件中间件库中定位多个以前未知的漏洞，我们证明了HLE在安全性分析方面的实用性。

## 介绍


### 现实问题

物联网安全问题严峻，固件检测问题难以解决。

固件测试通常使用物理方法。但存在以下问题：
- 调试接口
  - 被禁用
- 被限制
- 并行困难
- 其他限制
- 贵   💎💎💎
- 易坏💀💀💀


### 待解决的问题

使用固件模拟(firmware re-hosting)的方式，在普通计算机上执行固件。但由于固件的差异性，固件的模拟难以实现。

![image-20201018234452206](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/image-20201018234452206.png)

### 当前研究的不足
当前的研究把对硬件的请求转发到实际的硬件中，但这种方式需要源硬件。

另外还有技术可以重放或者对硬件建模，但这种方式限制需要严格按照已经记录好的路径执行。
### 主要解决思路
硬件抽象层是一些对实际硬件抽象处理的操作系统库。通过模拟硬件抽象层，可以达到模拟的底层硬件的目的。


### 主要贡献
1. 提出HAL库模拟技术，可在无需依赖实际硬件的情况下使用QEMU等模拟器仿真二进制固件
2. 改进了现有的依赖库匹配技术
3. 提出HALucinator仿真系统，可通过抽象处理程序和外围模型库的方式进行交互式仿真和固件Fuzzing
4. 通过对16个固件的模拟，证明了方法的实用性。并通过Fuzzing的方式发现了两个0day漏洞

## 动机(Motivation)

- 模拟硬件和外设

- 模拟固件栈

- 高层级模拟

## 设计

![架构图](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20201018225644.png)

![HTTP服务器软硬件堆栈、替换](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20201018225845.png)
最终能达到多层级的模拟。

### hal-fuzz 模糊测试功能
1. 基于AFL-Unicorn
2. 输入用尽时程序退出
3. 基于块计数的确定性计时器
4. 中断事件也基于块计数
5. 通过Unicorn自身的错误检测到崩溃
6. 检测器以及处理程序断言

## 实验评估

### 实验效果

#### CVE
1. CVE-2019-8359：Contiki OS数据包重组功能中的缓冲区溢出导致的远程执行代码漏洞。
2. CVE-2019-9183：Contiki OS数据包重组功能中的整数下溢漏洞导致的远程拒绝服务漏洞。

#### CSAW ESC 2019 比赛结果

1. ESC是一个比较知名的嵌入式安全比赛。2019年的比赛为无线射频识别(RFID) 的安全性。

2. 比赛使用美国国家安全局(NSA)开发的逆向工程工具黑客定制的 RFID 读卡器固件。

![image-20201019001646472](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/image-20201019001646472.png)

团队成绩：

- 模拟了所有挑战集的ARM部分
- 解决了18/19的挑战
- 使用模糊测试自动解决3个挑战
- 获得第一名！



## 讨论



## 总结



## 作者介绍

### Abraham A. Clements 

【[DBLP](https://dblp.org/pid/187/9046.html) 】

普渡大学PhD；从2017年开始做物联网安全研究；3篇一作顶会

### Eric Gustafson

【[主页](http://subwire.net/)】

加州大学圣芭芭拉分校已毕业PhD。

专注于移动端和物联网安全。

有很多顶会论文。

### 合作实验室

几个合作实验室都很有来头。

![合作实验室](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20201018225115.png)


## 收获

### 本文优势
这篇论文解决了一篇经典论文Firmadyne在固件模拟上的核心问题。

### 可扩展结合的点

可以尝试复现此文章来解决固件漏洞挖掘的问题。

## 论文评价

**评分**: ⭐⭐⭐⭐⭐

**评价**: 很有参考价值！



## 参考资料及附件

- [1] 论文笔记幻灯片: https://cdn.jsdelivr.net/gh/m2kar/bucket/annex/papernote-slides-HALucinator-sec20.pdf
- [2] 论文原稿: https://www.usenix.org/system/files/sec20-clements.pdf
- [3] 论文原幻灯片: https://www.usenix.org/system/files/sec20_slides_clements.pdf

-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)