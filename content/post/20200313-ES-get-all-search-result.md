---
title: "ES遍历所有搜索结果(Python实现)"
date: 2020-03-13
description: "ES遍历所有搜索结果(Python实现)"
tags: ["elasticsearch","python"]
categories: ["编程"]
---

# ES遍历所有搜索结果(Python实现)
ES的搜索是有数量限制的，因此利用官方提供是scroll API实现了一个对全量数据处理的函数。

```python

def travel_es(es,process_func, **kwargs): 
    """
    遍历es的搜索结果，并使用process_func处理返回的item
    process_func: function to process item. 
    kwargs: arguments same as elasticsearch search api.
    """
    kwargs.setdefault("scroll","2m")
    kwargs.setdefault("size",1000)
    res = es.search(**kwargs)
    
    sid = res['_scroll_id']
    scroll_size = len(res['hits']['hits'])
    total_size=scroll_size
    while scroll_size > 0:
        "Scrolling..."

        # Before scroll, process current batch of hits
        process_func(res['hits']['hits'])

        data = es.scroll(scroll_id=sid, scroll='4m')

        # Update the scroll ID
        sid = data['_scroll_id']

        # Get the number of results that returned in the last scroll
        scroll_size = len(data['hits']['hits'])
        total_size+=scroll_size
        print(total_size)
    return scroll_size
    
```
## 示例用法
下面是把所有的结果存到item_list中

```python
item_list=[]
def save_to(item):
    item_list.append(item)

# 使用save_to 函数处理结果
count=travel_es(
        es,
        save_to,
        index="reveye_v2",
        
        body={
            "query": {
                "match_all": {}
            }
        }
)

```

# 参考
-  https://www.elastic.co/guide/cn/elasticsearch/guide/current/scroll.html

# 文章地址
[ES遍历所有搜索结果(Python实现)](https://blog.csdn.net/still_night/article/details/104830290)

--------
- **版权声明**：本文为 m2kar 的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
- **作者**: m2kar
- **打赏链接**: [欢迎打赏m2kar](http://m2kar-cn.mikecrm.com/wy97haW)
- **邮箱**: [m2kar.cn#gmail.com](mailto:m2kar.cn@gmail.com)
- **主页**: [m2kar.cn](https://m2kar.cn)
- **Github**: [github.com/m2kar](https://github.com/m2kar)
- **CSDN**: [M2kar的专栏](https://blog.csdn.net/still_night)
