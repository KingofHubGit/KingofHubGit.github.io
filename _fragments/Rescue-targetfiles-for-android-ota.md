---
layout: fragment
title: How to build the incremental OTA package if target_files missed
categories: [android, ota]
description: 
keywords: android, ota
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

<img src="https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/inc_ota.jpeg" height=500>

[TOC]

# 差分升级提示hash不匹配，怎么重新编译出差分包？

> 差分升级对于基础版本的要求较高，必须是一模一样的时间戳和版本，不然升级的时候会提示hash不匹配。
>
> Android系统中如果targetfiles如果丢失了或者再也编译不出来了，怎么编译出正确的差分包呢？



## 问题背景

差分升级，是通过目标版本和源头版本做差分计算的升级，这种包叫做差分包，也称为增量包。

由于本人遇到问题是`MTK`平台`Android 13`，所以本文后面的部分信息是`MTK`平台的。

制作差分包用`target_files`，刷机镜像包是`flash_image`。

`target_files`里面也有`image`, 解压`zip`包，然后`img`的路径是： ```target_files/IMAGES/```



现在遇到一个差分升级经常失败的问题：

```
03-13 17:58:06.011 E/update_engine(  993): [ERROR:verified_source_fd.cc(50)] Unable to open ECC source partition /dev/block/by-name/dtbo_a: No such file or directory (2)
03-13 17:58:06.018 E/update_engine(  993): [ERROR:partition_writer.cc(317)] The hash of the source data on disk for this operation doesn't match the expected value. This could mean that the delta update payload was targeted for another version, or that the source partition was modified after it was installed, for example, by mounting a filesystem.
03-13 17:58:06.026 E/update_engine(  993): [ERROR:partition_writer.cc(322)] Expected:   sha256|hex = 6BB6ABAC4EFB59AF63943D4EE2A738BFB15F35E021561B1DA6C6D7A006F0654F
03-13 17:58:06.035 E/update_engine(  993): [ERROR:partition_writer.cc(325)] Calculated: sha256|hex = 5DB7C284D0A34CC703FB8998A408F064FA8B922AB4C0F26ECCCBF9BBD1AB5BD1
03-13 17:58:06.045 E/update_engine(  993): [ERROR:partition_writer.cc(336)] Operation source (offset:size) in blocks: 0:2048
03-13 17:58:06.052 E/update_engine(  993): [ERROR:partition_writer.cc(261)] source_fd != nullptr failed.
03-13 17:58:06.060 E/update_engine(  993): [ERROR:delta_performer.cc(846)] partition_writer_->PerformDiffOperation( operation, error, buffer_.data(), buffer_.size()) failed.
03-13 17:58:06.067 E/update_engine(  993): [ERROR:delta_performer.cc(201)] Failed to perform BROTLI_BSDIFF operation 8, which is the operation 1 in partition "dtbo"
03-13 17:58:06.076 E/update_engine(  993): [ERROR:download_action.cc(227)] Error ErrorCode::kDownloadStateInitializationError (20) in DeltaPerformer's Write method when processing the received payload -- Terminating processing
```



从这两条log可以看出，是因为`hash`不匹配，说明源版本和目标版本的`dtbo_a.img`不一致。

```
03-13 17:58:06.026 E/update_engine(  993): [ERROR:partition_writer.cc(322)] Expected:   sha256|hex = 6BB6ABAC4EFB59AF63943D4EE2A738BFB15F35E021561B1DA6C6D7A006F0654F
03-13 17:58:06.035 E/update_engine(  993): [ERROR:partition_writer.cc(325)] Calculated: sha256|hex = 5DB7C284D0A34CC703FB8998A408F064FA8B922AB4C0F26ECCCBF9BBD1AB5BD1
```

专门计算一下`target_files`的`dtbo_a.img`的`sha256`值：

```
6bb6abac4efb59af63943d4ee2a738bfb15f35e021561b1da6c6d7a006f0654f  dtbo.img
```

计算一下`flash_image`的`dtbo_a.img`的`sha256`值：

```
5db7c284d0a34cc703fb8998a408f064fa8b922ab4c0f26ecccbf9bbd1ab5bd1  dtbo.img
```

和以上log显示的信息对的上。所以**问题的根源就在于此**。



于是分别对比`target_files`和`flash_image`的所有`image`的`sha256`。

![image-20240512002755219](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240512002755219.png)



## 解决办法

>  最好的办法，当然是基于最新代码重新编译一下源版本的flash_image 和 target_files，然后再制作目标版本的差分包。 
>
> 但有的时候，源版本不允许重新编译，已经定板（code freeze）了，甚至给到了客户手里。



要想要做出正确的差分包，必须要有正确的`target_files`文件。

之前错的`target_files`要么是信息不对，要么就是编译和`flash_image`不是同一次编译的，所以编译不出正确的差分包。



### 如何基于错的target_files改造出正确的？

其实很简单！

`img`列表的`hash`不对，就将`flash_image`里面的`img`列表，一一拷贝到`target_files`的 ```target_files/IMAGES/```

`target_files`列表主要有如下：

```
target_files/IMAGES/boot.img
target_files/IMAGES/dlaux.img
target_files/IMAGES/dtbo.img
target_files/IMAGES/gz.img
target_files/IMAGES/lk.img
target_files/IMAGES/logo.bin
target_files/IMAGES/md1dsp.img
target_files/IMAGES/md1img.img
target_files/IMAGES/preloader.img
target_files/IMAGES/preloader_emmc.img
target_files/IMAGES/preloader_raw.img
target_files/IMAGES/preloader_ufs.img
target_files/IMAGES/product.img
target_files/IMAGES/product.map
target_files/IMAGES/scp.img
target_files/IMAGES/splash.bin
target_files/IMAGES/spmfw.img
target_files/IMAGES/sspm.img
target_files/IMAGES/super_empty.img
target_files/IMAGES/system.img
target_files/IMAGES/system.map
target_files/IMAGES/system_other.img
target_files/IMAGES/tee.img
target_files/IMAGES/userdata.img
target_files/IMAGES/vbmeta.img
target_files/IMAGES/vbmeta_system.img
target_files/IMAGES/vbmeta_vendor.img
target_files/IMAGES/vendor.img
target_files/IMAGES/vendor.map
```

`flash_image`列表主要有如下：

```
flash_image/boot.img
flash_image/boot-debug.img
flash_image/dlaux.img
flash_image/dtbo.img
flash_image/gz.img
flash_image/image.md5
flash_image/lk.img
flash_image/logo.bin
flash_image/md1dsp.img
flash_image/md1img.img
flash_image/scp.img
flash_image/splash.bin
flash_image/spmfw.img
flash_image/sspm.img
flash_image/super.img
flash_image/tee.img
flash_image/userdata.img
flash_image/vbmeta.img
flash_image/vbmeta_system.img
flash_image/vbmeta_vendor.img
```

大部分img还是能找到的，（最好一个一个手动拷贝，以防出问题）

```
cp flash_image/*.img   target_files/IMAGES/
```

其中`flash_image`中有一个`super.img`，而在`target_files/IMAGES/`中的是`system.img`。

>  众所周知，Android 10 以后，super.img包含了system.img + vendor.img + product.img

所以将`flash_image`的`super.img`分解成 `system.img + vendor.img + product.img`， 然后拷贝到`target_files/IMAGES/`。

### 如何分解super.img？

- 安装基本工具

```
sudo apt install android-sdk-libsparse-utils
```

- 在源码中编译出`lpunpack`

```
source env/envsetup.sh
lunch xxxx
make lpunpack
```

编译成的工具在：```out/host/linux-86/bin/lpunpack```

- 使用`simg2img`分解成`ext4`格式

```
simg2img super.img super_ext4.img
```

- 执行分解命令

```
mkdir super_ext4
out/host/linux-86/bin/lpunpack   super_ext4.img  super_ext4/
```

此时`super_ext4/` 就有了`system.img + vendor.img + product.img`

然后将这3者一一拷贝：

```
cp flash_image/system.img   target_files/IMAGES/
cp flash_image/vendor.img   target_files/IMAGES/
cp flash_image/product.img  target_files/IMAGES/
```

### 重新编译/升级

- 将`target_files`重新压缩成zip格式。

- 将新的`target_files.zip`放在源码目录下，然后重新制作差分包。
- 使用新的差分包升级，成功地从`0%～100%`，并提示重启。
- **开机后，成功升级！**



___________________________________________

**【更多干货分享】**

- 微信公众号"Lucas-Den"(Lucas.D)

<img src=https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240324122812628.png width=300 height=300 />

- 个人主页：[@Lucas.D](https://kingofhubgit.github.io/)
- GitHub：[@KingofHubGit](https://github.com/KingofHubGit)
- CSDN：[@Lucas.Deng](https://blog.csdn.net/dengtonglong)
- 掘金：[@LucasD](https://juejin.cn/user/3362755788151736)
- 知乎：[@Lucas.D](https://www.zhihu.com/people/lucas.deng)

