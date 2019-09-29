---
title: "[工具]GitGot：一款可从GitHub公开数据中搜索敏感信息的半自动化快速搜索工具"
date: 2019-09-20T14:54:24+08:00
lastmod: 2019-09-20T14:54:24+08:00
draft: false
keywords: ["工具","GitGot","复现"]
description: ""
tags: []
categories: ["工具"]
author: "m2kar <m2kar.cn@gmail.com>"

---

# 介绍
今天给大家介绍的是一款名叫GitGot的半自动信息收集工具，在GitGot的帮助下，广大研究人员可以轻松从GitHub公开数据中搜索敏感信息。

# # 安装运行

**环境**: Kali Linux + docker

## 安装

运行gitgot-docker.sh文件来构建GitGot Docker镜像，并执行Docker化的GitGot版本工具。运行之后，gitgot-docker.sh文件将会在主机当前的工作目录下创建并加载logs和states目录。如果gitgot-docker.sh文件是直接从GitGot项目目录下运行的话，它将会更新Docker容器：

```bash
./gitgot-docker.sh
```

### 设置token

由于GitHub会限制访问频率，因此我们还需要一个令牌，我们可以直接创建一个无权限/无范围的GitHub API令牌：【[传送门](https://github.com/settings/tokens)】，这个令牌可以直接拿来访问公共GitHub库。Gitgot.py文件的顶部需要添加下列代码：

```python
ACCESS_TOKEN= "<NO-PERMISSION-GITHUB-TOKEN-HERE>"
```

![1568962383377](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568962383377.png)



## 工具使用



- 使用默认正则式列表和日志文件地址(/logs/<query>.log)查询字符串”example.com”

```
./gitgot.py -q example.com
```



尝试了一下 iscas.ac.cn

```
./gitgot.py -q iscas.ac.cn
```

搜索到了一些手机号,邮箱,姓名这样的敏感信息 

![1568963130665](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568963130665.png)

发现很多机器学习的恶意邮件分类数据集中竟然包含很多的较为敏感的邮箱和域名信息

![1568963695626](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568963695626.png)

可以使用交互命令设置是否显示内容。如果设置是否忽略相似内容，则会根据相似度判断是否忽略。

![1568963367464](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568963367464.png)

还有这种极度敏感的信息。

![1568963974671](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568963974671.png)

这是PHP的password_hash函数生成的密码。

https://moodle.org/mod/forum/discuss.php?d=315092&parent=1262609

https://www.php.net/password_hash

# 参考

1. [Github] GitGot https://github.com/BishopFox/GitGot

2. GitGot：一款可从GitHub公开数据中搜索敏感信息的半自动化快速搜索工具 https://www.freebuf.com/sectool/212124.html



