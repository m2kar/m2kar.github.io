---
title: "[实验复现] How Machine Learning Is Solving the Binary Function Similarity Problem"
date: 2023-03-19T14:33:08Z

description: 
tags: []
issueId: 19
---

## 0x0 论文信息
- **标题:**  How Machine Learning Is Solving the Binary Function Similarity Problem
- **作者:** Andrea Marcelli, Mariano Graziano, Xabier Ugarte-Pedrero, and Yanick Fratantonio, Cisco Systems, Inc.; Mohamad Mansouri and Davide Balzarotti, EURECOM
- **关键字:** 二进制安全
- **来源:** SEC'22
- **链接:** https://www.usenix.org/conference/usenixsecurity22/presentation/marcelli
- **实验代码:** https://github.com/Cisco-Talos/binary_function_similarity
## 0x0 复现环境

- Window
- Ubuntu18.04(in WSL)  
> 由于环境依赖问题，本人复现时会在Windows和WSL之间切换，涉及到IDA Pro的部分使用Windows，其他部分使用WSL

- IDA Pro 7.3 For Windows
- capstone 3.0.5
- Python 3.8.16
- Python 2.7.13

## 0x01 数据获取
训练所需的数据作者均整理到了Google云盘，并可通过`gdrive_download.py`脚本下载。
```
python gdrive_download.py --binaries --features --results
```
> 旧版本的代码中的gdown版本不兼容，需要安装gdown==4.6.4，最新版本已解决此问题

## 0x02 数据集处理

数据集处理的步骤包括：

1. 编译：改变配置，基于源码，编译生成不同指令集架构、优化选项、编译器类型、编译器版本的二进制Binary
2. 生成IDB：通过IDA Pro，基于Binary生成IDB
3. 生成代码图数据：通过IDA Pro的扩展插件，基于IDB生成Flow图、ACFG汇编代码和ACFG特征
4. 数据筛选清洗：
5. 生成函数对：根据实验组中的编译优化、指令集等异同，组合生成用于训练的函数对
6. 数据集拆分：拆分得到训练、验证、测试集

### 0x02.1 编译

参看代码的 `Binaries/Compilation scripts/README.md` 部分，本文不详细介绍。

### 0x02.2 生成IDB

#### 配置IDA Pro
首先需要解决IDA Pro的安装问题。作者建议使用IDA Pro 7.3版本进行实验，但由于IDA Pro 7.3 for linux的资源很难找，所以本人在复现的时候使用了Windows版本的IDA Pro，代码可以完美运行。

在此之前需要设置环境变量指定IDA pro的位置。

```powershell
# 在powershell下设置环境变量
$env:IDA_PATH='D:\IDA 7.3\ida64.exe'
```

或者也可以通过WSL调用宿主机的IDA pro
```bash
export IDA_PATH=/mnt/d/IDA\ 7.3/ida64.exe
```
#### 运行生成IDB
环境配置完成后，可通过运行IDA_scripts/generate_idbs.py生成IDB

```bash
python3 generate_idbs.py 
```
其中`--db1 --db2 --dbvuln`参数可以任意组合。

成功运行结果：

![image](https://user-images.githubusercontent.com/16930652/227765780-16bc095e-80a4-4794-8383-d114acda4a62.png)


#### 代码解析：

```python
# 第72行
def export_idb(input_path, output_path):
    """运行IDA Pro并导出IDB"""
    try:
        print("Export IDB for {}".format(input_path))
        ida_output = str(subprocess.check_output([
            IDA_PATH,
            "-L{}".format(LOG_PATH),  # name of the log file. "Append mode"
            "-a-",  # enables auto analysis
            "-B",  # batch mode. IDA will generate .IDB and .ASM files
            "-o{}".format(output_path),
            input_path
        ]))
```

```bash
$ ida64.exe -L debug.log -a- -B -obinaryfile.idb  /path/to/binaryfile
```
### 0x02.3 生成代码图数据

通过IDA Pro的扩展插件，基于IDB生成Flow图、ACFG汇编代码和ACFG特征。

#### 安装capstone插件
本步骤需要在IDA pro的python环境中安装运行capstone 3.0.4。但由于ida pro 7.3的Linux版本不好找，因此使用在WSL中调用宿主机的IDA Pro 7.3的方式来运行，这就需要在IDA Pro 7.3的python2.7环境中安装capstone包。作者使用的是Linux环境，安装三方包更容易。

因此本人选择在window下需要额外安装python 2.7 x64，并在该环境中安装capstone。

首先尝试使用pip安装，但由于编译问题导致编译失败。（Windows下，涉及C代码的pypi扩展包编译安装是个大坑）

![image](https://user-images.githubusercontent.com/16930652/227766192-333877c3-d6bd-43cc-ac23-911fa1e35be6.png)

从项目主页找到了适用于Windows的预编译包，由于3.0.4版本未放出预编译包，因此使用了3.0.5版本。

链接：https://github.com/capstone-engine/capstone/releases/tag/3.0.5

下载其中的msi包，运行，选择python2.7的安装目录即可安装。

安装成功后在ida python中成功import capstone。

![image](https://user-images.githubusercontent.com/16930652/227766238-dd6efbd7-2b11-45be-91a4-482572ef634a.png)

#### 生成Flow图

在`IDA_scripts\IDA_flowchart`下执行： 

```powershell
#powershell

$env:IDA_PATH='D:\IDA 7.3\ida64.exe'

python .\cli_flowchart.py -i ..\..\IDBs\Dataset-1\ -o flowchart_Dataset-1.csv

```

运行成功截图：

![image](https://user-images.githubusercontent.com/16930652/227767320-cb13992e-4522-4467-af74-a936f587bab1.png)

> 如在WSL下运行，需要处理依赖路径转换的问题。

#### 生成ACFG汇编代码

#### 生成ACFG特征

### 0x02.4 数据筛选清洗

### 0x02.5 生成函数对

根据实验组中的编译优化、指令集等异同，组合生成用于训练的函数对。

### 0x02.6 
6. 数据集拆分：拆分得到训练、验证、测试集




## 0x03 复现Asm2Vec & Doc2vec实验

Asm2vec和Doc2vec实现由两个模块构成。第一个模块以ACFG逆向数据为输入，并输出所选函数的随机路径。然后，这些随机路径作为机器学习第二部分的输入。

## 

- [ ] 待补充

<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/19)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#19](https://github.com/m2kar/m2kar.github.io/issues/19)