---
title: "【论文笔记】SoK: Security Evaluation of Home-Based IoT Deployments"
date: 2019-10-11
draft: False
keywords: ["论文","Sok","系统安全","物联网"]
description: "使用图和组合的方法评估家庭物联网的安全性"
tags: ["论文笔记","系统安全","物联网"]
categories: ["论文笔记"]

---

# 概览
## 摘要
Home-based IoT devices have a bleak reputation regarding their security practices. On the surface, the insecurities of IoT devices seem to be caused by integration problems that may be addressed by simple measures, but this work finds that to be a naive assumption. The truth is, IoT deployments, at their core, utilize traditional compute systems, such as embedded, mobile, and network. These components have many unexplored challenges such as the effect of over-privileged mobile applications on embedded devices. Our work proposes a methodology that researchers and practitioners could employ to analyze security properties for home-based IoT devices. We systematize the literature for home-based IoT using this methodology in order to understand attack techniques, mitigations, and stakeholders. Further, we evaluate 45 devices to augment the systematized literature in order to identify neglected research areas. To make this analysis transparent and easier to adapt by the community, we provide a public portal to share our evaluation data and invite the community to contribute their independent findings.

基于家庭的物联网设备在其安全实践方面惨不忍睹。从表面上看，物联网设备的不安全性似乎是由集成问题引起的，可以通过简单方法解决。但这项工作发现这是非常浅显的认识。事实是，物联网部署的核心是利用传统的计算系统，例如嵌入式，移动和网络。这些组件具有许多未稳定的尝试，例如，过于特权的移动应用程序对嵌入式设备的影响。我们的工作提出了一种方法，研究人员和从业人员可以采用该方法来分析基于家庭的物联网设备的安全属性。我们使用此方法将基于家庭的物联网的参考资料系统化，以了解攻击技术，缓解措施和利益相关方。此外，我们评估了45个设备以扩充系统化的参考资料，以识别被忽视的研究领域。为了使此分析透明并易于社区适应，我们提供了一个公共门户网站来共享我们的评估数据，并邀请社区贡献其独立的发现。

## 关键词
 - 系统安全
 - 物联网

## 引用格式
Omar Alrawi, Chaz Lever, Manos Antonakakis, Fabian Monrose; SoK: Security Evaluation of Home-Based IoT Deployments, IEEE S&P (Oakland), May 2019.
## 作者
Omar Alrawi, Chaz Lever, Manos Antonakakis, Fabian Monrose

其中一作Omar Alrawi的主页为： https://alrawi.github.io/

作者来自美国佐治亚理工学院，导师为	Manos Antonakakis。

导师研究方向为计算机和网络安全，异常检测，数据挖掘和攻击溯源。导师主页为： https://sites.google.com/site/antonakakis/pubs。 发表了很多安全相关的顶会论文。


# 笔记
## 论文主题
使用图和组合的方法评估家庭物联网的安全性
## 待解决问题

 - 物联网安全性太差。
 - 由于网络系统复杂性搭建安全物联网并不简单。
 - 供给面太广。

## 解决方案
使用基于物联网组件的框架，探索设备、软件、云端和网络终端之间的联系，另外还有指纹组件，可以更好地理解网络中的行为。构建了一个图结构表示物联网中的各个组成成分。

![设计思想](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20191011102625.png)

## 效果
作者对45款热门的设备进行分析。

**实验设备**:

![实验设备](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20191011102911.png)

**设备分析情况**:

![设备分析情况](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20191011102944.png)

![20191011102953.png](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20191011102953.png)

# 思考
## 收获
使用图的思想，对家用物联网环境下的物联网设备进行综合性全面的分析。
## 不足之处
图只是作为关联和思想，没有真正应用到图。
## 可扩展结合的点
# 论文评价
## 评分
> 满分5
⭐⭐⭐⭐⭐

## 评价
论文对于设备的分析非常全面和到位。

# 参考资料及附件
作者官网：https://alrawi.github.io/

其他参考资料

 - [slides-long](https://alrawi.github.io/static/slides/M3AAWG_iot_feb_2019.pdf)
 - [slides-short](https://alrawi.github.io/static/slides/IEEESP_iot_may_2019.pdf)
 - [website](https://yourthings.info/)
 - [VIDEO: One min Preview](https://www.youtube.com/watch?v=-KCia-uTr-8)
 - [VIDEO: Conf. Presentation](https://www.youtube.com/watch?v=Yg807tkRSZ8)


--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
