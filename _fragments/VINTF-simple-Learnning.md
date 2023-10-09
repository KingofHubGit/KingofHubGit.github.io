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



# VINTF

是vendor interface object的缩写。



## Reference

```
https://source.android.google.cn/docs/core/architecture/vintf?hl=zh-cn
https://source.android.google.cn/docs/core/architecture/vintf/match-rules?hl=zh-cn

https://source.android.com/docs/core/architecture/vintf?hl=zh-cn
https://source.android.com/docs/core/architecture/vintf/objects?hl=zh-cn

http://ddrv.cn/a/238197
https://blog.csdn.net/qq_42194101/article/details/129648737
https://zhuanlan.zhihu.com/p/634585429

https://adtxl.com/index.php/archives/89.html
VINTF供应商接口对象原创 - CSDN博客 https://blog.csdn.net/zhgeliang/article/details/118961253
https://www.qiniu.com/qfans/qnso-74122895
HIDL：VINTF 有什么用？ https://stackoverflow.org.cn/questions/67363368

```



## 概述

VINTF指的是Vendor Interface object，是android 8.0分离system和vendor分区的机制之一，用来检查system和vendor依赖是否匹配。

Framework(system)和Device(vendor)匹配的框架如下：

![VINTF框架](https://source.android.google.cn/docs/core/architecture/images/treble_vintf_mm.png?hl=zh-cn)

Manifest 描述了提供给对方的feature， 

Matrix 描述了需要对方提供的feature。



Manifest 和 Matrix 在OTA升级前会进行匹配检查，以确保framework和device是兼容的。总的来说，manifest是提供端，matrix是需求端。



## Manifest

Framework manifest文件是由Google手动生成的。

它在aosp源码的路径是system/libhidl/manifest.xml，在具体设备上的路径是/system/manifest.xml。



Device manifest文件是和具体设备相关的。

它在aosp源码路径是device/${VENDOR}/${DEVICE}/manifest.xml，在具体设备上的路径是/vendor/manifest.xml。



具体清单描述如下：

[https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn](https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn)



### 清单 Fragment

在您的 `Android.bp` 或 `Android.mk` 文件中，将 `vintf_fragments` 添加到任意模块

![image-20231009175356886](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231009175356886.png)

具体可查看：

[https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn#manifest-fragments](https://source.android.google.cn/docs/core/architecture/vintf/objects?hl=zh-cn#manifest-fragments)





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

**Kernel信息**：

/proc/config.gz. 压缩过的kernel配置，需要在运行时被转化成一个可查询的对象

/proc/version. 系统调用uname()的到的信息

/proc/cpuinfo. 格式可能根据32位和64位而有所不同

policydb version

/sys/fs/selinux/policyvers (假设selinuxfs加载在/sys/fs/selinux).

Libselinux的security_policyvers() 接口返回结果是一样的

**Static Libavb version**：

bootloader system property：ro.boot.vbmeta.avb_version

init/fs_mgr system property：ro.boot.avb_version



## 查询接口

VINTF Object是系统API，提供给hwservicemanager、OTA升级服务、CTS DeviceInfo等模块调用以便获取信息用以匹配。



C++ 查询API位于system/libvintf/VintfObject.cpp中的android::vintf::VintfObject

Java 查询API位于frameworks/base/core/java/android/os/VintfObject.java 中的android.os.VintfObject



## 组合

不同工程提供的feature不同，需要差异化配置。

可以在各自feature的mk中通过 DEVICE_MANIFEST_FILE 来申明和该feature相关的 manifest.xml，编译时候会收集所有mk中的DEVICE_MANIFEST_FILE组合成一个完整的manifest.xml。



可查询的供应商接口对象的代码位于 `system/libvintf`



## 工具

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



帮助：

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


