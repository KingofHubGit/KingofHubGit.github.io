---
layout: fragment
title: Debug skill of the WiFi framework changes
tags: [android]
description: 调试
keywords: Android, wifi, apex
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---


### Debug skill of the WiFi framework changes

Suppose you need debug about wifi framework source code, such as frameworks/opt/net/wifi/service/java/com/android/server/wifi/WifiConnectivityManager.java, and you don't want flash system.img every time.

You can debug it by this way.

1. load the build environment

```
  source build/envsetup.sh
  lunch dl36-userdebug
```

2. build the module

```
  make -j16 com.android.wifi
```

It will produce the apex file in the path : out/target/product/mssi_t_64_cn/system/apex/com.android.wifi.apex

3. install the apex file

- *a. if you can adb install apex file, you can do this by command:*

```
  adb install --apex out/target/product/mssi_t_64_cn/system/apex/com.android.wifi.apex
```

- *b. ortherwise you can do this by two step:*

```
  adb push out/target/product/mssi_t_64_cn/system/apex/com.android.wifi.apex /data/local/tmp/
  adb shell "pm install --apex  data/local/tmp/com.android.wifi.apex"
```



4. reboot the device

After restarted, you can check the modify whether work.



