---
layout: post
title: template page
categories: [cate1, cate2]
description: some word here
keywords: keyword1, keyword2
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---





[TOC]



# Jenkins-AOSP构建系统架构设计（全自动化/多产品/持续迭代）



> Android系统开发经常需要用到自动化编译系统，用于正式发布/日构建/验证修改点/远程触发等。
>
> Jenkins是最常用最广泛的DevOps工具之一。本文重点讲解如何在Jenkins上面部署灵活设计/解耦性强/扩展性强的AOSP编译系统。





## 通俗介绍Jenkins

Jenkins可以简单地理解为一个Server+Web应用，同时具有Winows+Linux+Mac等系统的版本。

[https://www.jenkins.io/download/](https://www.jenkins.io/download/)

![image-20240302184045917](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240302184045917.png)

本人极力推荐使用docker版本，后续维护性强 稳定性强。



可以在上面开发+定制你的自动化构建任务，然后将这个任务部署到内网/公网，其他工程师就可以远程访问了。

- 开发工程师用于触发构建 + 发版本
- 测试工程师用于下载固件 + 跑自动化测试

所以工程师之间互不干扰，少一些war！

 Jenkins的文件格式就是war，寓意（开发/测试/运维）不再有战争。



## 框架设计

如果产品规模小， 管理+编译+存放固件  可以在同一个服务器上进行也可以。

当时如果公司规模大，产品杂，就有必要每个服务器各司其职了。

如下是我简单描述的一个框架：



![image-20240304165744142](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240304165744142.png)

- Jenkins服务用于账号管理，Job管理，系统环境配置，系统插件配置，用户界面等
- 编译服务器用于代码下载，更新，编译，整理固件等
- FTP服务器用于按照规定命名/格式存放固件等，常常用于内部研发使用
- Jfrpg Artifacts就是类似于Jenkins的服务器应用，可以快速查找/搜索想要的固件，常用于给别的部门使用，或者释放给客户使用



## Jenkins部署

### 系统/插件配置

- 需要安装的系统插件：

- Publish over SSH：用ssh协议发送固件的

- E-mail：编译结果通知开发者

- Build Timestamp： 编译时间戳，每次会默认保存启动的时间戳

- ANSI Color： 颜色显示更加美观/明显

- Office 365 Connector： 用于Teams远程触发编译/结果同志， 企业微信也支持的

- Gitlab： 用于gitlab相关的

-  Repo： repo 相关的接口， manifest sync diff

- Build periodically with parameters ： 编译传入选项的UI控件

- Set Build Name： 设置任务编译名字的UI控件

- Active Choices： 可以选择的UI控件

- File Parameter： 用于传入文件的的UI控件

- ...

  

需要准备的系统配置：

- Publish over SSH

- E-mail，注意stmp的端口

- 内网的用户名+密码

- ...

  

### JOB配置

- 创建一个Job， 选择freestyle
- 创建编译的UI界面，使用控件“This project is parameterized”

如下，是我简单设计的UI模板：

______________________

BUILD_PROJECTS

```
A10
B20
C50
```

BUILD_ANDROID_VERSION

```
a13
a11
```

------

BUILDS

BUILD_VERSION_NUMBER

```

```

BUILD_SNAPSHOT

```
daily_build
no
user+gms+ota
```

BUILD_INTENT

```
dev
rel
jenkins_test
```

BUILD_SKU

```
gms
aosp
```

BUILD_VARIANT

```
user
userdebug
eng
```

BUILD_TIMESTAMPS

```

```

-----------------

PACKAGES

- [ ] BUILD_FULL_OTA

- [ ] BUILD_INC_OTA

  BUILD_OLD_BUILD_ID

  ```
  
  ```

  BUILD_NEW_BUILD_ID

  ```
  
  ```

- [ ] BUILD_SPECIAL_OTA

  ```
  no
  root ota
  ```

- [ ] BUILD_ESPRESSO

-------

BUILD_SOURCE_SYNC

- [ ] BUILD_RM_OUT
- [ ] BUILD_REPO_SYNC

--------

SOURCE_CUSTOMZATION

- [ ] BUILD_HOOK_LOCAL_MANIFEST
```
[-----] chose files
```
- [ ] BUILD_HOOK_DEFAULT_MANIFEST
```
[-----] chose files
```
- [ ] BUILD_REPO_HOOK_BEFORE_BUILD
```
```

-----

POST_BUILDS

BUILD_UPLOAD

```
bs04
bs04+jenkins
bs04+jenkins+onedrive
```







## AOSP编译部署



### 环境配置

- repo
- git
- ssh



### 编译框架





## 发布管理

### 文件服务器

### jfrog





## 实用技巧

### docker

### ccache





































