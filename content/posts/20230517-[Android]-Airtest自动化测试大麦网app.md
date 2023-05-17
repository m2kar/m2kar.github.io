---
title: "[Android] Airtest自动化测试大麦网app"
date: 2023-05-17T10:19:30Z

description: 
tags: []
issueId: 20
---

# 0x01 缘起

疫情结束的2023年5月，大家对出去玩都有点疯狂，歌手们也扎堆开演唱会。但演唱会多，票一点也不好抢，抢五月天的门票难度不亚于买五一的高铁票。所以想尝试找一些脚本来辅助抢票，之前经常用selenium和request做一些小爬虫来搞定自动化的工作，所以在 [MakiNaruto/Automatic_ticket_purchase](https://github.com/MakiNaruto/Automatic_ticket_purchase)  的基础上改了改，实现抢票功能。但是大麦网实在太**狡猾**了，改完爬虫才发现几乎所有的热门演唱会只允许在app购买，所以就需要利用APP实现接口自动化。

# 0x02 Airtest自动化测试

首先想到的是利用对UI的操作实现此功能，目前比较流行的框架是网易的poco和appium，对比了一下发现poco比较简单好上手，而且也基于python语法，因此笔者选择了此框架。

## 运行环境搭建

-  Airtest IDE:  poco运行基于网易的Airtest IDE，官网下载解包安装即可
-  adb调试： 打开安卓手机的设置中开发者选项的usb调试功能。对于小米和华为手机，还应当允许通过USB安装应用。

配置好后，点击connect即可连接到手机

<p align="center">
<img src="https://github.com/m2kar/m2kar.github.io/assets/16930652/7cead540-fcf2-4b61-82ca-4040cf7a38d2" alt="连接设备"  height="200"/>
</p>

## 操作录制

我认为Airtest IDE最方便的地方莫过于自动分析apk窗口的控件，并录制操作，生成代码。如下图，点击poco辅助窗的右上角按钮，即可开始录制。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/a297bc35-23fb-4426-bfe8-41c3c0715fcf)

此时点击设备窗的中对应的控件，即可在左侧的代码窗中自动生成代码。

![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/29da7dd0-db4c-4594-9cc6-b337424746f0)

生成的代码示例
```python
# 点击操作
poco("cn.damai:id/project_poster_mask_iv").click()
poco("cn.damai:id/rich_text_tv").click()
poco("cn.damai:id/tv_left_main_text").click()
poco("cn.damai:id/title_back_btn").click()

# 滑动操作
poco("cn.damai:id/rich_text_tv").swipe([-0.0254, -0.3666])
```
除此之外，还可以支持inspector模式。点击下图红色按钮的部分即可打开inspector，类似chrome浏览器控制台的inspector。然后在设备窗中移动鼠标，并在目标位置点击右键，也可以看到控件的名称。

inspector模式：
![image](https://github.com/m2kar/m2kar.github.io/assets/16930652/96c9a24b-487a-4898-8959-1356903cf0ac)

另外，还可以在poco辅助窗中点开窗口的树结构的节点，分析具体的控件名称和类型

## 其他控件操作
1. **等待控件出现**。`wait(timeout=1)`，如果控件在timeout时间内出现，则返回控件，否则返回None

如下面的代码等待sku_contanier出现，如果未出现，则证明本页面非选择票档的页面：
```python
    if not poco("cn.damai:id/sku_contanier").wait(timeout=1):
        logger.debug("未在票档页")
        return False
```
2. **获取子控件**。`offspring()`用于获取某控件所有的子孙节点的控件。`.child()`获取下级节点。

如：
```python
# 遍历控件，返回第一个的item_text节点
poco("cn.damai:id/project_detail_perform_flowlayout").offspring("cn.damai:id/item_text")

# 遍历子节点，并单击子节点的checkbox
    for viewer_widget in  poco("cn.damai:id/recycler_view").offspring("cn.damai:id/recycler_main").child():
        viewer_widget.offspring("cn.damai:id/checkbox").click()
```

4. **获取属性**。`get_text()`用于获取文字内容，`attr()`可获取其他属性。

```python
#获取tv_tag的文字
tag_str=tv_tag.get_text() 

# 判断复选框是否已被选中
viewer_widget.offspring("cn.damai:id/checkbox").attr("checked") 
```

5. **点击**。 `click()`
```
viewer_widget.offspring("cn.damai:id/checkbox").click()
```

# 代码开发

基于上述poco提供的api，即可像搭积木一样组合出自动化测试工具，实现自动化抢票。
完整代码贴在： https://gist.github.com/m2kar/4f4c1cabe047ac77d5ca0a3b35fad4e1

但本方法需要通过adb和App UI交互，调用的框架较重，因此运行起来很慢，实测需要17s，比人慢很多，因此在实际抢票中不是很实用。

因此作者又深入分析了大麦网app的接口实现，写在了博客的 ”[Android逆向] 某麦网自动化购票工具“ 中。

# 参考
更多poco操作可以参考官方文档： https://airtest.doc.io.netease.com/tutorial/3_Poco_introduction/

<hr/>

- 欢迎[评论](https://github.com/m2kar/m2kar.github.io/issues/20)以及发邮件和作者交流心得。
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar,您的打赏是我创作的重要源泉](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: `m2kar.cn<at>gmail.com`
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://m2kar.blog.csdn.net)

<hr/>

**欢迎在ISSUE参与本博客讨论**: [m2kar/m2kar.github.io#20](https://github.com/m2kar/m2kar.github.io/issues/20)