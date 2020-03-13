---
title: "华为的几道笔试题"
date: 2019-09-11T00:00:00+08:00
lastmod: 2019-11-08T00:00:00+08:00
draft: false
tags: ["code","笔试","算法"]
categories: ["笔试"]
author: "m2kar <m2kar.cn@gmail.com>"

---

华为考试遇到了几个笔试题目，先记一下，有些题得重新做、
>笔试信息试卷名称：【华为2019年校园招聘】2019-9-11 软件题
>考试时间：(北京时间,UTC+08:00)09-11 19:00:00 -- 21:10:00
>考试时长：120分钟
>考试地址：https://exam.nowcoder.com/cts/17045150/summary?xxxxxxxxxxxx（考试地址为你的私人专属地址，请勿转发。如无法直接打开，请拷贝完整链接并粘贴至浏览器地址栏）
>硬件模拟试卷链接：https://www.nowcoder.com/cts/9540163/summary
>软件模拟试卷链接：https://www.nowcoder.com/cts/9540156/summary
>注：可提前进入模拟试卷链接熟悉题型和考试环境，方便您更顺利通过考试。
>
>![1568223500508](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223500508.png)

# 数轴相邻点问题
## 题目描述

s

![1568223716592](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223716592.png)

![1568223741218](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223741218.png)

![1568223775864](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223775864.png)
## 解答
```python
s=input()
A=[]
B=[]
R=0
area=""
s=s.replace("{","").replace("}","").replace("=",",")
for x in s.split(","):
    if x in "ABR":
        area=x
    elif x in "={}":
        pass
    else:
        if area=="A":
            A.append(int(x))
        elif area=="B":
            B.append(int(x))
        elif area=="R":
            R=int(x)
        else:
            raise ValueError
i=0
j=0
na=len(A)
nb=len(B)
sj=0
while i<na:
    while sj<nb and A[i]>B[sj] :
        sj+=1
    if sj>=nb:
        break
    j=sj
    while j<nb and B[j]-A[i]<=R :
        print("(%s,%s)"%(A[i],B[j]),end="")
        j+=1

    if j==sj:
        print("(%s,%s)"%(A[i],B[j]),end="")
    i+=1
print()
        
    
    


```

# 字符串倒序排列问题
## 题目描述
![1568223787906](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223787906.png)

![1568223801491](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223801491.png)

![1568223816084](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223816084.png)
## 解答
```python
import string
CHR=string.digits+string.ascii_letters
s=input()
l=[]
n=len(s)
i=0
while i<n:
    if s[i] in CHR:
        l.append("")
        while i<n and (s[i] in CHR or s[i]=="-"):
            if s[i]=="-":
                if not(i+1<n and s[i+1] in CHR):
                    break
            l[-1]+=s[i]
            i+=1
    else:
        i+=1

print(" ".join(l[::-1]),end=" ")
```
# 航班线路问题
## 题目描述
![1568223832820](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223832820.png)

![1568223841507](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223841507.png)

![1568223914401](https://cdn.jsdelivr.net/gh/m2kar/bucket/img/1568223914401.png)
## 解答
```python
N=int(input())
old={}
for _ in range(N):
    fid,sid,name=input().split(',')
    old[(fid,sid)]=name
new={}
M=int(input())
names={}
for _ in range(M):
    ofid,osid,nfid,nsid=input().split(',')
    ofs=(ofid,osid)
    nfs=(nfid,nsid)
    name=old.pop(ofs,)
    if names.get(name,("",""))[0]==nfid:
        new.pop(names[name],)
    new[(nfid,nsid)]=name
    names[name]=(nfid,nsid)

for fs,name in old.items():
    if not (fs in new or names.get(name,("",""))[0]==nfid) :
        new[fs]=old[fs]

l=sorted(list(new.items()),key=lambda x: x[0])
for fs,name in l:
    print("%s,%s,%s"%(fs[0],fs[1],name))

```


--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://blog.csdn.net/still_night)
