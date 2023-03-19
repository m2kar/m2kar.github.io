---
title: "如何把Issue博客自动同步到github page中 | M2kar's Security World"
date: 2023-03-19T13:14:58Z

description: 
tags: [
  "blog"
]
issueId: 17
---

# 如何把Issue博客自动同步到github page中 | M2kar's Security World

这个问题我问了chatgpt:
问题1 生成一段github的workflows配置文档，当有新issue的时候，自动将issue的内容同步到该GitHub项目的blog分支的content/post文件夹中的新Markdown文件中。文件名为"{YYYYMMDD}-{Title}.md",其中{YYYYMMDD}为issue的日期，"{Title}“为issue的标题。文件开头加上
---
title: data: lastmod:
draft: false
tags:
---
它给我回复了一个GitHub Workflows 配置文档。
name:Sync Issue to Blogon:issues:types:[opened, edited]jobs:sync-issue-to-blog:runs-on:ubuntu-lateststeps:- name:Checkout Codeuses:actions/checkout@v2- name:Setup Hugouses:peaceiris/actions-hugo@v2with:hugo-version:"l

[https://m2kar.cn/posts/20230317-%E5%A6%82%E4%BD%95%E6%8A%8Aissue%E5%8D%9A%E5%AE%A2%E8%87%AA%E5%8A%A8%E5%90%8C%E6%AD%A5%E5%88%B0github-page%E4%B8%AD/](https://m2kar.cn/posts/20230317-%E5%A6%82%E4%BD%95%E6%8A%8Aissue%E5%8D%9A%E5%AE%A2%E8%87%AA%E5%8A%A8%E5%90%8C%E6%AD%A5%E5%88%B0github-page%E4%B8%AD/)

<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/17)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#17](https://github.com/m2kar/m2kar.github.io/issues/17)