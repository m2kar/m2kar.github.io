---
title: "如何把GitHub issue博客内容自动同步到github repo中的markdown文档中"
date: "2023-03-17"
lastmod: "2023-03-17"
draft: false
tags:
---
这个问题我问了chatgpt:



它给我回复了一个GitHub Workflows 配置文档。



这个 Workflows 将会在项目中有新的 issue 被创建或编辑时运行。它首先会检出代码库，并安装最新版的 Hugo。接下来，它会创建一个新的 Markdown 文件，其中包含了 issue 的标题和正文，并将其保存到项目的 blog 分支的 content/post 目录下，文件名格式为 {YYYYMMDD}-{Title}.md。最后，它会将更改提交到 blog 分支，并使用 GitHub API 的 token 进行身份验证。注意，为了使 Workflows 正确运行，你需要将 GitHub API 的 token 存储在你的项目的 secrets 中，并将其命名为 GH_TOKEN。
