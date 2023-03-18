---
title: "[技术分享] 编写bash命令，过滤变量BLOG_CONTENT中包括换行符的所有的标点符号，连接为一行，通过pipe传递给head命令"
date: 2023-03-18T17:16:56Z

description: 
tags: []
issueId: 16
---

[你好，这是Bing。我可以帮你写一个bash命令，过滤变量BLOG_CONTENT中包括换行符的所有的标点符号，连接为一行，通过pipe传递给head命令。根据搜索结果](https://stackoverflow.com/questions/67779103/can-you-insert-a-newline-in-between-pipes-in-a-shell-script)[1](https://stackoverflow.com/questions/67779103/can-you-insert-a-newline-in-between-pipes-in-a-shell-script)[2](https://tldp.org/LDP/abs/html/textproc.html)[3](https://stackoverflow.com/questions/19345872/how-to-remove-a-newline-from-a-string-in-bash)[4](https://stackoverflow.com/questions/12524308/bash-strip-trailing-linebreak-from-output)，你可以使用以下命令：

```
sed 's/ [ [:punct:]]//g' <<< "$BLOG_CONTENT" | tr -d '\n' | head
```

这个命令会把变量BLOG_CONTENT的内容传给sed，然后用空字符替换所有的标点符号。[[:punct:]]是一个字符类，表示所有的标点符号。<<<是一个bash特性，叫做here字符串，它可以把一个字符串当作输入传给一个命令。

然后，这个命令会用管道（|）把sed的输出传给tr，然后用-d选项删除所有的换行符（\n）。tr是一个文本处理工具，它可以转换或删除字符。

最后，这个命令会用管道（|）把tr的输出传给head，然后打印出前面几行。head是一个文本处理工具，它可以显示文件或输入流的开头部分。

如果你还有其他问题，请继续问我。😊

<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/16)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#16](https://github.com/m2kar/m2kar.github.io/issues/16)