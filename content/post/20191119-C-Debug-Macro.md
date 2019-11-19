---
title: "C语言中常用的调试宏"
date: 2019-11-19
lastmod: 2019-11-19
tags: ["C","编程语言","code"]
categories: ["编程语言"]

---
# 背景
在C语言编写中，经常想因为调试的原因，插入一些临时输出的变量，或者执行一些不必要的指令。

写完之后频繁注释和反注释很耗时间，而且可能会造成不必要的错误。

因此作者采用了宏命令的方式，插入一些调试输出。

# 代码

```c
// File: debug.c
// some debug Macro
// #define DEBUG
#ifndef DEBUG_PRINT
#ifdef DEBUG
#define DEBUG_PRINT(fmt, args...)    fprintf(stderr, fmt, ## args)
#else
#define DEBUG_PRINT(fmt, args...)    /* Don't do anything in release builds */
#endif
#endif //DEBUG_PRINT

#ifndef DEBUG_RUN
#ifdef DEBUG
#define DEBUG_RUN(args)    {args ; }
#else
#define DEBUG_RUN(args...) 
#endif
#endif //DEBUG_RUN
```

# 使用方式

将上述代码加入到头文件中。

Gcc编译时加入-DDEBUG定义DEBUG宏
```shell
gcc -DDEBUG -o ./a.out 

```

对于DEBUG_PRINT,在代码中像正常printf一样使用。

对于DEBUG_RUN,在括号中的语句只有在DEBUG模式下才会执行。

```c
//File: main.c
#include <stdio.h>
#include "debug.c"
int a=10;
DEBUG_PRINT("%d\n",a);

char c[]="123123l123";
DEBUG_RUN(
	printf("%s",c);
)

```

Gis URL: https://gist.github.com/m2kar/6c9acef7a7cbf6540f40f74f5756be35
