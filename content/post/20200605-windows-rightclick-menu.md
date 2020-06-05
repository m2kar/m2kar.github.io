---
title: "Windows 定制右键菜单"
date: 2020-06-05
description: "Windows定制右键菜单。工具推荐&格式讲解"
tags: ["windows","右键菜单","技巧"]
categories: ["运维"]
---

# Windows 定制右键菜单

Windows的右键快捷菜单是个非常方便的东西。但有时候因为安装程序过多，所以右键菜单过于冗余。有的时候有需要自定义一些新的右键菜单项，因此我们需要了解右键菜单的知识。

## 工具

### 注册表
所有的右键菜单条目都在注册表的`HKEY_CLASSES_ROOT\XXXX\shell\`里。

![注册表位置](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200605084132.png)

### 第三方修改工具

1. [右键管家](http://youjiangj.com/)
1. Ultimate Windows Customizer, Right-Click Extender, Ultimate Windows Tweaker, & Context Menu Editor
2. ContextEdit
3. ShellExtView or  ShellMenuView
4. Easy Context Menu
5. MenuMaid
6. File Menu Tools.

这里还是比较推荐**右键管家**的，符合中国人操作习惯，而且功能很强大。

详细说明参考: https://www.thewindowsclub.com/remove-click-context-menu-items-editors/


## 修改技巧

下面介绍一些常用的修改技巧。

### 常用主体的注册表位置
常用的右键菜单主体都在注册表的`HKEY_CLASSES_ROOT`下面。

- **\*** : 表示所有文件
- **某扩展名**：如`.zip`,表示扩展名对应的右键菜单
- **Directory/Background**: 表示文件夹的背景

### 右键菜单注册表项结构

所谓百闻不如一见，下面就几个示例来讲解常用的右键菜单配置参数。

在所要创建的主体下面的`shell`下的`项`即为某个右键菜单项。其中默认值即为此项的显示名称。字符串项`Icon`为图标。如下图所示。

![20200605084839](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200605084839.png)

在右键菜单项的下一级创建项，并命名为`command`，表示此项的执行命令，命令的位置及参数应当写在`command`子项的`默认`中。通常用`%1`表示本文件的文件名参数。

![20200605084857](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200605084857.png)

也有一些高级的参数。比如下面的`PowerShell`，默认值用了使用了一个动态链接库。

然后`Extended`参数表示把此项在默认菜单中隐藏，需要按`Shift+右键`才可以显示。

`NoWorkingDirectory`表示不设置工作文件夹。
![20200605084914](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200605084914.png)

![20200605084935](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/20200605084935.png)


-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
