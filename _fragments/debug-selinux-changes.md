---
layout: fragment
title: Debug skill of the SEpolicy changes
tags: [android]
description: debug
keywords: Android, selinux， sepolicy
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---


### Debug skill of the SEpolicy changes

1. load the build environment

```
  source build/envsetup.sh
  lunch [project]-userdebug
```

2. build the system_sepolicy module

```
   mmma system/sepolicy
```

Then it will update the file in this dirctory as bellow:

```
out/target/product/[product]/system/etc/selinux
out/target/product/[product]/vendor/etc/selinux
```

3. Push the selinux file to device

```
   adb push  out/target/product/[product]/system/etc/selinux   /system/etc/ 
   adb push  out/target/product/[product]/vendor/etc/selinux   /vendor/etc/
```

**NOTE**: The target file will produced in out/ after single make command (mmma), and it is copied from the out_sys/ and out_vnd/, they are same.



4. reboot the device

After restarted, you can check the modify whether work.



