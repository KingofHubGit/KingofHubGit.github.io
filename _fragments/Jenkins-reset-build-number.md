---
layout: fragment
title: How to reset the build number of Jenkins
categories: [jenkins, devops]
description: some word here
keywords: jenkins, docker, devops
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



![jenkins-build-number](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/jenkins-build-number.png)



# Jenkins如何重置build number？

> Jenkins调试过程中, 难免会产生很多无用的编译号，但需要清除无用build数据的时候，可以使用Script Consle来达到目的.



## 解决方案

直接说答案。



![image-20240122171633546](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122171633546.png)



在脚本中填写如下语句：

![image-20240122171827638](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240122171827638.png)

```
def jobName = "xxx-Build"
def job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
job.nextBuildNumber = 3000
job.save()
```



> 注意：这个删除会将之前的build id全部清空掉，找不回来了。



如果出现删除失败的问题，可能是权限有问题，咨询管理员是否sudo rm掉。

Jenkins主题框架是用java写的，扩展性和延续性都很不错，Script Console就是其中一个好工具，还可以再这里修改时区等，修改系统配置。

