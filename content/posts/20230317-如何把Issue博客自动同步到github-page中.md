---
title: "如何把Issue博客自动同步到github page中"
date: 2023-03-17T03:31:47Z

description: 
tags: []
issue_id: 14
---

这个问题我问了chatgpt:

### 问题1 
生成一段github的workflows配置文档，当有新issue的时候，自动将issue的内容同步到该GitHub项目的blog分支的content/post文件夹中的新Markdown文件中。文件名为"{YYYYMMDD}-{Title}.md",其中{YYYYMMDD}为issue的日期，"{Title}"为issue的标题。文件开头加上
```
---
title: 
data: 
lastmod:
draft: false
tags:
---
```

它给我回复了一个GitHub Workflows 配置文档。

```yml
name: Sync Issue to Blog

on:
  issues:
    types: [opened, edited]

jobs:
  sync-issue-to-blog:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v2

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "latest"

      - name: Create Blog Post
        id: create_post
        run: |
          issue_title=$(echo "${{ github.event.issue.title }}" | sed 's/[[:space:]]/-/g')
          issue_date=$(echo "${{ github.event.issue.created_at }}" | cut -c1-10 | sed 's/-//g')
          post_path="content/post/${issue_date}-${issue_title}.md"
          post_date=$(echo "${{ github.event.issue.created_at }}" | cut -c1-10)
          post_title=$(echo "${{ github.event.issue.title }}" | sed 's/"/\\"/g')
          post_body=$(echo "${{ github.event.issue.body }}" | sed 's/"/\\"/g')
          echo "---" > "${post_path}"
          echo "title: \"${post_title}\"" >> "${post_path}"
          echo "date: \"${post_date}\"" >> "${post_path}"
          echo "lastmod: \"${post_date}\"" >> "${post_path}"
          echo "draft: false" >> "${post_path}"
          echo "tags:" >> "${post_path}"
          echo "---" >> "${post_path}"
          echo "${post_body}" >> "${post_path}"

      - name: Commit and Push Changes
        run: |
          git config --global user.name "${{ github.actor }}"
          git config --global user.email "${{ github.actor }}@users.noreply.github.com"
          git add .
          git commit -m "Sync issue #${{ github.event.issue.number }} to blog"
          git push origin blog
        env:
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
```

这个 Workflows 将会在项目中有新的 issue 被创建或编辑时运行。它首先会检出代码库，并安装最新版的 Hugo。接下来，它会创建一个新的 Markdown 文件，其中包含了 issue 的标题和正文，并将其保存到项目的 blog 分支的 content/post 目录下，文件名格式为 {YYYYMMDD}-{Title}.md。最后，它会将更改提交到 blog 分支，并使用 GitHub API 的 token 进行身份验证。注意，为了使 Workflows 正确运行，你需要将 GitHub API 的 token 存储在你的项目的 secrets 中，并将其命名为 GH_TOKEN。



### 问题2

后面我又完善了gpt给的回答，重新问了new bing。

编写github action配置文件: 当issue的open/edit事件触发时，使用GitHub CLI client获取issue的详细信息。

定义issue的id为ISSUE_ID。遍历content/posts/下的所有markdown文件，读取markdown文件头部的yaml部分，如果存在issue_id=${ISSUE_ID}，那么定义变量POST_PATH=该markdown文件路径，否则定义变量POST_PATH="content/post/${issue_date}-${issue_title}.md"。

设置环境变量BLOG_TITLE为issue的标题， 

设置环境变量BLOG_DATE为issue的创建时间，

格式为2020-09-15T11:30:03+00:00， 

设置环境变量BLOG_DESCRIPTION为空白， 

设置环境变量BLOG_TAGS为issue的标签列表，格式为["tag1","tag2"],

设置环境变量BLOG_CONTENT为issue的内容，基于markdown格式。

最后，使用envsubst命令，用环境变量更新template/template.md的内容，将更新后的文件保存在${POST_PATH}路径下。

```yaml
# This is a basic workflow to help you get started with Actions

name: Blog Post Generator

# Controls when the action will run. 
on:
  # Triggers the workflow on issue open or edit events
  issues:
    types: [opened, edited]

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This job generates a blog post from an issue
  generate-post:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v2
      
      # Installs GitHub CLI on the runner (you may need to adjust this according to your OS)
      - name: Install GitHub CLI
        run: |
          sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
          sudo apt-add-repository https://cli.github.com/packages
          sudo apt update
          sudo apt install gh
      
      # Authenticates to GitHub using a personal access token (you need to store it as a secret in your repository settings)
      - name: Authenticate to GitHub
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh auth login --with-token < $GITHUB_TOKEN
      
      # Runs a bash script to set environment variables and update template file using GitHub CLI and envsubst commands
      - name: Run bash script
        env:
          ISSUE_ID: ${{ github.event.issue.number }}
        run: |
          # Get the issue data from GitHub CLI using gh api command (you may need to specify owner and repo flags)
          issue_data=$(gh api issues/${ISSUE_ID})
          # Set BLOG_TITLE to the issue's title
          BLOG_TITLE=$(echo "$issue_data" | jq -r '.title')
          # Set BLOG_DATE to the issue's creation time, formatted as 2020-09-15T11:30:03+00:00
          BLOG_DATE=$(echo "$issue_data" | jq -r '.created_at')
          # Set BLOG_DESCRIPTION to blank
          BLOG_DESCRIPTION=""
          # Set BLOG_TAGS to the issue's label list, formatted as ["tag1","tag2"]
          BLOG_TAGS=$(echo "$issue_data" | jq -r '[.labels[].name]')
          # Set BLOG_CONTENT to the issue's content, based on markdown format
          BLOG_CONTENT=$(echo "$issue_data" | jq -r '.body')
          # Export these variables so they can be used by envsubst command later
          export BLOG_TITLE BLOG_DATE BLOG_DESCRIPTION BLOG_TAGS BLOG_CONTENT
          # Loop through all markdown files under content/posts/
          for file in content/posts/*.md; do
            # Read the yaml part at the top of each file using yq command (you may need to install yq first)
            yaml_part=$(yq e '.' $file)
            # Check if there is an issue_id field that matches ISSUE_ID 
            if [[ $(echo "$yaml_part" | yq e '.issue_id' -) == "$ISSUE_ID" ]]; then
              # If yes, set POST_PATH to that file path and break out of loop 
              POST_PATH=$file 
              break 
            else
              # If no, set POST_PATH using issue date and title (you may need to adjust this according to your desired format)
              POST_PATH="content/post/${BLOG_DATE}-${BLOG_TITLE}.md"
            fi
          done
          # Use these variables to update template/template.md's content using envsubst command (you may need to adjust this according to your template format)
          envsubst < template/template.md > ${POST_PATH}
      # Commits and pushes the updated file to your repository (you may need a personal access token for this step)
      - name: Commit and push changes        
      run: |
      git config --global user.name 'GitHub Action'
      git config --global user.email 'action@github.com'

git add ${POST_PATH}
git commit -m "Update blog post from issue $ISSUE_ID"
git push origin main
```
### 微调
github cli客户端是默认安装在github workflow的container中的，所以不需要额外安装，只需要调用的时候传入环境变量${GITHUB_TOKEN}就好了。

所以删除了Install GitHub CLI和Authenticate to GitHub的步骤.

### 触发网站更新操作
在gh-page.yml中的on下添加workflow_run配置。

```yaml
on:
 ......
  workflow_run:
    workflows:
      - "issue-to-post"
    types:
      - completed
```

> 参考：https://docs.github.com/en/actions/using-workflows/using-github-cli-in-workflows

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#14](https://github.com/m2kar/m2kar.github.io/issues/14)