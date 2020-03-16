---
title: "Tmux快速使用"
date: 2020-03-13
description: "Tmux快速使用"
tags: ["tmux","linux","ssh","运维"]
categories: ["运维"]
---


# 背景
很多时候我们需要通过SSH连接服务器进行一些操作，费了好长时间调好了程序，一顿饭的功夫SSH超时了(broken pipe)，重新连上去正在运行的程序也都没了，一切又得从头再来。这个时候你就非常需要用到tmux了，用tmux在服务器上创建一个会话（Session），在该会话中进行操作，你可以随时随地断开和重新连接会话（Session），即便是SSH中断了你在远程服务器上的工作状态也可以持久化地保存。

# 安装
> ubuntu 操作系统
> 
```bash
sudo apt-get install tmux

# 同时安装Oh My Tmux组件包
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```

# 快捷键和常用命令
## 创建和重新连接
```bash
tmux new -s <session>
tmux a -t <session>
```
## 全局键
Tmux 官方默认时`C-b`.

.tmux 额外添加了`C-a`
下面用`<prefix>`代指示全局键

`<prefix>` 然后`:`可以输入指令。

## 会话操作(session)
| 快捷键 | 操作 | 指令 |
|--|--| --|
| `<preix> s` |  session 列表 | |
| `<preix> d` |  退出并在后台执行 | |
| `<preix> D` |  选择并退出所有其他的session | |
| `<preix> m` |  鼠标操作 | |

## 窗口操作(window)
| 快捷键 | 操作 |指令 |
|--|--|--|
| `<preix> c` |  创建新窗口 | |
| `<preix> 0...9` |  切换 | |
| `<preix> &` |  关闭当前窗口 | |
| `<preix> ,` |  重命名 | |

## 面板操作(Panes)
| 快捷键 | 操作 |指令 |
|--|--|--|
| `<preix> %` |  纵向分割 | |
| `<preix> “` |  水平分割 | |
| `<preix> ←↑↓→` |  切换 | |

# 参考
1. Oh My Tmux 参考: [gpakosz/.tmux(github)](https://github.com/gpakosz/.tmux)
2. 更多快捷方式参考：[Tmux Cheat Sheet & Quick Reference](https://tmuxcheatsheet.com/)

# 文章链接
- [Tmux快速使用](https://blog.csdn.net/still_night/article/details/104832882)

--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
