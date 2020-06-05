---
title: "Zotero使用技巧"
date: 2020-06-03
description: "Zotero使用技巧:文献同步、修改默认文件名、标签快捷键、分级、Sci-hub支持"
tags: ["zotero","论文阅读"]
categories: ["工具收藏"]
---

# Zotero 使用技巧

## 设置文献同步

1. 文献数据库使用Zotero账户同步
2. 文件使用坚果云的WebDAV服务同步

![Zotero配置文献同步](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603112907.png)

## 修改PDF默认文件名

打开`首选项`-`高级`-`常规`-`设置编辑器`。

搜索`extensions.zotero.attachmentRenameFormatString`，修改为

```
{%t{50} - }{%c - }{%y}
```

![修改PDF默认文件名](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603113221.png)

## 快速打标签
1. 可以通过在标签上指定颜色，选择位置。即可在条目上按数字键快速打标签。
![标签快捷键](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603113627.png)

2. 标签命名为简单的数字为开头或者`*+数字`为开头，通过Zotero对标签的检索功能快速打标签。
![标签命名技巧](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603113830.png)

## 分级
分级打星标是Endnote中比较好用的功能，但是zotero中没有，但是我们可以通过标签功能快速分级。

![标签分级](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603113939.png)

```
*1⭐
*2⭐⭐
*3⭐⭐⭐
*4⭐⭐⭐⭐
*5⭐⭐⭐⭐⭐
```
也可以使用[快速打标签](#快速打标签)中介绍的内容实现快速标签

## sci-hub支持

此功能需要下载安装插件：

1. 下载插件：[zotero-scihub/release](https://github.com/ethanwillis/zotero-scihub/releases)
2. 拖拽到`工具`-`插件`
3. 重启Zotero

![zotero插件](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200603114800.png)

参考： https://github.com/ethanwillis/zotero-scihub

## 参考文献格式
一般选择国标 GB/T 7714。最新版为2015.


### 软件学报格式

参见:[软件学报参考文献格式](https://m2kar.cn/post/20190905-jos-csl/)

-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
