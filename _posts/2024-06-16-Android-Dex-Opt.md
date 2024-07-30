---
layout: post
title: Trigger Workflow of Android Dex Optimizations 
categories: [android, DexOpt]
description: some word here
keywords: android, dex2oat, DexOpt
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![android_dex](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/android_dex.png)

[TOC]

# DexOpt六种触发流程解析(基于android 13)

> 众所周知，DexOpt是安卓应用性能优化非常重要的手段，相当于将应用对虚拟机的多层调用直接转化成了arm机器码。Dex优化过和没优化过，效果千差万别。本文深入解析android系统DexOpt机制的触发流程。



## 1 DexOpt简介

### 1.1 简要原理

​	  通俗来讲，相当于外交官开发布会（Java），此前是用人工同声翻译（JVM），转达到各个国家的媒体记者那，现在人类开发了同声翻译器（DexOpt），这个翻译会基于每个国家的语言文化的规则（profile）进行翻译成各国记者（各CPU架构）能快速听懂的语言（机器码）。

![DexOpt.jpg](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/DexOpt.jpg)

app经过DexOpt之后，运行在安卓虚拟机上，可以快速和底层硬件用机器码沟通，从而实现优化执行链路。



​		基本原理就是app存在大量的直接或者间接对系统framework层代码的调用，对于系统应用来说，其运行环境在编译期间是可以确定的，那么系统层的这些大量代码在设备上已经是尽可能的 .art 化了的,并且 frameworks image 和 frameworks code 是可以直接提供给oat中的cpmpiled method 直接调用和访问的，而不需要在程序启动的时候动态创建，这样无疑能很大程度提升程序运行速度。此外，oat 文件包含了不少对 dex 文件进行 preload 的数据，省去了大量内存开辟和赋值的指令。

![img](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/01cb7ee0d67a84c579a4e8fe1b5d21c9.png)



Android早期版本是Dalvik虚拟机，从Android 5.0 开始引入ART虚拟机。

Dalvik虚拟机：

```
dex files ----> dexopt  ----> odex files
```

ART虚拟机：

```
dex files ----> dex2oat  ----> oat files
```

由于早期称这个过程为dexopt， 后面称这个过程为dex2oat， 现在统称这个过程为DexOpt。

![img](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/807220-a9132fd83683f2e7)

### 1.2 演变史

Android DexOpt的演变有3个大阶段：

- Android 5.0之前，运行在Dalvik虚拟机上，Dalvik虚拟机会在执行dex文件前对dex文件做优化，依赖于JIT技术，生成可执行**odex**文件，保存到 data/dalvik-cache 目录，最后把Apk文件中的dex文件删除。

  此时生成的odex文件后缀依然是dex ，它是一个dex文件，里面仍然是字节码，而不是本地机器码。

- Android 5.0～Android 8.0，使用ART虚拟机，ART虚拟机使用AOT预编译生成**oat文件**。oat文件是ART虚拟机运行的文件，是ELF格式二进制文件。oat文件包含dex和编译的本地机器指令，因此比Android5.0之前的odex文件更大。
  此时生成的oat文件后缀是odex ，它是一个oat文件，里面仍然是本地机器码，而不是字节码。

- Android 8.0至今， dex2oat会直接生成两个oat文件 (即 **vdex文件 和 odex文件** )。其中 odex 文件是从vdex 文件中提取了部分模块生成的一个新的可执行二进制码文件，odex 从vdex 中提取后，vdex 的大小就减少了。App在首次安装的时候，odex 文件就会生成在` /system/app/<packagename>/oat/ `下。
  在系统运行过程中，虚拟机将其 从 `/system/app` 下 copy 到 `/data/dalvik-cache/` 下。



Android 8 以后，将会生成以下文件：

- `.vdex`：包含一些可加快验证速度的其他元数据（有时还有 APK 的未压缩 DEX 代码）。
- `.odex`：包含 APK 中已经过 AOT 编译的方法代码。
- `.art (optional)`：包含 APK 中列出的某些字符串和类的 ART 内部表示，用于加快应用启动速度。



拿到Android13的实机上查询发现，特点如下：

- 系统编译阶段生成的优化文件：

  ```
  /system/priv-app/ABC/ABC.apk
  /system/priv-app/ABC/oat/arm64/ABC.vdex
  /system/priv-app/ABC/oat/arm64/ABC.odex
  ```

- 空闲编译产生的优化文件：

  ```
  ./system/system_ext/priv-app/ABC/ABC.apk
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.vdex
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.art
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.dex
  ```

- 系统编译生成的jar文件：

  ```
  /system/framework/ABC.vdex
  /system/framework/arm64/ABC.art
  /system/framework/arm64/ABC.oat
  /system/framework/arm64/ABC.vdex
  ```

简约地理解如下：

- `vdex` 是用来安装/启动快速验证的，

- `art`是用来i阿快应用启动的，

- 而上面的`odex / dex / oat` 格式本质上都是ELF文件，是程序运行本身。



### 1.3 过滤器

ART 如何编译 DEX 代码还有个compile filter以参数的形式来决定：从 Android O 开始，有四个官方支持的过滤器：

- **verify**：只运行 DEX 代码验证。
- **quicken**：运行 DEX 代码验证，并优化一些 DEX 指令，以获得更好的解释器性能。
- **speed-profile**：运行 DEX 代码验证，并对配置文件中列出的方法进行 AOT 编译。
- **speed**：运行 DEX 代码验证，并对所有方法进行 AOT 编译。

verify 和quicken 他俩都没执行编译，之后代码执行需要跑解释器。而speed-profile 和 speed 都执行了编译，区别是speed-profile根据profile记录的热点函数来编译，属于部分编译，而speed属于全编。

执行效率上：

```
verify < quicken < speed-profile < speed
```

编译速度上：

```
verify > quicken > speed-profile > speed
```



> 理论上，生成的优化文件越大，编译耗时越长，优化越彻底，运行速度理应越快。



以下这些属性代表了，不同原因（Reason）做dexopt，将会使用不同的过滤器。

比如AB OTA升级，建议使用`speed-profile`，因为OTA本身比较耗时，选择这种方式可以让升级后，性能快速提升。

比如OTA升级开机 或者首次开机，建议使用`verify`，因为不能消耗太多时间在这上面，否则影响开机速度。

```
 # getprop |   grep pm.dexopt
[pm.dexopt.ab-ota]: [speed-profile]
[pm.dexopt.bg-dexopt]: [speed-profile]
[pm.dexopt.boot-after-ota]: [verify]
[pm.dexopt.cmdline]: [verify]
[pm.dexopt.first-boot]: [verify]
[pm.dexopt.inactive]: [verify]
[pm.dexopt.install]: [speed-profile]
[pm.dexopt.install-bulk]: [speed-profile]
[pm.dexopt.install-bulk-downgraded]: [verify]
[pm.dexopt.install-bulk-secondary]: [verify]
[pm.dexopt.install-bulk-secondary-downgraded]: [extract]
[pm.dexopt.install-fast]: [skip]
[pm.dexopt.post-boot]: [extract]
[pm.dexopt.shared]: [speed]
```

PKMS中的 dexopt 实现仅适用于 Android 13 及更低版本。

在 Android 14 中，它已被 ART 服务取代，并且将在下一个版本中从软件包管理系统中移除。



### 1.2 DexOpt触发条件

![image-20240730155857821](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240730155857821.png)

>  此外，还有使用adb命令手动触发，本质上属于系统空闲触发的流程。

## 2 DexOpt触发流程解析

### 2.1 编译阶段



### 2.2 OTA升级



### 2.3 系统首次启动



### 2.4 系统非首次启动



### 2.5 系统空闲



### 2.6 应用安装



### 2.7 应用启动



## 3 结语



___________________________________________

**【更多干货分享】**

- 微信公众号"Lucas-Den"(Lucas.D)

<img src=https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240324122812628.png width=300 height=300 />

- 个人主页：[@Lucas.D](https://kingofhubgit.github.io/)
- GitHub：[@KingofHubGit](https://github.com/KingofHubGit)
- CSDN：[@Lucas.Deng](https://blog.csdn.net/dengtonglong)
- 掘金：[@LucasD](https://juejin.cn/user/3362755788151736)
- 知乎：[@Lucas.D](https://www.zhihu.com/people/lucas.deng)