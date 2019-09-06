---
title: "SafeHidden: An Efficient and Secure Information
Hiding Technique Using Re-randomization"
date: 2019-09-05T18:05:00+08:00
lastmod: 2019-09-05T18:05:00+08:00
draft: false
keywords: ["论文","SafeHidden","系统安全"]
description: "一种新型的内存地址随机化的增强方案SafeHidden，可以解决内存地址随机化（ASLR）的不安全问题。"
tags: ["论文笔记","系统安全","流量分析","静态分析"]
categories: ["论文笔记"]
author: "m2kar"

---

# 概览
## 摘要
### 中文（翻译）
在众多代码重用攻击的防御手段中，信息隐藏(Information Hiding,IH)由于其有效性和高性能，成为是防御手段的一个重要组成模块，如代码指针完整性(CPI)，控制流完整性(CFI)和细粒度的代码重随机化。它使用随机化实现有概率的隐藏系统的关键内存区域，也成为安全区。该区域不能被任何指针直接访问，可以阻止攻击者的攻击行为。这些防御手段使用安全区来保护非常重要的数据，如跳转目标和随机化的密码。然而，最近的研究表明IH在很多攻击手段下不再安全。
在本文中，我们提出一种新的IH技术，称之为SafeHidden。 它能持续重随机化安全区的位置，组织攻击者探索和推理内存布局来寻找安全区的位置。本文提出一种新的线程私有的内存机制，该机制可以让线程本地的安全区孤立化，避免攻击者通过随机熵减少发起攻击。它也可以在TLB（页表）缺失后随机化安全区，来避免攻击者使用基于cache侧信道推理安全区的位置。现有的基于信息隐藏的防御方法无需修改也能使用SafeHidden技术。实验表明SafeHidden不仅可以有效避免已有的攻击手段，并且带来的性能损耗也极小。

### 英文
Information hiding (IH) is an important building block for many defenses against code reuse attacks, such as code-pointer integrity (CPI), control-flow integrity (CFI) and fine-grained code (re-)randomization, because of its effectiveness and performance. It employs randomization to probabilistically ''hide'' sensitive memory areas, called safe areas, from attackers and ensures their addresses are not leaked by any pointers directly. These defenses used safe areas to protect their critical data, such as jump targets and randomization secrets. However, recent works have shown that IH is vulnerable to various attacks.

In this paper, we propose a new IH technique called SafeHidden. It continuously re-randomizes the locations of safe areas and thus prevents the attackers from probing and inferring the memory layout to find its location. A new thread-private memory mechanism is proposed to isolate the thread-local safe areas and prevent adversaries from reducing the randomization entropy. It also randomizes the safe areas after the TLB misses to prevent attackers from inferring the address of safe areas using cache side-channels. Existing IH-based defenses can utilize SafeHidden directly without any change. Our experiments show that SafeHidden not only prevents existing attacks effectively but also incurs low performance overhead.

## 关键词
系统安全；信息隐藏；安全区；地址空间布局随机化(ASLR)
## 出处
USENix Security 2019, 赫赫有名的安全顶级学术会议
## 引用格式
[1]Wang Z, Wu C, Zhang Y, Tang B, Yew P-C, Xie M, Lai Y, Kang Y, Cheng Y, Shi Z. SafeHidden: an efficient and secure information hiding technique using re-randomization. 28th USENIX Security Symposium (USENIX Security 19). Santa Clara, CA: USENIX Association, 2019: 1239–1256.

**URL**: https://www.usenix.org/conference/usenixsecurity19/presentation/wang

## 作者
>Zhe Wang and Chenggang Wu, State Key Laboratory of Computer Architecture, Institute of Computing Technology, Chinese Academy of Sciences, University of Chinese Academy of Sciences; Yinqian Zhang, The Ohio State University; Bowen Tang, State Key Laboratory of Computer Architecture, Institute of Computing Technology, Chinese Academy of Sciences, University of Chinese Academy of Sciences; Pen-Chung Yew, University of Minnesota at Twin-Cities; Mengyao Xie, Yuanming Lai, and Yan Kang, State Key Laboratory of Computer Architecture, Institute of Computing Technology, Chinese Academy of Sciences, University of Chinese Academy of Sciences; Yueqiang Cheng, Baidu USA; Zhiping Shi, The Capital Normal University

一作为Zhe Wang，其导师武成岗为二作，来自中科院计算所国家计算机体系结构重点实验室。

三作张殷乾来自俄亥俄州立大学，曾有幸在[InfoSec][2]听过他对于安全方面论文发表的经验，其实验室和手下的博士生发表了很多的安全顶会论文。


# 笔记
## 论文主题
一种新型的内存地址随机化的增强方案SafeHidden，可以解决内存地址随机化（ASLR）的不安全问题。
## 待解决问题
先来介绍下内存地址随机化技术,这个技术，可以看一下这个[ASLR][1]。一些攻击，比如return-oriented programming (ROP)之类的[代码复用攻击][4]，会试图得到被攻击者的内存布局信息。这样就可以知道代码或者数据放在哪里，来定位并进行攻击。比如可以找到ROP里面的gadget。而ASLR让这些内存区域随机分布，来提高攻击者成功难度，让他们只能通过猜猜猜来进行不断试错的攻击(理想状况下)。下图举了个例子。

![ASLR](./ASLR.png)

但是ASLR已经不再安全，有多种方式可以对它发起攻击。如：
 - CROP Attack[NDSS 16]: 使用错误处理机制绕过读取安全区的crash。
 - 克隆探测攻击[S&P 14]: 通过探测子进程来避免让父进程crash。
 - 不断克隆安全区[Secruity 16]: 不断分发线程的安全区，通过不断开启新线程。 
 - 通过填补内存区空白[Security 16]: 不断分发内存占满未映射的区域。
 - 对页表进行攻击
## 之前方案不足

## 攻击模型
 - 假设这种基于信息隐藏的方式能够有效保护一个包含漏洞的程序，使其避免代码重用攻击（如web服务器或浏览器）。
 - 这种基于信息隐藏的防御没有漏洞。
 - 攻击者的能力
   - 读写任意内存位置
   - 分配和释放任意内存区域
   - 创建任意数量的进程
### 攻击类型
 1. 收集内存布局信息以帮助找到安全区域
 2. 创建探测机会而不会使系统崩溃
 3. 减少随机安全区域位置的熵
 4. 使用缓存侧通道监控页表访问模式
## 解决方案
###　使用**SafeHidden**来阻止这些攻击方式。
 - 修改可能泄漏位置的所有类型的探针
 - 在检测到可疑探针时随机化安全区域
 - 隔离线程本地安全区域
 - 检测到非法探测时引发安全警报
### 对于攻击类型1 
攻击类型1是收集内存布局信息以帮助找到安全区域。

![memory layout event](./vector1.png)
### 对于攻击类型2
 攻击类型2是创建探测机会而不会使系统崩溃。

![probe safe area](./vector2.png)
### 对于攻击类型3
攻击类型3是减少随机安全区域位置的熵。

SafeHidden可以防止未映射区域的无限缩小安全区域不受限制地增长。
 - 映射区域的最大大小设置为64 TB。
 - 使用线程专用内存机制隔离线程本地安全区域。
   - 不会减少熵。
   - 使用硬件辅助虚拟化技术
   - 每个线程将被分配一个线程专用EPT（扩展页表）
### 对于攻击类型4
 攻击类型4使用缓存侧通道监控页表访问模式。
 - 它需要数百个Prime + Probe或Evict + Time测试。
 - PTE的地址对应于此也是必要的内存区域不会改变。
 - 这些PTE映射的缓存条目不会更改。
  
 - SafeHidden还监控对可能的由攻击者故意触发的对安全区域的合法访问。
 - 一旦检测到这样的合法访问，安全隐藏将随机化安全区域的位置。
 - 对页表缓存侧通道攻击的**关键步骤**是强制页表行走。

![force-page-table-walk](./force-page-table-walk.png)
#### 将TLB miss转为页错误
 - 设置保留位后，将在页表行走期间触发页面错误异常。
 - 设置保留位后，将在页表行走期间触发页面错误异常。
   - 当TLB未命中时，它将被捕获到pf处理程序中。
#### 页表错误处理器的流程图
![Flowchart-of-Page-Fault-Handler.png](./Flowchart-of-Page-Fault-Handler.png)

### 系统整体设计
![architecture-overview.png](./architecture-overview.png)

## 效果
### 实验环境
 - X86_64/Linux
 - SafeHidden保护两个使用IH的防御。
   - 影子堆栈和O-CFI。
   - ％gs指向安全区域
 - 评分标准
   - **CPU密集型基准测试**：SPEC CPU2006和多线程Parsec-2.1。
   - **网络I/O**：多个进程Nginx和多线程Apache。
   - **磁盘I/O**：Bonnie ++基准测试工具 
### 性能评价
#### CPU密集型基准测试
 - SPEC CPU2006 benchmark with ref input
    - Incurred 2.75% and 2.76% when protecting O-CFI and Shadow Stack.
 - Multi-threaded Parsec-2.1 benchmark with native input
   - Incurred 5.78% and 6.44% when protecting O-CFI and Shadow Stack.
  
在网络I/O和磁盘I/O也都产生了一定的性能损耗，但都不超过15%

# 思考

## 收获
 - SafeHidden提出了针对所有已知攻击的基于重新随机化的IH技术。
 - SafeHidden引入了线程专用内存的使用来隔离线程本地安全区域。
 - 它设计了一种检测TLB未命中的新技术。

## 不足之处
有几点疑问，这篇论文的核心思想是增加重随机化，所以监控了很多个点，多增加了很多的随机化的东西，比如在监控到程序进行非正常的内存读写，监控到页表异常时，看起来并没有特别大的创新点。

## 可扩展结合的点
该论文对于计算机体系机构底层的认识，值得学习。

在PPT制作上，既要简单明了，还可以生动一些，这个上加了一些猫捉老鼠的图，很好。
# 论文评价
## 评分
> 满分5

⭐⭐⭐⭐

## 评价
给4星是由于本论文和我当前的工作可结合性不大，该论文对计算机体系结构底层有着很深刻的了解。此论文的作者来自中科院计算所计算机体系结构国家重点实验室，该实验室对于计算机底层的实现有着十分深刻的了解，所以能够写出这样的论文。本人才疏学浅，对于计算机体系结构底层的东西并没有这么深刻的体会，所以只是能看出来本论文好，但是对于它最大优势并没有太深感悟。

# 参考
[0]:https://www.usenix.org/conference/usenixsecurity19/presentation/wang "SafeHidden: An Efficient and Secure Information Hiding Technique Using Re-randomization"
[1]:https://www.inforsec.org/wp/?p=1009	"地址空间布局随机化(ASLR)增强研究综述"
[2]:http://www.inforsec.org/ "Infosec 网络安全研究国际学术论坛"

[3]: https://en.wikipedia.org/wiki/Address_space_layout_randomization	"Address space layout randomization（Wikipedia）"

[4]:https://zhuanlan.zhihu.com/p/39695776	"JOP代码复用攻击（知乎）"
