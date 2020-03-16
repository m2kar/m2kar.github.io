---
title: "批量迁移Gitee仓库到Github"
date: 2019-12-06
description: "批量迁移Gitee仓库到GitHub"
tags: ["Git","Github","Gitee","迁移仓库"]
categories: ["运维"]

---

# 背景
虽然Gitee仓库蓬勃发展，趋势很好，但是客观来讲，和Github的易用性还是有一定差距的。

当初由于Github私有仓库数量的限制，所以把很多私有的小项目的仓库都放到了gitee。

最近随着Github的免费仓库不再限制数量，所以把私有仓库和公有仓库都挪到一起放到github挪上了日程。

由于建的仓库有些多，所以手动逐个挪比较费时间，而且学习一下GitHub的API操作，对以后的工作可能会有帮助，所以我采取了脚本的方式完成这个事情。

下面分享我做这个事情的几个步骤。

# 步骤

1. 获取项目列表
2. 克隆
3. github创建项目API
4. 上传
5. 归档

# 获取Gitee项目列表：
没有找到gitee的API,所以采取手动浏览器解析网页的方式获得仓库列表，这里主要获得了仓库名和仓库的描述。

### 在gitee网站执行JS脚本
```js
l=[]

$.each($("#search-projects-ulist div.list-warpper"),function(i,v){
	dl=$(".description",v);
	console.log(dl);
	des=dl.length>0?dl[0].textContent:"";
	j={
		"path":v.attributes["data-path"].value,
		"des":des+" https://gitee.com/"+v.attributes['data-path'].value
		};
	l.push(j);
	})
```

其中除了`l=[]`,需要手动翻页，每次翻页都要执行一次。

得到的`l`是所有项目列表。
```js
JSON.stringfy(l);
```

输出所有。

## 然后导入到python。

```python
import json
j=json.loads(s)
l=[]
for i,v in enumerate(j):
    l.append({
        "name":os.path.split(v["path"])[1],
        "path":v["path"],
        "des":v["des"],
    })
    
```
## 处理后示例
```
[{'name': 'repo1',
  'path': 'username/repo1',
  'des': ' https://gitee.com/username/repo1'},
  {'name': 'repo2',
  'path': 'username/repo2',
  'des': ' https://gitee.com/username/repo2'}]
```

# 克隆项目
这里使用python调用linux 下 git客户端完成

```python
for i,v in enumerate(l):
    os.system(f"git clone git@gitee.com:{v['path']}.git {v['name']}")
```

# 创建Github项目列表

这里采用了PyGithub库。

```bash
$ pip install PyGithub
```

需要设置Github的token，申请token参看 https://github.com/settings/tokens 

```python
from github import Github
g = Github("0a25fe745xxxxxxxxxxxxxxxxxxxxxxx") # token
user=g.get_user()
hub_repos=[]
repoddl=[repo for repo in user.get_repos()]
reponames=[repo.name for repo in repoddl] # 当前已有的项目列表
for i,v in enumerate(l):
    print(v)
    
    if v["name"] in reponames: # 如果重名，则跳过
        print("Exists")
    else:
        des=re.sub("[\n\t\b]","",v["des"])
        hub_repos.append(user.create_repo(v["name"],description=des,private=True))  # 创建，并设置权限为私有
        print("created")
```



# 上传

## 所有repo的字典
先建立一个所有repo的字典。
```python
repod={}
for repo in user.get_repos():
    repod[repo.name]=repo

```
## 调取git 命令客户端进行添加源和push操作。
```python
for i,repo in enumerate(l):
    cmd=f" pushd {repo['name']} && git remote add gh {repod[repo['name']].ssh_url} && git push gh master && popd "  
    print(cmd)
    os.system(f"bash -xc '{cmd}' 1>>  log.txt 2>>log.txt")
    print(f"{repo} done")
```

## 对于上传错误的进行补全
上传中会出现一些项目未能成功push。
用下面的方法补漏。

```python
for i,repo in enumerate(l):
    cmd=f" pushd {repo['name']} && git push gh master && popd "
    print(cmd)
    os.system(f"bash -xc '{cmd}' 1>>  log.txt 2>>log.txt")
    print(f"{repo} done")

```

# 归档

由于迁移的项目均为老旧项目，因此对其进行归档操作。

由于PyGithub未找到对项目归档的功能，所以使用GitHub的官方API进行操作。


```python
import requests
from requests.auth import HTTPBasicAuth

def archieve(repo):
        req=requests.patch(url=f"https://api.github.com/repos/m2kar/{repo}",
                   json={"archived":True},
auth=HTTPBasicAuth("my_user_name","0a25fexxxxxxxxxxxxxxxxxxxxxxxxxxxx") # 使用了HTTP基本认证
                  )
        try:
            if req.json()["archived"]==True:
                print(f"{repo} Success")
        except:
            print(f"{repo} Fail")
            
for v in l:
    archieve(v["name"])

```
注意使用了HTTPBasicAuth，需要把代码中的用户名和token进行替换。



# 参考
 - **pyGithub**: https://pygithub.readthedocs.io/en/latest/
 - **Github API**: https://developer.github.com/v3/repos/
 
 --------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)
