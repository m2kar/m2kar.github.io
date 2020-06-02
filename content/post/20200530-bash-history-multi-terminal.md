---
title: "Bash 终端配置优化"
date: 2020-05-30
description: "Bash配置文件类型，同时保存多个终端的命令记录，更改历史记录数"
tags: ["bash","linux","运维"]
categories: ["运维"]

---

# Bash优化

Bash可以称之为使用最为广泛的终端程序了！

之前特别喜欢用zsh+oh-my-zsh，很方便很好看的终端程序，傻瓜化且人性化的配置，但是无奈在windows下不是很理想。最近喜欢用上了Windows下的git-bash，因为这个非常简单的bash在windows下运行的很快很好。因此也寻找了一下zsh中比较喜欢的一些功能，并让它能在bash下支持。

下面将列举一些让默认的Bash更加好用的一些修改。

## 修改配置文件

### 配置文件种类

全局配置：`/etc/profile`, `/etc/profile.d/*.sh`, `/etc/bashrc`

个人配置：`~/.bash_profile`,  `~/.bashrc`

profile类文件作用:

- 定义环境变量
- 运行命令或者脚本

bashrc类文件作用:

- 定义本地变量，函数
- 命令别名

通常会编辑 ~/.bashrc，在文件最后添加某些语句。

### 加载顺序

登陆式Shell: 

```bash
/etc/profile > .bash_profile > .bash_login > .profile > .bash_logout
```

非登陆式Shell:

```bash
/etc/bash.bashrc > .bashrc
```

详情参看： [Bash配置文件][1]

## Bash历史记录优化

### Bash同时保存多个终端的命令记录

编辑 ~/.bashrc，在文件最后添加下面的语句：

```bash
export PROMPT_COMMAND='history -a'
```

重新启动终端，即可在多个终端中同时保存命令到History.


### 设置可保存的历史记录数量
```bash
export HISTSIZE=10000
```


[1]: https://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_linux_010.html

-------

- 欢迎评论以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
