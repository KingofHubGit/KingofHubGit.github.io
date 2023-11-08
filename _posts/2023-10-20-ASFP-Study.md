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

Android studio for platform——史上第一款AOSP开发的IDE （支持java/Kotlin/C++/JNI/Native/Shell）

简称asfp(爱上富婆)



## 背景&下载&使用

### 背景

由于Android系统源码过于庞大，比如Android14源代码就有400G了。

做AOSP开发的小伙伴都经常受困于改代码的工具，此前主流的IDE主要有：

1. 通过idgen 生成对应的android.ipr和android.iml文件，然后用Android Studio加载整个源码。

   弊端很明显，文件权限问题，很消耗资源，很卡，没法编译，Gradle定时作妖

2. 通过AIDEGen给对应的模块编译，然后使用Idea加载，具有跳转和补全的作用。

   使用复杂繁琐，没法编译，貌似也不支持kt

3. 用Eclipse加载源码模块，倒入framework.jar等库。

   UI跟不上时代，使用困难

4. 使用Source Insight/Visual Code/Sublime的工具进行裸开发，借助其他IDE完成部分语法校验和补全工作。

   没有补全功能，优点是不那么吃系统资源



### 基本情况

现在google官方推出了系统开发专用版本Android Studio for Platform，应该能解决大部分安卓系统开发从业者的烦恼。

先说一下大体情况：

- 优点：
  - 可以加载你关注的几个模块，支持单独编译，有自己的Soong build system。
  - 支持多款语言的跳转/补全/派生关系。
  - 支持灵活的文本搜索，文件搜索，灵活配置，JetBrain家族的特性，很熟悉的味道。
  - 支持单点调试，但是必须base官方源码和官方镜像

- 缺点：
  - 目前仅支持Linux系统，可以在Ubuntu下使用
  - 对电脑配置要求也有点高
  - 对于JNI C++的跳转还有说欠缺



Let's get started!



### 下载

[https://developer.android.com/studio/platform?hl=zh-cn](https://developer.android.com/studio/platform?hl=zh-cn)

![在这里插入图片描述](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/6661ce941ec8464c8f324f785d8b16c3.png)



![640](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/640.png)



目前只支持Ubuntu，会自动识别操作系统类型，如果非Ubuntu会显示不可用。

以我的理解，以后也不会支持Windows，搞android系统开发的都懂。



### 入门

google官方教学视频教程地址： [https://www.bilibili.com/video/BV1U](https://link.zhihu.com/?target=https%3A//www.bilibili.com/video/BV1UV411P7nf/%3Fvd_source%3Da8c604ee3ce4999324264828f8fd99d8)



1. 如果您尚未安装 Repo，请按照[安装 Repo](https://source.android.com/docs/setup/download?hl=zh-cn#installing-repo) 中的说明操作。

   关于repo，想了解深入一些，可以参考这篇文章：

   [https://blog.csdn.net/dengtonglong/article/details/133365006?spm=1001.2014.3001.5502](https://blog.csdn.net/dengtonglong/article/details/133365006?spm=1001.2014.3001.5502)

   

2. 如果您尚未初始化并同步 Repo 检出分支，请按照[初始化 Repo 客户端](https://source.android.com/docs/setup/download/downloading?hl=zh-cn#initializing-a-repo-client)中的说明操作。

   现在大部分android源码项目都是通过repo来管理，也是官方推荐的方式。

   

3. 下载 ASfP到Ubuntu。

   需要科学上网，我上传到网盘/CSDN了。

   

   ![image-20231108170148034.png](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108170148034.png)

   ```
   //TODO
   
   ```

   

4. 安装 ASfP：

   `sudo dpkg -i /path/to/asfp-2023.1.1.19-linux.deb`

   

5. 安装完asfp后，默认在这个目录下：

   `/opt/android-studio-for-platform/bin/studio.sh`

   也可以制作桌面图标：

   ```
   [Desktop Entry]
   Version=1.0
   Encoding=UTF-8
   Name=Android Studio
   Exec=/opt/android-studio-for-platform/bin/studio.sh
   TryExec=/opt/android-studio-for-platform/bin/studio.sh
   Comment=Android Studio For Platform
   Terminal=false
   Categories=Qt;Development;
   Icon=/opt/android-studio-for-platform/bin/studio.png
   Type=Application
   ```

   ![image-20231108165501869](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108165501869.png)

   也可以将这个安装目录，mv到你常用的目录。

   

6. 通过以下方式导入项目：

   可以选择主题风格：

   ![image-20231107182239873](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231107182239873.png)

   

   ![image-20231107182536908](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231107182536908.png)

   

   

   指向您的 Repo 检出目录

   指定 `lunch` 目标

   然后选择要构建的模块

   ![image-20231107183116309](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231107183116309.png)

   

   

7. 点击**完成**，您的项目将开始同步。

8. 像新建工程，ide设置，添加模块、依赖，配置文件，存储路径这些，是和JetBrain其他软件一样的操作，甚至快捷键都一样，熟悉的配方。

   用惯了Android Studio的人，应该对工程师来讲，这个不陌生。



### 编译

   第一次加入项目，会自动编译，由于我加入的代码包含一些定制化，还有test目录经常出问题，编译到了99%，大体也算完成了。



本质上编译指令是：

```
Syncing targets: [frameworks/base]

Preparing for sync...
Updating MAX_ARG_STRLEN to 131072

Generating Soong artifacts...
/bin/bash -c "source build/envsetup.sh && lunch xxxx-userdebug && echo ANDROID_PRODUCT_OUT=$ANDROID_PRODUCT_OUT && refreshmod"
including device/mediatek/build/vendorsetup.sh



```

 

**refreshmod**应该很好用！



![image-20231108092959039](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108092959039.png)

编译完，会生成各种项目配置iml文件

dependencies.iml

依赖的配置目录

frameworks.base.iml

源代码的配置目录

frameworks.base-gen.iml

源代码产生的文件的目录

![image-20231108102839175](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108102839175.png)



编译之后，会生成各种中间版本的jar,

这些classes.jar其实和平时编译生成在out目录下的是一样的。

![image-20231108172411187](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108172411187.png)

frameworks.base.core生成的classes.jar

- core-android-libraries

所有dependencies的classes.jar

- dependencies-jars

frameworks.base生成的classes.jar

- frameworks.base-jars



虽然说ASFP支持soong编译，但不咋好用，是项目实践中，还是建议用m/mm/mmm编译调试！



### 配置

项目配置位置：

![image-20231108103909927](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108103909927.png)

![image-20231108104925002](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108104925002.png)





## 体验特性

 **特性是可以提供便利的**。



### Java Kotlin跳转 补全 派生关系

- 支持java跳转 补全 派生关系

  查看哪些地方调用了：

  ![image-20231108093617436](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108093617436.png)

- 支持kotlin跳转 补全 派生关系

  ![image-20231108104033476](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108104033476.png)

- 支持java和kotlin相互跳转

  可自行尝试。

  

- scratch功能

当写android源码，比如一些复杂的计算，字符串处理，一些数据处理的算法，需要通过java代码或kt代码验证它的语法和运行。

这个时候，scratch功能就非常有用了。



点击创建scratch

![image-20231108174349402](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108174349402.png)

创建一个scratch类

![image-20231108100426729](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108100426729.png)

点击绿色箭头，直接运行：



![image-20231108100518523](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108100518523.png)

运行成功！

![image-20231108100624168](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108100624168.png)



### JNI跳转

我以com/android/server/alarm/AlarmManagerService.java为例，

发现setKernelTime这个native方法并不能跳转到对应的jni方法，这个有点违背某些博客大V的说法。

![image-20231108100130378](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108100130378.png)

替换的方法，可以用ctrl+shift+R查找

![image-20231108100101965](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108100101965.png)



### Native语言支持

在Native环境，可以进行补全，这个已经非常好了，帮我们解决了写native代码的一大困扰：

![image-20231108113459863](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108113459863.png)



### C/C++语言支持

添加servicemanager模块，貌似很多红色报点，我觉得C和C++份依赖于整个环境，缺这缺那的，不可能跑的通的。

所以提示 需要加入对应的环境，如果是专职作内核开发的小伙伴，可以尝试调通。

![image-20231108105127375](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108105127375.png)

但是支持代码补全，这个已经非常好了。

![image-20231108175204604](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108175204604.png)

所以建议大量开发C C++代码，建议转战clion。

![image-20231108105149878](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108105149878.png)

C++也支持scratch

![image-20231108105332754](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108105332754.png)



![image-20231108105450772](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108105450772.png)

可以试验C++代码运行的语法和可行性。



### Python语言支持



![image-20231108174759835](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108174759835.png)

![image-20231108175826022](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108175826022.png)

安装python的插件即可。







### Shell语言支持

直接点击绿色箭头即可运行，本质上用的是bash运行的。

![image-20231108114344688](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108114344688.png)



### mk/bp支持

不支持这两个语法，但是检测到修改，会提示让你重编。

![image-20231108095757328](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108095757328.png)



### 单点调试体验

理论上，单点调试的环境要求比较严格，需要用官方代码+官方镜像；

我尝试在我本地代码上调试，最后失败告终。



![image-20231108094500252](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108094500252.png)





![image-20231108094522417](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108094522417.png)





![image-20231108094635353](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108094635353.png)







![image-20231108094730166](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108094730166.png)





![image-20231108095114798](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108095114798.png)







出现“debug info can be unavailable”的错误，需要关闭运行的AS。

![image-20231108095546936](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108095546936.png)



![image-20231108095735584](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231108095735584.png)

最后都没办法成功单点调试，以后有机会再实验吧！



## 体验小结

简要给出我个人的使用体验，并不代表官方。

|            | 跳转 | 补全 | 关系 |
| :--------- | ---- | ---- | ---- |
| java       | Y    | Y    | Y    |
| kt         | Y    | Y    | Y    |
| C/C++      | N    | Y    | N    |
| JNI/Native | N    | Y    | N    |
| Python     | Y    | Y    | Y    |
| Shell      | Y    | Y    | N/A  |
| mk/bp      | N    | N    | N    |

- 非常适合做Framework开发的小伙伴，也就是手机厂中的系统组
- 如果公司有自己的组件，加入到其中，也是可以兼容，实现跳转和补全
- 希望加强C C++ native的开发体验，也许是可以调好的，如果专职作某块的开发，肯定可以把linux C那套集成
- 建议再观望观望，等更加稳定的版本出来！













