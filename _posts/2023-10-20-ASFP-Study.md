---
layout: post
title: ASFP Study
categories: [android, tools]
description: Android Studio for platform
keywords: android studio, AOSP, ROM, tools
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# ASFP Study

Android Studio for platform使用指南

简称asfp(爱上富婆)



## 背景

aidgen

下载了AOSP源码，那我们要考虑如果开发和查看，查看的工具有Source Insight，开发和查看AndroidStudio和Eclipse，当然选择 Android Studio，官方也提供我们系统开发专用版本Android Studio for Platform ,利用强大的工具。我们如何将 AOSP 源码导入 Android Studio里面？



作者：张小潇
链接：https://www.jianshu.com/p/35a7062787fc
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。











## 下载&入门

- 官网下载

[https://developer.android.com/studio/platform?hl=zh-cn](https://developer.android.com/studio/platform?hl=zh-cn)

![在这里插入图片描述](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/6661ce941ec8464c8f324f785d8b16c3.png)



ASfP是专门用于开发aosp的ide工具，有着 Soong build system.，主要有以下几个特点
语言支持部分：
同时支持：C++, Kotlin, and Java 同时使用在ide中编程
设置部分：
可以配置你的编译target和具体的模块



这里最吸引我们的还是他居然支持多语言，c++，java，kotlin同时都支持。
以前我们开发aosp时候，其实java部分使用android studio的体验还是相当好，但是android studio没办法支持c++等native代码的跳转和代码提示，所以不得不使用vscode工具，这个vscode工具相关看c++等代码也是比较方便，基本上的代码也是可以跳转的，但是毕竟有时候需要两个工具相互切快捷键等还是有一点点不方便，虽然不太影响。

所以开发aosp之前的选择就是：
java相关代码使用android studio
c++相关代码使用vscode

目前ASfP工具出现真的是我们framework开发者的一个巨大福音，解决了android studio无法跳转c++代码的这个巨大痛点。
————————————————
版权声明：本文为CSDN博主「千里马学框架」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/learnframework/article/details/132845748





【下载图片】

目前只支持Ubuntu，会自动识别操作系统类型，如果非Ubuntu会显示不可用。

以我的理解，以后也不会支持Windows，搞android系统开发的都懂。



- 入门

1. 如果您尚未安装 Repo，请按照[安装 Repo](https://source.android.com/docs/setup/download?hl=zh-cn#installing-repo) 中的说明操作。

   关于repo，想了解深入一些，可以参考这篇文章：

   [https://blog.csdn.net/dengtonglong/article/details/133365006?spm=1001.2014.3001.5502](https://blog.csdn.net/dengtonglong/article/details/133365006?spm=1001.2014.3001.5502)

   

2. 如果您尚未初始化并同步 Repo 检出分支，请按照[初始化 Repo 客户端](https://source.android.com/docs/setup/download/downloading?hl=zh-cn#initializing-a-repo-client)中的说明操作。

   现在大部分android源码项目都是通过repo来管理，也是官方推荐的方式。

   

3. 下载 ASfP到Ubuntu。

   

4. 安装 ASfP：

   `sudo dpkg -i /path/to/asfp-2023.1.1.19-linux.deb`

   

5. 安装完asfp后，默认在这个目录下：

   `/opt/android-studio-for-platform/bin/studio.sh`

   可以从命令行打开 ASfP：

   【打开图片】

   也可以将这个安装目录，mv到你常用的目录。

   

6. 通过以下方式导入项目：

   指向您的 Repo 检出目录

   【打开图片】

   指定 `lunch` 目标

   【lunch图片】

   然后选择要构建的模块

   【选择图片】

   

7. 点击**完成**，您的项目将开始同步。

   【同步图片】

   

8. [申请加入](mailto: asfp-external+subscribe@google.com)我们外部的用户支持群组。

   

## 使用

- 新建工程
- ide设置
- 添加模块、依赖
- 配置文件
- 存储路径



## 特性

特性是可以提供便利的。

- Java C C++跳转
- 系统源码跳转
- Java查看父类，继承，实现关系
- C_C++查看方法引用
- Build 模块
- 单点调试



## 总结





### 总结体验：

整体体验和以前android studio没有大的差别 1、不过说实话单独java部分的代码开发的话，体验还不如以前的android studio轻量，反而依赖的东西太多，对于跳转等，查找代码还没有以前方便，针对java部分的话，这个建议可以先观望等更多版本更新稳定

2、c++部分的native代码，来说简直就利器，非常好用，跳转准确，非常值的推荐

google官方教学视频教程地址： [https://www.bilibili.com/video/BV1U](https://link.zhihu.com/?target=https%3A//www.bilibili.com/video/BV1UV411P7nf/%3Fvd_source%3Da8c604ee3ce4999324264828f8fd99d8)























