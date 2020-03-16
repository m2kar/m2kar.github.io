---
title: "[编程]ipython后台任务多线程执行"
date: 2019-11-27
lastmod: 2019-11-27
keywords: ["python","ipython","多线程","编程"]
categories: ["编程"]
author: "m2kar <m2kar.cn@gmail.com>"
---

# 背景
jupyter notebook是以ipython为内核的，在编写程序的时候，经常遇到有些高IO的函数在后台运行半天，但是又需要在它运行的时候执行别的任务，因此这就用到了多线程。

其实ipython 已经封装好了多线程工具，只需要调用即可执行

# 简单使用
```

from IPython.lib import backgroundjobs as bg
from time import sleep

jobs = bg.BackgroundJobManager()

def func1():
  sleep(1000000)
  return 1

# 创建任务
jobs.new(func1)

# 任务状态
jobs.status()
# Running jobs:
# 0 : <function func1 at 0x7fae1b670c80>

# 执行结果
result=jobs.result(0)

```

# 官方代码

<script src="https://gist.github.com/m2kar/cd171c13c2d1094316d3cb3cb9a56899.js"></script>


--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
