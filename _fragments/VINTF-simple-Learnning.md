---
layout: fragment
title: VINTF study
tags: [android]
description: summary
keywords: Android, vintf, OTA, Treble
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# VINTF简介



## VINTF

是Vendor Interface Object的缩写，即厂商接口对象。



## Reference

```
https://source.android.google.cn/docs/core/architecture/vintf?hl=zh-cn
https://source.android.google.cn/docs/core/architecture/vintf/match-rules?hl=zh-cn
https://source.android.com/docs/core/architecture/vintf?hl=zh-cn
https://source.android.com/docs/core/architecture/vintf/objects?hl=zh-cn

http://ddrv.cn/a/238197
https://blog.csdn.net/zhgeliang/article/details/118961253

Treble:
https://juejin.cn/post/6844903591266746375?searchId=20231010120400FC02AEBBB243E6B75C71

Stable AIDL:
https://source.android.google.cn/docs/core/architecture/aidl/aidl-hals?hl=zh-cn&skip_cache=true
```



## 关于Treble



![treble](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/4/15/162c522483268cd5~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)各分区较合理的规划方式：

- Product: OEM相关定制，主要包括Apps，SDK，产品sysprops等
- System: Android系统的Framework和Daemons
- Treble Interface: Treble接口
- Vendor: 硬件相关驱动/Daemons
- ODM: ODM相关定制，包括ODM相关的Apps，SDK等，还有VINTF支持



Treble Interface组成成分，

在Android O添加的接口：

- C++依赖(使用VNDK)，
- IPC调用(使用HIDL)，
- SELinux，
- 通用Kernel接口，
- Android Verified Boot(AVB)；



到Android P新增接口：

- Java依赖(使用System SDK)，

- 系统Properties。



## 概述

VINTF指的是Vendor Interface object，是android 8.0分离system和vendor分区的机制之一，用来检查system和vendor依赖是否匹配。

Framework(system)和Device(vendor)匹配的框架如下：

![VINTF框架](https://source.android.google.cn/docs/core/architecture/images/treble_vintf_mm.png?hl=zh-cn)

- Manifest 描述了提供给对方的feature（Provider）

- Matrix 描述了需要对方提供的feature（Requirement）

Manifest 和 Matrix 在OTA升级前会进行匹配检查，以确保framework和device是兼容的。总的来说，manifest是提供端，matrix是需求端。



## Manifest

Framework manifest文件是由Google手动生成的。

- 在aosp源码的路径: ```system/libhidl/manifest.xml```
- 在设备上的路径: ```/system/manifest.xml```



Device manifest文件是和设备，硬件相关的。

- 在aosp源码路径: ```device/${VENDOR}/${DEVICE}/manifest.xml```
- 在设备的路径: ```/vendor/manifest.xml```



具体清单描述如下：

[https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn](https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn)



## Manifest Fragment

在您的 `Android.bp` 或 `Android.mk` 文件中，将 `vintf_fragments` 添加到任意模块

![image-20231009175356886](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009175356886.png)

具体可查看：

[https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn#manifest-fragments](https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn#manifest-fragments)

本质上就是在汇总manifest的时候，除了常规路径，还会将各个子仓库的VINTF碎片汇总进来。



## Compatibility Matrices

Framework compatibility matrix描述的是framework对 device的需求。

这个matrix文件是和Android Framework Image（system.img）关联的。

Framework compatibility matrix的这些需要被device manifest支持。

Device compatibility matrix描述了device对framework的需求。



具体兼容性矩阵描述如下：

[https://source.android.google.cn/docs/core/architecture/vintf/comp-matrices?hl=zh-cn](https://source.android.google.cn/docs/core/architecture/vintf/comp-matrices?hl=zh-cn)



## 运行时数据

有些需求的信息是在运行时搜集的。通过接口

::android::vintf::VintfObject::GetRuntimeInfo()，信息包括以下：



**Kernel信息**

/proc/config.gz. 压缩过的kernel配置，需要在运行时被转化成一个可查询的对象

/proc/version. 系统调用uname()的到的信息

/proc/cpuinfo. 格式可能根据32位和64位而有所不同



**policydb version**

/sys/fs/selinux/policyvers (假设selinuxfs加载在/sys/fs/selinux).

Libselinux的security_policyvers() 接口返回结果是一样的



**Static Lib AVB version**

bootloader system property：ro.boot.vbmeta.avb_version

init/fs_mgr system property：ro.boot.avb_version



## 查询接口

VINTF Object也是系统API，提供给hwservicemanager、OTA升级服务、CTS DeviceInfo等模块调用以便获取信息用以匹配。


可查询的供应商接口对象的代码位于```system/libvintf```。


C++ 查询API位于：

```
system/libvintf/VintfObject.cpp
```


```
android::vintf::VintfObject
```


Java 查询API位于:


```
frameworks/base/core/java/android/os/VintfObject.java
```

```
android.os.VintfObject
```


vendor和system检查不通过会弹窗：

![错误弹框](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/18fce7d1a5aa4173948c10112948b389%7Etplv-k3u1fbpfcp-zoom-in-crop-mark%3A1512%3A0%3A0%3A0.awebp)



### 关于feature

不同工程提供的feature不同，需要差异化配置。

可以在各自feature的mk中通过 DEVICE_MANIFEST_FILE 来申明和该feature相关的 manifest.xml，

编译时候会收集所有mk中的DEVICE_MANIFEST_FILE组合成一个完整的manifest.xml。



## Stable AIDL

[https://source.android.com/devices/architecture/aidl/aidl-hals](https://source.android.com/devices/architecture/aidl/aidl-hals)

Google 在Android 11引入了AIDL for HALs，旨在代替HIDL原先的作用。在之后的Android版本推荐使用AIDL 实现Hal层的访问。
这样做的原因，应该有以下几点：

- AIDL比HIDL存在的时间更长（仅从Android 8到Android 10），并在许多其他地方使用，如Android框架组件之间或应用程序中。既然AIDL具有稳定性支持，就可以用单一的IPC方式从HAL到框架进程或者应用进程。
- AIDL还有一个比HIDL更好的版本控制系统。
  

[https://blog.csdn.net/qq_40731414/article/details/126823262](https://blog.csdn.net/qq_40731414/article/details/126823262)

[https://blog.csdn.net/weixin_60253080/article/details/127810200](https://blog.csdn.net/weixin_60253080/article/details/127810200)



![在这里插入图片描述](https://img-blog.csdnimg.cn/7a5523cc95b7431ba179a21625ba0663.jpeg#pic_center)



也就是说，VINTF接口后面会演变成aidl接口为主，而不是hidl。



例如，

原来的hidl的接口为：

```xml
<manifest version="1.0" type="device">

    <hal format="hidl">

        <name>vendorabcd.hardware.sensorscalibrate</name>

        <transport>hwbinder</transport>

        <version>1.0</version>

        <interface>

            <name>ISensorsCalibrate</name>

            <instance>default</instance>

        </interface>

    </hal>

</manifest>
```



后面改为了如下：

```xml
<manifest version="1.0" type="device">

    <hal format="aidl">

        <name>vendorabcd.hardware.sensorscalibrate</name>

        <transport>hwbinder</transport>

        <version>1</version>

        [可以保留原本的写法：]

        <interface>

            <name>ISensorsCalibrate</name>

            <instance>default</instance>

        </interface>

      [或者使用fqname：]

      <fqname>ISensorsCalibrate/default</fqname>

        [两种任选一个即可]

    </hal>

</manifest>
```



## 相关工具

细节可参考：

[https://source.android.google.cn/docs/core/architecture/vintf/resources?hl=zh-cn](https://source.android.google.cn/docs/core/architecture/vintf/resources?hl=zh-cn)



### LSHAL

在设备端查看设备清单文件：

```
/system/bin/lshal --init-vintf
```



### ASSEMBLE_VINTF

主机端的工具，功能：

1. 验证兼容性矩阵或清单文件是否有效。
2. 将变量注入到构建时可用的清单/兼容性矩阵，并生成应该安装到设备上的新文件。
3. 检查生成的文件与其双重文件之间的兼容性。
4. 如果给出了清单文件，则可以视需要生成与该清单文件兼容的样板兼容性矩阵。



### 帮助文档

```shell
#./assemble_vintf --help

assemble_vintf: Checks if a given manifest / matrix file is valid and 
    fill in build-time flags into the given file.
assemble_vintf -h
               Display this help text.
assemble_vintf -i <input file>[:<input file>[...]] [-o <output file>] [-m]
               [-c [<check file>]]
               Fill in build-time flags into the given file.
    -i <input file>[:<input file>[...]]
               A list of input files. Format is automatically detected for the
               first file, and the remaining files must have the same format.
               Files other than the first file should only have <hal> defined;
               other entries are ignored. Argument may also be specified
               multiple times.
    -o <output file>
               Optional output file. If not specified, write to stdout.
    -m
               a compatible compatibility matrix is
               generated instead; for example, given a device manifest,
               a framework compatibility matrix is generated. This flag
               is ignored when input is a compatibility matrix.
    -c [<check file>]
               The path of the "check file"; for example, this is the path
               of the device manifest for framework compatibility matrix.
               After writing the output file, the program checks against
               the "check file", depending on environment variables.
               - PRODUCT_ENFORCE_VINTF_MANIFEST=true: check compatibility
               If any check fails, an error message is written to stderr.
               Return 1.
    --kernel=<version>:<android-base.config>[:<android-base-arch.config>[...]]
               Add a kernel entry to framework compatibility matrix or device
               manifest. Ignored for other input format.
               There can be any number of --kernel for framework compatibility
               matrix, but at most one --kernel and at most one config file for
               device manifest.
               <version> has format: 3.18.0
               <android-base.config> is the location of android-base.config
               <android-base-arch.config> is the location of an optional
               arch-specific config fragment, more than one may be specified
    -l, --hals-only
               Output has only <hal> entries. Cannot be used with -n.
    -n, --no-hals
               Output has no <hal> entries (but all other entries).
               Cannot be used with -l.
    --no-kernel-requirements
               Output has no <config> entries in <kernel>, and kernel minor
               version is set to zero. (For example, 3.18.0).
```



计划写一篇VINTF匹配原理和使用，以及stable AIDL调用的文章。

