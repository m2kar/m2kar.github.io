---
title: "[算法] E02 递归解压并对压缩包内的数字求和"
date: 2019-08-15T01:37:56+08:00
lastmod: 2019-08-15T01:37:56+08:00
draft: false
tags: ["算法","python"]
categories: ["算法"]

---


# 背景
本题目想实现递归解压并对压缩包内的数字求和。
本题目来自中国科学院大学，算法概论课后作业02 源文件 。 

# Exercise (2). 
定义文件xx.tar.gz 的产生方式如下：
 - 以xx 为文件名的文件通过tar 和gzip 打包压缩产生，该文件中以字符串的方式记录
了一个非负整数；
 - 或者以xx 为名的目录通过tar 和gzip 打包压缩产生，该目录中包含若干xx.tar.gz。
其中，x 2 [0, 9]。  
  现给定一个根据上述定义生成的文件00.tar.gz (该文件从课程网站
下载)，请确定其中包含的以xx 为文件名的文件个数以及这些文件中所记录的非负整数之和。   
 > **00.tar.gz** 下载链接：[https://download.csdn.net/download/still_night/10820211](https://download.csdn.net/download/still_night/10820211)
# 代码实现（Python）

```python
import os,tarfile

def unpack_path_file(pathname):
    archive = tarfile.open(pathname, 'r:gz')
    path=os.path.split(os.path.abspath(pathname))[0]
    f,n=0,0 # 设置文件数和加和为0
    for tarinfo in archive:
        archive.extract(tarinfo, path)   # 解压压缩文件中的一个文件
        name=tarinfo.name # 解压的文件名
        tfname=os.path.join(path,tarinfo.name) # 解压后的文件路径
        if tarinfo.isfile(): # 如果是文件 存在待解压文件是.的情况 表示当前压缩文件
            if tarinfo.name.rfind(".tar.gz")!=-1: # 如果也是压缩文件，则递归解压它
                f1,n1=unpack_path_file(tfname)
                f+=f1
                n+=n1
                # 把调用函数的文件数量和数字和加上来
            else: # 如果不是压缩文件，则是数据文件，里面含有非负整数
                f+=1 # 文件数量加1
                with open(tfname) as fp:  # 读出来这个非负整数并加到n上
                    n+=int(fp.read())
    archive.close() # 关闭这个压缩文件
    return f,n  # 返回给上一级文件数量和加和
```


```python
# 调用函数开始解压
unpack_path_file("00.tar.gz")
```
## 结果
  - 文件数：3170
  - 加和：15752491  




--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://blog.csdn.net/still_night)
