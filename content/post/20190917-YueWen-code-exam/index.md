---
title: "美团点评的几道笔试题"
date: 2019-09-12T00:00:00+08:00
lastmod: 2019-09-12T00:00:00+08:00
draft: false
tags: ["code","笔试","算法"]
categories: ["笔试"]
---

美团考试遇到了几个笔试题目，先记一下，有些题得重新做

# 黑客入侵点定位
## 题目描述

![黑客入侵点定位](黑客入侵点定位.png)

## 实现
分为两段执行：
1. 分别将模块1-12，模块1-24，模块1-48，... 模块1-144，模块1-150输入到第一款检测程序中，当检测程序输出为True时，进行下一步检测。假设此时输入的程序为$1-12*(x)$

2. 将模块
    $$1-12*(x-1),1-[12*(x-1)+1],1-[12*(x-1)+2],...,1-[12*(x-1)+11],1-12*(x)$$

  分别输入到检测程序，检测出则为被入侵的程序
> 但是这种实现方式存在问题，这里是假设平均分割，但可以不平均分割，这时候的方程如何列？

# 重复子序列

## 题目描述：

输入两个

输入整数序列A和B,输出同时在A，B中出现的最长子序列的长度。注意，子序列由原序列中的连续元素构成。

### 输入

```
第一行一个数n，表示序列A的长度
第二行n个数，表示序列A
第三行一个数m，表示序列B的长度
第四行m个数，表示序列B
（1<=n,m<=1000)
```
### 输出
```
输出结果
```
### 样例输入
```
5
1 2 3 2 1
5
3 2 1 4 7
```
### 样例输出
```
3
```
### 提示
```
即最长重复子序列为[3,2,1]
```
给了示例代码，包括输入部分

## 实现

```
def findMaxSubListLen( A, B):
    n1 = len(A)
    n2 = len(B)
    dp = [[0 for _ in range(n2+1)] for _ in range(n1+1)]
    
    for i in range(1,n1+1):
        for j in range(1,n2+1):
            if A[i-1] == B[j-1]:
                dp[i][j] = dp[i-1][j-1] + 1
    return max([max(row) for row in dp])

```

# 美团送餐分箱问题
棋手拿出装有货物的保温箱

![美团送餐问题1](美团送餐问题1.png)

![美团送餐问题2](美团送餐问题2.png)

## 实现
### python
```python
n=int(input())
sa=input()
a=[int(s) for s in sa.split()]
sb=input()
b=[int(s) for s in sb.split()]

s=sum(a)
d=list(zip(b,a))
d.sort(key=lambda x:x[0],reverse=True)
s0=0
i=0
while s0<s:
    s0+=d[i][0]
    i+=1

x1=i
x2=0
while i<n:
    x2+=d[i][1]
    i+=1
print(x1,x2)
```
### go
```go
/*
美团送餐
棋手拿出装有货物的保温箱

*/
package main

import (
	"fmt"
	"sort"
)

type Box struct {
	a int
	b int
}
type Boxs []Box

func (bs Boxs) Len() int { return len(bs) }
func (bs Boxs) Less(i, j int) bool {
	if bs[i].b == bs[j].b {
		return bs[i].a < bs[j].a
	}
	return bs[i].b < bs[j].b
}
func (bs Boxs) Swap(i, j int) {
	bs[i].a, bs[j].a = bs[j].a, bs[i].a
	bs[i].b, bs[j].b = bs[j].b, bs[i].b
}

func main() {
	var n int
	fmt.Scanf("%d", &n)
	fmt.Println(n)
	bs := make(Boxs, n)
	s := 0
	for i := 0; i < n; i++ {
		fmt.Scanf("%d", &bs[i].a)
		s += bs[i].a
		//   fmt.Println(a[i])
	}
	for i := 0; i < n; i++ {
		fmt.Scanf("%d", &bs[i].b)
	}
	sort.Sort(bs)
	s0 := 0
	x1 := 0
	for i := n - 1; i >= 0; i-- {
		fmt.Println(i, x1, s0, bs[i].b)
		if s0 < s {
			s0 += bs[i].b
			x1 += 1
		} else {
			break
		}

	}

	x2 := 0
	for i := 0; i < x1; i++ {
		x2 += bs[i].a
		fmt.Println(i, bs[i].a)
	}
	fmt.Println(x1, x2)

}

```

