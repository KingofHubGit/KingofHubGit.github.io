---
layout: fragment
title: Repo mirror
categories: [repo, android]
description: some word here
keywords: repo, android
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![repo_mirror](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/repo_mirror.png)

# 如何30分钟下载完368G的Android系统源码？

> Android系统开发的一个痛点问题就是Android系统源码庞大，小则100G,大则，三四百G。如标题所言，本文介绍通过局域网高速网速下载源码的方法。

## 制作源码mirror

从源码git服务器A，下载到服务器B（serverB），制作一个镜像（A->B）:

```shell
serverB# cd /serverB/AOSP
serverB# repo init -u [源码manifests的地址] -b  [manifests分支]  -m [manifests xml配置名] --mirror  --no-repo-verify
serverB# repo sync -j8  --force-sync
```

下载好后，这个目录和普通的源码结构不一样，以文件git项目为基本元素。

```shell
 repo.git 
 abc.git 
 adb1.git 
 abc2.git 
 ...
```





## 从mirror局域网下载源码

1. 使用sshfs挂载B服务器的mirror地址到C服务器

   > 如果不存在sshfs，可使用apt-get install sshfs 下载

   ```shell
   serverC# mkdir sshfs_mount_points
   serverC# sshfs account@serverB:/serverB/AOSP ./sshfs_mount_points/ ; [输入密码]
   ```

2. C服务器使用mirror下载到本地

   ```shell
   serverC# repo init -u [源码manifests的地址] -b  [manifests分支]  -m [manifests xml配置名] --reference=$(pwd)/sshfs_mount_points/  --dissociate --no-repo-verify
   
   serverC# repo sync -j8  --force-sync
   
   # 开始下载。。。 网速100-200M/s
   
   # 下载完
   serverC# umount sshfs_mount_points
   ```
