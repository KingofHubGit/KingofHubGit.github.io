---
layout: post
title: system update
categories: Excel
description: system update
keywords: update, recovery
---



#### responsible for

DLSystemUpdate.apk  (common apk in Italian projects, might have limited modification for M11), 

frameworks, update_engine, sepolicy.



device/datalogic/

device/qcom/common/

device/qcom/sdm660_64/

device/qcom/sepolicy/

device/qcom/x5

frameworks/base/

hardware/datalogic/ (this involve DLSysyemUpdate app, in a11 this is a prebuilt apk)

hardware/qcom/bootctrl/

system/update_engine/

packages/apps/Settings (things about factrory-enteprise reset)



#### 底层打包+升级

bootable/recovery/

build/make/





#### 源码资料

http://wiki.mobile.dl.net/mediawiki/index.php/SDK

https://dtcsrv838.dl.net/android-datalogic-common/prebuilts/DLSystemUpdateApp

https://dtcsrv838.dl.net/android-datalogic-common/source-code/DLSystemUpdateApp





#### X5代码查看

I suggest you can learn it from SX5 A11 source code, access it in waylon’s domain in DLCNRDBS02 (10.86.240.14),

waylon@DLCNRDBS02: /home/waylon/project/x5_a11/LINUX/android/

psw:123456





### 提升编译速度

较吃硬盘，固态

C cache打开





system 1h 

vendor 0.5h





为什么要将update_metadata.proto在STATIC_LIBRARIES的相应目录内，

生成了update_metadata.pb.cpp和update_metadata.pb.h文件？

![image-20220715151249596](/home/ldeng/.config/Typora/typora-user-images/image-20220715151249596.png)





```
adb shell am startservice -n com.datalogic.systemupdate/.SystemUpgradeService  --ei action 2 -e path "/sdcard/ota.zip"  --ei reset 0 --ei force_update 0 --ei reboot 1
```







### SX5相关

```
Hello Lucas,
I guess you joined us recently, so welcome on board!

All 660 projects are now managed by Thai (except M20 A9, which has been phasing out for some months), so in general he will be your point of contact about them.

Regarding your request, you can find here the links to all MC sw releases:
Mobile Computers Build Artifacts - Datalogic ADC Mobile (dl.net)

SX5 A11 is therefore here (including userdebug):
QUO_VADIS - Builds SX5 - A11 - Tutti i documenti (sharepoint.com)
(I made sure you can access it)
I see latest is 3.06.004. Release notice attached, with link to release notes.

Ciao,
Carlo

```





### LOG

```
adb shell "logcat -b all |  grep -iE 'SystemUpdate|SystemUpgradeService|UpdateEngine|update_engine|ota' "

```





### Config

vendor/mediatek/proprietary/bootable/bootloader/lk/project/dl36.mk

```shell
AB_OTA_UPDATER := true

```

device/mediatek/vendor/common/BoardConfig.mk

```
AB_OTA_PARTITIONS := \
  boot \
  system \
  vendor
```

device/mediatek/system/common/device.mk

```shell
# A/B System updates
ifeq ($(strip $(MTK_AB_OTA_UPDATER)), yes)

# Squashfs config
#BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := squashfs
#PRODUCT_PACKAGES += mksquashfs
#PRODUCT_PACKAGES += mksquashfsimage.sh
#PRODUCT_PACKAGES += libsquashfs_utils

$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)

PRODUCT_PACKAGES += \
update_engine \
update_engine_sideload \
update_verifier

PRODUCT_HOST_PACKAGES += \
delta_generator \
shflags \
brillo_update_payload \
bsdiff \
simg2img

PRODUCT_PACKAGES_DEBUG += \
update_engine_client \
bootctl

PRODUCT_PACKAGES += mtk_plpath_utils
PRODUCT_PACKAGES += mtk_plpath_utils.recovery

## bootctrl HAL and HIDL
#PRODUCT_PACKAGES += \
#        bootctrl.$(MTK_PLATFORM_DIR) \
#        android.hardware.boot@1.0-impl \
#        android.hardware.boot@1.0-service

# A/B OTA dexopt package
PRODUCT_PACKAGES += otapreopt_script

# Tell the system to enable copying odexes from other partition.
PRODUCT_PACKAGES += \
        cppreopts.sh

#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.cp_system_other_odex=1

#DEVICE_MANIFEST_FILE += $(LOCAL_PATH)/project_manifest/manifest_boot.xml
endif

```





### 升级方式

1、sideload线刷

机器必须要root权限，否则没法进入sideload

```
adb reboot sideload
adb sideload  full-ota-xx.zip
```



2、python脚本刷

```
python update_engine/scripts/update_device.py  --file full-ota-xx.zip
```

本质上是对update_engine_client的封装，这个对于外部有依赖，大致如下：

- 需要安装sudo apt-get install python-protobuf；

- 需要push update_engine_client 、su等bin文件；

- 需要push 一些so库：

  ```
  adb push lib64/libbrillo-stream.so   system/lib64/ 
  adb push lib64/libbrillo-stream.so   system/lib64/  
  adb push lib/libbrillo-stream.so   system/lib/  
  adb push lib/libbrillo-stream.so  system/lib/ 
  adb push lib/libbrillo-stream.so  system/lib/  
  adb push lib64/libbrillo-stream.so  system/lib64/  
  adb push lib/libbrillo.so  system/lib/  
  adb push lib/libbrillo.so  system/lib/  
  adb push lib64/libbrillo.so  system/lib64/  
  adb push lib64/libbinderwrapper.so  system/lib64/  
  adb push lib/libbinderwrapper.so  system/lib/  
  adb push lib/libbrillo-binder.so  system/lib/ 
  adb push lib64/libbrillo-binder.so  system/lib64/
  ```

- 还是会报错，提示：

  ```
  INFO:root:Running: adb shell su 0 update_engine_client --help
  Traceback (most recent call last):
    File "update_engine/scripts/update_device.py", line 445, in <module>
      sys.exit(main())
    File "update_engine/scripts/update_device.py", line 429, in main
      AndroidUpdateCommand(args.otafile, payload_url, args.extra_headers)
    File "update_engine/scripts/update_device.py", line 282, in AndroidUpdateCommand
      ota = AndroidOTAPackage(ota_filename)
    File "update_engine/scripts/update_device.py", line 92, in __init__
      payload_info = otazip.getinfo(self.OTA_PAYLOAD_BIN)
    File "/usr/lib/python2.7/zipfile.py", line 932, in getinfo
      'There is no item named %r in the archive' % name)
  KeyError: "There is no item named 'payload.bin' in the archive"
  ```

  因为ota包里面没有payload.bin文件，所以没法成功。

  ![image-20220729115741315](Image/image-20220729115741315.png)

  ![image-20220729115714455](Image/image-20220729115714455.png)

  

https://www.thecustomdroid.com/how-to-extract-android-payload-bin-file/

https://blog.csdn.net/u011391629/article/details/103833785

是因为我用得是memorK的ota包，如果不是AB系统的，就不会生成payload.bin文件。



出现报错：

```
# python  update_device.py  --file     otapackage.zip 
INFO:root:Running: adb shell su 0 update_engine_client --help
INFO:root:Running: adb push otapackage.zip /data/local/tmp/debug.zip
otapackage.zip: 1 file pushed. 11.5 MB/s (1373451738 bytes in 114.357s)
INFO:root:Running: adb shell su 0 mv /data/local/tmp/debug.zip /data/ota_package/debug.zip
INFO:root:Running: adb shell su 0 chcon u:object_r:ota_package_file:s0 /data/ota_package/debug.zip
INFO:root:Running: adb shell su 0 chown system:cache /data/ota_package/debug.zip
INFO:root:Running: adb shell su 0 chmod 0660 /data/ota_package/debug.zip
INFO:root:Running: adb shell su 0 update_engine_client --update --follow --payload=file:///data/ota_package/debug.zip --offset=963 --size=1373447250 --headers="FILE_HASH=4XiOVrReGeBxyBrfOXfwODUDEoi7rXyXkZH2BBlH8OQ=
FILE_SIZE=1373447250
METADATA_HASH=/u/iuYUlm6fC6wUKr1Ucpydxo5OkymJW+mWelm9eOs8=
METADATA_SIZE=100144
USER_AGENT=Dalvik (something, something)
NETWORK_ID=0
"
[INFO:update_engine_client_android.cc(92)] onStatusUpdate(UPDATE_STATUS_IDLE (0), 0)
[INFO:update_engine_client_android.cc(92)] onStatusUpdate(UPDATE_STATUS_UPDATE_AVAILABLE (2), 0)
[INFO:update_engine_client_android.cc(92)] onStatusUpdate(UPDATE_STATUS_CLEANUP_PREVIOUS_UPDATE (11), 0)
[INFO:update_engine_client_android.cc(92)] onStatusUpdate(UPDATE_STATUS_DOWNLOADING (3), 1.26303e-05)
[INFO:update_engine_client_android.cc(92)] onStatusUpdate(UPDATE_STATUS_IDLE (0), 0)
[INFO:update_engine_client_android.cc(100)] onPayloadApplicationComplete(ErrorCode::kInstallDeviceOpenError (7))

```





3、update_engine_client刷

```
bcm7252ssffdr4:/ # update_engine_client \
--payload=http://stbszx-bld-5/public/android/full-ota/payload.bin \
--update \
--headers="\
  FILE_HASH=ozGgyQEcnkI5ZaX+Wbjo5I/PCR7PEZka9fGd0nWa+oY= \
  FILE_SIZE=282164983
  METADATA_HASH=GLIKfE6KRwylWMHsNadG/Q8iy5f7ENWTatvMdBlpoPg= \
  METADATA_SIZE=21023 \
"
```

```
adb shell su 0 update_engine_client --update --follow --payload=file:///data/ota_package/debug.zip --offset=963 --size=1373447250 --headers="FILE_HASH=4XiOVrReGeBxyBrfOXfwODUDEoi7rXyXkZH2BBlH8OQ=
FILE_SIZE=1373447250
METADATA_HASH=/u/iuYUlm6fC6wUKr1Ucpydxo5OkymJW+mWelm9eOs8=
METADATA_SIZE=100144
USER_AGENT=Dalvik (something, something)
NETWORK_ID=0
"
```



4、APK升级 normal mode

设置--->系统升级--->进入recovery界面进行更新



5、刷机工具

暂时不支持

【设想如果要支持，如何做？本质上还是push文件+调用接口】



6、通过adb发intent刷机

```
adb shell am startservice -n com.datalogic.systemupdate/.SystemUpgradeService --ei action 2  -epath  enterprise/enterprise_package_M11_V1.0.zip   --ei reset 0 --ei force_update 0 --ei reboot 1
```





### 踩坑

1、

```
Package is for product " << pkg_device << " but expected 
```

设备不能unlock，否则会get不到属性，导致这个报错

![image-20220805104424729](Image/image-20220805104424729.png)

2、

```
Update package is older than the current build, expected a build 
```

![image-20220805104446573](Image/image-20220805104446573.png)

理论上编译的本地image和ota包已经可以直接升级的，但是本地image的时间戳会偶先比ota包大的情况。

ota包的时间很纯粹，固定是ro.build.date.utc

本地image的时间拿到的，可能是ro.vendor.build.date.utc

本地image的时间拿到的，可能是ro.vendor.build.date.utc

本地image的时间拿到的，可能是ro.vendor.build.date.utc



- ota包的时间戳查看方法：

解包，并查看META-INF下面的metadata

post-timestamp=1659589248

2022-08-04 13:00:48

在out_sys下



- 本地包的时间戳查看方法：

  dl36/mk/vendor_build.prop

  ```
  16:ro.vendor.build.date.utc=1659594562
  33:ro.bootimage.build.date.utc=1659594562
  ```

2022-08-04 14:29:22

在out_vnd下



在buildinfo.sh下强行改(避免ota时间戳烦恼):

```
ro.build.date=Thu Aug  4 17:32:24 CST 2025
ro.build.date.utc=1754299944
```



build有很多个时间：

```
[ro.bootimage.build.date]: [Thu Aug 4 20:01:55 CST 2022]
[ro.bootimage.build.date.utc]: [1659614515]
[ro.boottime.update_engine]: [18191666231]
[ro.boottime.update_verifier_nonencrypted]: [15360163000]
[ro.build.ab_update]: [true]
[ro.build.date]: [Thu Aug  4 17:32:24 CST 2025]
[ro.build.date.utc]: [1754299944]
[ro.odm.build.date]: [Thu Aug  4 20:01:55 CST 2022]
[ro.odm.build.date.utc]: [1659614515]
[ro.product.build.date]: [Thu Aug  4 18:30:27 CST 2022]
[ro.product.build.date.utc]: [1659609027]
[ro.system.build.date]: [Thu Aug  4 18:30:27 CST 2022]
[ro.system.build.date.utc]: [1659609027]
[ro.system_ext.build.date]: [Thu Aug  4 18:30:27 CST 2022]
[ro.system_ext.build.date.utc]: [1659609027]
[ro.vendor.build.date]: [Thu Aug  4 20:01:55 CST 2022]
[ro.vendor.build.date.utc]: [1659614515]
[ro.vendor.md_apps.load_date]: [2022/07/27 16:35:50 GMT +08:00]


```



3、全量包不允许downgrade，加了允许的参数也不行，所以必须本地编译

![image-20220802143529591](Image/image-20220802143529591.png)



4、时间戳变成一个巨大的数字，是因为机器被root和unlock了

- 不能unlock
- 时间戳不能downupgrade



5、报错：Failed to load keys from releasekey.x509.pem

```
[  474.218103] I:Update package id: /sideload/package.zip
[  474.405627] E:Failed to read x509 certificate
[  474.615352] E:Failed to load keys from releasekey.x509.pem
[  474.710197] E:Failed to load keys
[  474.930994] I:current maximum temperature: 36000
[  474.931346] I:/sideload/package.zip
```

![image-20220803180106111](Image/image-20220803180106111.png)



本质上是升级会去校验/system/etc/security/otacerts.zip文件下的证书和otapackage里面的证书是否一致。

![image-20220803180210908](Image/image-20220803180210908.png)

![image-20220803180250663](Image/image-20220803180250663.png)

后面发现不一致，在/system/etc/security/otacerts.zip下面的证书是错的，需要在recovery模式下push到这个目录，然后升级，需要修复bug。



6、报错Package is for product m11 but expected

```
[  415.025342] E:Package is for product m11 but expected 
[  415.062221] E:result: 1 fact.secure_boot_lock : 0  metadataMap.find('ro.action.set_device_lock') 
```

怀疑是解锁unlock了导致？

是的。





### DLSystemUpdate/update_engine/recovery

1、编译最新的DLSystemUpdate：

Common_Code/artifacts/debug/DLSystemUpdate



adb install -r DLSystemUpdate.apk 

```shell
ldeng@dotorom:~/code/AOSP/Common_Code/artifacts/debug/DLSystemUpdate$ aapt2  dump  DLSystemUpdate.apk  |   grep name 
Package name=com.datalogic.systemupdate id=7f
    spec resource 0x7f09000d com.datalogic.systemupdate:string/app_name
    spec resource 0x7f090057 com.datalogic.systemupdate:string/system_update_activity_name
```

```shell
ldeng@dotorom:~/code/AOSP/Common_Code/artifacts/debug/DLSystemUpdate$ adb shell "pm dump  com.datalogic.systemupdate |  grep version "
    versionCode=13301 minSdk=26 targetSdk=29
    versionName=1.33.1
    signatures=PackageSignatures{d1c0972 version:2, signatures:[675792bf], past signatures:[]}
    versionCode=30 minSdk=30 targetSdk=30
    versionName=11
    signatures=PackageSignatures{d1c0972 version:2, signatures:[675792bf], past signatures:[]}

```





2、添加UpdateEngine相关的framework的接口：

```diff
diff --git a/core/java/android/os/UpdateEngine.java b/core/java/android/os/UpdateEngine.java
index e907e2204b7..97c84a0b741 100644
--- a/core/java/android/os/UpdateEngine.java
+++ b/core/java/android/os/UpdateEngine.java
@@ -21,9 +21,11 @@ import android.annotation.NonNull;
 import android.annotation.SystemApi;
 import android.annotation.WorkerThread;
 import android.content.res.AssetFileDescriptor;
+import android.content.Context;
 import android.os.IUpdateEngine;
 import android.os.IUpdateEngineCallback;
 import android.os.RemoteException;
+import android.provider.Settings;
 
 /**
  * UpdateEngine handles calls to the update engine which takes care of A/B OTA
@@ -54,7 +56,7 @@ public class UpdateEngine {
     private static final String TAG = "UpdateEngine";
 
     private static final String UPDATE_ENGINE_SERVICE = "android.os.UpdateEngineService";
-
+    private static int DLErrorCode = 0;
     /**
      * Error codes from update engine upon finishing a call to
      * {@link applyPayload}. Values will be passed via the callback function
@@ -274,15 +276,21 @@ public class UpdateEngine {
 
                 @Override
                 public void onPayloadApplicationComplete(final int errorCode) {
+                    int tmpErr = errorCode;
+                    if(tmpErr>1000){
+                        DLErrorCode = tmpErr;
+                        tmpErr = ErrorCodeConstants.ERROR;
+                    }
+                    final int errorCodeFinal = tmpErr;
                     if (handler != null) {
                         handler.post(new Runnable() {
                             @Override
                             public void run() {
-                                callback.onPayloadApplicationComplete(errorCode);
+                                callback.onPayloadApplicationComplete(errorCodeFinal);
                             }
                         });
                     } else {
-                        callback.onPayloadApplicationComplete(errorCode);
+                        callback.onPayloadApplicationComplete(errorCodeFinal);
                     }
                 }
             };
@@ -295,6 +303,31 @@ public class UpdateEngine {
         }
     }
 
+    /**
+     * {@hide}
+     */
+    public int DLGetErrorCode(){
+        return DLErrorCode;
+    }
+
+    /**
+     * {@hide}
+     */
+    public void DLEnableGOTAUpdate(Context context){
+        Settings.Global.putInt(context.getContentResolver(),
+                Settings.Global.OTA_DISABLE_AUTOMATIC_UPDATE,
+                0);
+    }
+
+    /**
+     * {@hide}
+     */
+    public void DLDisableGOTAUpdate(Context context){
+        Settings.Global.putInt(context.getContentResolver(),
+                Settings.Global.OTA_DISABLE_AUTOMATIC_UPDATE,
+                1);
+    }
+
     /**
      * Equivalent to {@code bind(callback, null)}.

```



如上1、2，关闭selinux成功升级了。



3、打开selinux，报错如下：

```html
08-10 11:20:03.613   839   839 I update_engine: [INFO:action_processor.cc(143)] ActionProcessor: starting InstallPlanAction
08-10 11:20:03.616  4318  4318 D NotificationEntryMgr: onAsyncInflationFinished, key = 0|com.datalogic.systemupdate|1337|null|1000, isNew = true
08-10 11:20:03.626   839   839 I update_engine: [INFO:action_processor.cc(116)] ActionProcessor: finished InstallPlanAction with code ErrorCode::kSuccess
08-10 11:20:03.642   839   839 I update_engine: [INFO:action_processor.cc(143)] ActionProcessor: starting DownloadAction
08-10 11:20:03.652   839   839 I update_engine: [INFO:install_plan.cc(91)] InstallPlan: new_update, version: , source_slot: B, target_slot: A, url: file:///storage/7F53-170F/Download/otapackage.zip, payload: (size: 1258139198, metadata_size: 91188, metadata signature: , hash: 6181190FED32FA83ADF506A299924D323F39AF8CF163118BF38D3E38E4EF0203, payload type: unknown), hash_checks_mandatory: true, powerwash_required: false, switch_slot_on_reboot: true, run_post_install: true, is_rollback: false, write_verity: true
_______________________________________________________________________________________
08-10 11:20:03.661   839   839 I update_engine: [INFO:download_action.cc(199)] Marking new slot as unbootable
08-10 11:20:03.689   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(45)] starting first transfer
08-10 11:20:03.697   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(74)] starting transfer of range 1010+1258139198
08-10 11:20:03.708   839   839 E update_engine: [ERROR:file_stream.cc(-1)] Domain=system, Code=EACCES, Message=Permission denied
08-10 11:20:03.700   839   839 I auditd  : type=1400 audit(0.0:41740): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=0
08-10 11:20:03.700   839   839 W update_engine: type=1400 audit(0.0:41740): avc: denied { dac_read_search } for capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=0
08-10 11:20:03.720   839   839 E update_engine: [ERROR:file_fetcher.cc(87)] Couldn't open /storage/7F53-170F/Download/otapackage.zip
_______________________________________________________________________________________
08-10 11:20:03.729   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(172)] Received transfer complete.
08-10 11:20:03.738   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(129)] TransferEnded w/ code 404
08-10 11:20:03.749   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(144)] Didn't get enough bytes. Ending w/ failure.
08-10 11:20:03.759   839   839 I update_engine: [INFO:action_processor.cc(116)] ActionProcessor: finished DownloadAction with code ErrorCode::kDownloadTransferError
08-10 11:20:03.773   839   839 I update_engine: [INFO:action_processor.cc(121)] ActionProcessor: Aborting processing due to failure.
08-10 11:20:03.782   839   839 I update_engine: [INFO:update_attempter_android.cc(522)] Processing Done.
08-10 11:20:03.792   839   839 I update_engine: [INFO:update_attempter_android.cc(662)] Terminating cleanup previous update.
08-10 11:20:03.810  7214 10679 I SystemUpdate: [SystemUpgradeService] Error applying OTA. Error: 9 DL error: 0
08-10 11:20:03.810  1508  1508 I sysui_multi_action: [757,128,758,5,759,8,793,579,794,0,795,579,796,1337,806,com.datalogic.systemupdate,857,myChannel,858,3,947,0,1500,579,1688,1]
08-10 11:20:03.810  1508  1508 I notification_canceled: [0|com.datalogic.systemupdate|1337|null|1000,8,579,579,0,-1,-1,NULL]
08-10 11:20:03.820  1508  1508 I notification_enqueue: [1000,7214,com.datalogic.systemupdate,1337,NULL,0,Notification(channel=myChannel shortcut=null contentView=null vibrate=null sound=null defaults=0x0 flags=0x18 color=0x00000000 vis=PRIVATE),0]
08-10 11:20:03.820  4318  4318 D NotificationListener: onNotificationRemoved: StatusBarNotification(pkg=com.datalogic.systemupdate user=UserHandle{0} id=1337 tag=null key=0|com.datalogic.systemupdate|1337|null|1000: Notification(channel=myChannel shortcut=null contentView=null vibrate=null sound=null defaults=0x0 flags=0x6a color=0x00000000 vis=PRIVATE)) reason: 8
08-10 11:20:03.821  7214 10679 W ContextImpl: Calling a method in the system process without a qualified user: android.app.ContextImpl.sendBroadcast:1111 android.content.ContextWrapper.sendBroadcast:468 com.datalogic.systemupdate.SystemUpgradeService$MyUpdateEngineCallback.onPayloadApplicationComplete:705 android.os.UpdateEngine$1.onPayloadApplicationComplete:293 android.os.IUpdateEngineCallback$Stub.onTransact:101 
08-10 11:20:03.824  1508  6310 E ActivityManager: Sending non-protected broadcast com.datalogic.systemupgrade.APPLY_UPDATE_FAILED from system 7214:com.datalogic.systemupdate/1000 pkg com.datalogic.systemupdate
08-10 11:20:03.827  1508  1615 I am_wtf  : [0,1508,system_server,-1,ActivityManager,Sending non-protected broadcast com.datalogic.systemupgrade.APPLY_UPDATE_FAILED from system 7214:com.datalogic.systemupdate/1000 pkg com.datalogic.systemupdate]
08-10 11:20:03.829  1508  6310 E ActivityManager: Sending non-protected broadcast com.datalogic.systemupgrade.APPLY_UPDATE_FAILED from system 7214:com.datalogic.systemupdate/1000 pkg com.datalogic.systemupdate
08-10 11:20:03.840  7214  7214 I SystemUpdate: [UpdateActivity] SystemUpgradeBroadcastReceiver: received com.datalogic.systemupgrade.APPLY_UPDATE_FAILED action
08-10 11:20:03.840  7214  7214 I SystemUpdate: [UpdateActivity] APPLY_UPDATE_FAILED action
08-10 11:20:03.858  1508  6310 W WindowManager: Changing focus fromWindow{7585ed1 u0 Applying update... EXITING} to Window{eecbc47 u0 com.datalogic.systemupdate/com.datalogic.systemupdate.UpdateActivity} displayId=0 Callers=com.android.server.wm.RootWindowContainer.updateFocusedWindowLocked:457 com.android.server.wm.WindowManagerService.updateFocusedWindowLocked:5602 com.android.server.wm.WindowState.setupWindowForRemoveOnExit:2358 com.android.server.wm.WindowState.removeIfPossible:2327 
08-10 11:20:03.865  1508  1675 I InputDispatcher: setInputWindows displayId=0 Window{ba8d1f3 u0 StatusBar} Window{7585ed1 u0 Applying update...} Window{eecbc47 u0 com.datalogic.systemupdate/com.datalogic.systemupdate.UpdateActivity} Window{a63da65 u0 com.android.systemui.ImageWallpaper} 
08-10 11:20:03.876  7214  7214 I SystemUpdate: [UpdateActivity] CheckConditionError action: Error code 0
08-10 11:20:03.876  7214  7214 E SystemUpdate: [UpdateActivity] Unhandled error code 0
08-10 11:20:03.876  7214  7214 I SystemUpdate: [UpdateStateMachine] processEvent(CHECK_FAILURE)
08-10 11:20:03.877  7214  7214 I SystemUpdate: [UpdateActivity] Current state: INSTALL Processing event : CHECK_FAILURE
08-10 11:20:03.877  7214  7214 I SystemUpdate: [UpdateStateMachine] getNextState(7): next state is PRE_INSTALL_ERROR
08-10 11:20:03.877  7214  7214 I SystemUpdate: [UpdateStateMachine] processState(PRE_INSTALL_ERROR)
08-10 11:20:03.877  7214  7214 I SystemUpdate: [UpdateActivity] Executing state action for the current state : PRE_INSTALL_ERROR
```



需要解除的selinux权限如下：

```
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25927): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25927): avc: denied { dac_read_search } for capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25928): avc: denied { search } for comm="update_engine" name="0" dev="tmpfs" ino=2384 scontext=u:r:update_engine:s0 tcontext=u:object_r:mnt_user_file:s0 tclass=dir permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25928): avc: denied { search } for name="0" dev="tmpfs" ino=2384 scontext=u:r:update_engine:s0 tcontext=u:object_r:mnt_user_file:s0 tclass=dir permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25929): avc: denied { search } for comm="update_engine" name="/" dev="fuse" ino=1 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=dir permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25929): avc: denied { search } for name="/" dev="fuse" ino=1 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=dir permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25930): avc: denied { read } for comm="update_engine" name="otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25930): avc: denied { read } for name="otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25931): avc: denied { open } for comm="update_engine" path="/storage/7F53-170F/Download/otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25931): avc: denied { open } for path="/storage/7F53-170F/Download/otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25932): avc: denied { getattr } for comm="update_engine" path="/storage/7F53-170F/Download/otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.452   868   868 I update_engine: type=1400 audit(0.0:25932): avc: denied { getattr } for path="/storage/7F53-170F/Download/otapackage.zip" dev="fuse" ino=1048985 scontext=u:r:update_engine:s0 tcontext=u:object_r:fuse:s0 tclass=file permissive=1
08-10 11:45:10.476   868   868 I update_engine: [INFO:delta_performer.cc(209)] Completed 0/? operations, 16384/1258139198 bytes downloaded (0%), overall progress 0%
08-10 11:45:10.477  1159  1159 I notification_enqueue: [1000,6456,com.datalogic.systemupdate,1337,NULL,0,Notification(channel=myChannel shortcut=null contentView=null vibrate=null sound=null defaults=0x0 flags=0x8 color=0x00000000 vis=PRIVATE),1]
```



4、遇到第二个问题

```
08-10 11:26:27.751  4318  4318 D InterruptionStateProvider: No bubble up: not allowed to bubble: 0|com.datalogic.systemupdate|1337|null|1000
08-10 11:26:27.753  4318  4318 D InterruptionStateProvider: No heads up: unimportant notification: 0|com.datalogic.systemupdate|1337|null|1000
08-10 11:26:27.780  4318  4318 D NotificationEntryMgr: onAsyncInflationFinished, key = 0|com.datalogic.systemupdate|1337|null|1000, isNew = false

08-10 11:26:27.780   839   839 E update_engine: Cannot create update snapshots with overlayfs setup. Run `adb enable-verity`, reboot, then try again.

08-10 11:26:27.792   839   839 E update_engine: [ERROR:dynamic_partition_control_android.cc(764)] Cannot create update snapshots: Error
08-10 11:26:27.801   839   839 E update_engine: [ERROR:dynamic_partition_control_android.cc(463)] PrepareSnapshotPartitionsForUpdate failed in Android mode
08-10 11:26:27.810   839   839 E update_engine: [ERROR:delta_performer.cc(995)] Unable to initialize partition metadata for slot A
08-10 11:26:27.819   839   839 E update_engine: [ERROR:download_action.cc(336)] Error ErrorCode::kInstallDeviceOpenError (7) in DeltaPerformer's Write method when processing the received payload -- Terminating processing
08-10 11:26:27.828   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(177)] Received transfer terminated.
08-10 11:26:27.837   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(129)] TransferEnded w/ code 200
08-10 11:26:27.844   839   839 I update_engine: [INFO:multi_range_http_fetcher.cc(131)] Terminating.
08-10 11:26:27.869   839   839 I update_engine: [INFO:action_processor.cc(116)] ActionProcessor: finished DownloadAction with code ErrorCode::kInstallDeviceOpenError
08-10 11:26:27.882   839   839 I update_engine: [INFO:action_processor.cc(121)] ActionProcessor: Aborting processing due to failure.
08-10 11:26:27.889   839   839 I update_engine: [INFO:update_attempter_android.cc(522)] Processing Done.
08-10 11:26:27.901   839   839 I update_engine: [INFO:metrics_reporter_android.cc(131)] Current update attempt downloads 0 bytes data
08-10 11:26:27.902  7214  7232 I SystemUpdate: [SystemUpgradeService] Error applying OTA. Error: 7 DL error: 0
```

设备被disable-verify了！

需要执行adb enable-verity然后重启即可。



【update_engine selinux问题】

1、重新跑一下，内置sd 好了，外置还不行。

前面五条 avc log已经不存在 ，但仍然报如下错误：

08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25927): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1

dac_read_search

audit2allow一下：

allow update_engine self:capability dac_read_search;

编译报错，neverallow，百度之后加上dac_override，继续报错。

尝试直接  dac_override/dac_read_search 权限放开，



编译+测试pass。

但是这种方式把update_engine的权限放的过于大，不利于系统安全，此方法只能作为备选，需要寻找更合理方案。



3、查看 博客：

https://blog.csdn.net/Donald_Zhuang/article/details/108786482

dac_override/dac_read_search  和文件rwx权限检查相关，说明update_engine没有读取外置sd文件权限。

貌似没什么用，因为update_engine已经添加过了sdcard 组权限：



陷入总以为 rwxrwx---导致 ，无法chmod 777，即使改成功了，还是失败了。

启发于这篇文章：

https://blog.csdn.net/shift_wwx/article/details/85633801

仔细查看 发现sdcard下面 目录，属于everybody这个组，所以灵机一动，everybody加上：



```
service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
    class late_start
    user root
    group root system wakelock inet cache media_rw everybody
    writepid /dev/cpuset/system-background/tasks /dev/blkio/background/tasks
    disabled
```

成功升级。



成功升级。

一旦遇到dac_override/dac_read_search相关问题，不要指望直接添加白名单，权限过于大，需要考虑如何改对应权限。

如何确认update_engine 拥有everybody权限：

cat /proc/[pid]/status 

查看是否Groups有哪些数字： 9997代表everybody



![image-20220913104402763](Image/image-20220913104402763.png)



### 【差分包制作】

1、编译两个targetfiles
python out_sys/target/product/mssi_t_64_cn/images/split_build.py --system-dir out_sys/target/product/mssi_t_64_cn/images --vendor-dir out_vnd/target/product/dl36/images --kernel-dir out_vnd/target/product/dl36/images --output-dir out/target/product/dl36 --otapackage --targetfiles
（一个source，一个target）

2、使用如下命令生成差分包，注意先执行Note中步骤
AB update:

./build/tools/releasetools/ota_from_target_files -p out/host/linux-x86 -k device/mediatek/common/security/releasekey -i source.zip target.zip AB_delta.zip

Note: no need --block, A/B only has block-based update

if your project do not have releasekey, please delete " -k device/mediatek/common/security/releasekey" in command, that will use default key(test key)

 

Note:

if build failed, please execute the following three commands first:
cp out_sys/host/linux-x86/* out/host/linux-x86/ -rf
cp out_sys/soong/host/linux-x86/* out/host/linux-x86/ -rf
cp out/soong/host/linux-x86/* out/host/linux-x86/ -rf
Before build Increment OTA package, you must ensure you shell environment has done source and lunch!!!
zip is the old version target package, the version on the current platform should be the same as the source.zip version.
zip is the new version target package.@Lucas试试看



记得一定要删除out目录编译，否则会有hash对不上的问题。





### 【拆解update】

1、Android AB系统原生功能

a. 能编译OTA全量包

b. recovery ，sideload+外置SD卡升级成功

c. DLSystemUpdate升级成功

d. mssi引入的情况下，差分包制作，并升级成功 (写入wiki)



2、DL定制部分的升级

a. lock/unlock

b. DL 电池20% + 相关校验DLCheckCompatibilityList+错误码返回 

c. dlaux/last_result.prop信息写入

d. Enterprise wash reset

ENTERPRISE_RESET

e.去除时间戳校验，如果ota包的时间比当前的旧，默认清除enterprise的数据

f. Metadata

g. factoryreset



第二次总结：

1、电池校验（APK+update_engine+recovery）

2、兼容性校验DLCheckCompatibilityList

3、升级失败错误码返回 

4、dlaux/last_result.prop信息写入

5、去除编译时间戳校验，如果ota包的时间比当前的旧，默认清除enterprise的数据

6、dl_action和dl_extra_action，以及生成对应生成的meta数据，已经升级后，是否奏效

7、Enterprise



VF A13 收益

GKI——5G



补充wiki：差分升级、factory工具



recovery：

1、DHAS_SDCARD

2、DUSE_SCAN_KEYS

3、DDL_SYSTEM_UPDATE

4、minui

5、librecovery_ui

6、dl_recovery



电量检测，sku校验，lock包，extra action





#### update_engine

        "libdeviceDL_static_system",
        "librecoverydl",
        "librecovery_utils",
        "libotautil",



### 关于lock/unlock、factoryreset、enterprisereset、dl_extra_actions

```
ota打包的时候，新增支持的参数：
--dl_action
factoryreset     metadata["ro.action.reset"] = "factory";
enterprisereset  metadata["ro.action.reset"] = "enterprise";
lock             metadata["ro.action.set_device_lock"] = "1";
unlock           metadata["ro.action.set_device_lock"] = "0";

--dl_extra_actions

key:value
ro.action.extra.[key]   -->  value   --> OTA metadata
update_engine --> /sys/bus/platform/devices/factory_data/[key] ---> value


特殊情况：frpreset：1
DoFrpReset

通常情况：
apply_ota_extra_action
写入factory数据

比如写：
python [py tool] --dl_action unlock --dl_extra_actions frpreset:1,enable_adb:1

```

源码简要总结：

(1)ota_from_target_files.py

根据生成ota包的命令，解析对应的参数，并做了两件事：

1、接受参数，起始点

2、将命令参数标记在ro.action.属性，存储在ota包的meta里面

```
   args = common.ParseOptions(argv, __doc__,
                             extra_opts="b:k:i:d:e:t:2o:",
                             extra_long_opts=[
                                 "package_key=",
                                 "incremental_from=",
                                 "full_radio",
                                 "full_bootloader",
                                 "wipe_user_data",
                                 "downgrade",
                                 "override_timestamp",
                                 "extra_script=",
                                 "worker_threads=",
                                 "two_step",
                                 "include_secondary",
                                 "no_signing",
                                 "block",
                                 "binary=",
                                 "oem_settings=",
                                 "oem_no_mount",
                                 "verify",
                                 "stash_threshold=",
                                 "log_diff=",
                                 "payload_signer=",
                                 "payload_signer_args=",
                                 "payload_signer_maximum_signature_size=",
                                 "payload_signer_key_size=",
                                 "extracted_input_target_files=",
                                 "skip_postinstall",
                                 "retrofit_dynamic_partitions",
                                 "skip_compatibility_check",
                                 "output_metadata_path=",
                                 "disable_fec_computation",
                                 "force_non_ab",
                                 "boot_variable_file=",
                                 "dl_action=",
                                 "dl_extra_actions=",
                             ], extra_option_handler=option_handler)
 
 if OPTIONS.dl_action is not None:
    additional_args += ["--dl_action", OPTIONS.dl_action]
    if OPTIONS.dl_action=="factoryreset":
      metadata["ro.action.reset"] = "factory";
    if OPTIONS.dl_action=="enterprisereset":
      metadata["ro.action.reset"] = "enterprise";
    if OPTIONS.dl_action=="lock":
      metadata["ro.action.set_device_lock"] = "1";
    if OPTIONS.dl_action=="unlock":
      metadata["ro.action.set_device_lock"] = "0";


  if OPTIONS.dl_extra_actions is not None:
    additional_args += ["--dl_extra_actions", OPTIONS.dl_extra_actions]
    dl_extra_actions_list = OPTIONS.dl_extra_actions.split(",")
    for dl_extra_action in dl_extra_actions_list:
      meta_key,meta_value = (None, None)
      dl_extra_action_split = dl_extra_action.split(":", 1)
      if len(dl_extra_action_split) != 2:
          raise common.ExternalError("couldn't parse extra dl_extra_action {}".format(dl_extra_action))
          continue
      #key = None if empty strings
      dl_extra_action_split[0] = dl_extra_action_split[0].strip()
      if len(dl_extra_action_split[0]) != 0:
          meta_key = ("ro.action.extra." + dl_extra_action_split[0])
      dl_extra_action_split[1] = dl_extra_action_split[1].strip()
      if len(dl_extra_action_split[1]) != 0:
          meta_value = dl_extra_action_split[1]
      if meta_key is not None and meta_value is not None:
        metadata[meta_key]=meta_value
      else:
        raise common.ExternalError("couldn't parse dl_extra_action {}".format(dl_extra_action))
```



（2）

brillo_update_payload是制作payload.bin件：

脚本入口：

```
brillo_update_payload generate [参数] [参数值]
# Sanity check that the real generator exists:
GENERATOR="$(which delta_generator || true)"
[[ -x "${GENERATOR}" ]] || die "can't find delta_generator"

case "$COMMAND" in
  generate) validate_generate
            cmd_generate
            ;;
  hash) validate_hash
        cmd_hash
        ;;
  sign) validate_sign
        cmd_sign
        ;;
  properties) validate_properties
              cmd_properties
              ;;
  verify) validate_verify_and_check
          cmd_verify
          ;;
  check) validate_verify_and_check
         cmd_check
         ;;
esac

```

![image-20220914183851519](Image/image-20220914183851519.png)



```
cmd_properties() {
  "${GENERATOR}" \
      -in_file="${FLAGS_payload}" \
      -properties_file="${FLAGS_properties_file}"
  GENERATOR_ARGS=(
    -in_file="${FLAGS_payload}"
    -properties_file="${FLAGS_properties_file}"
  )

  if [[ -n "${FLAGS_dl_action}" ]]; then
    GENERATOR_ARGS+=( --dl_action="${FLAGS_dl_action}" )
  fi

  if [[ -n "${FLAGS_dl_extra_actions}" ]]; then
    GENERATOR_ARGS+=( --dl_extra_actions="${FLAGS_dl_extra_actions}" )
  fi

  "${GENERATOR}" "${GENERATOR_ARGS[@]}"
}
```



读取到--dl_action，获取到参数值，然后再重新映射到--dl_action="${FLAGS_dl_action}"去



system/update_engine/payload_generator/payload_file.cc

```
if(!config.dl_action.empty()){
    if(config.dl_action == "lock"){
      //lock package
      dl_checks->set_lock_system(DLCustomChecks::LOCK);
    }
    if(config.dl_action == "unlock"){
      //unlock package
      dl_checks->set_lock_system(DLCustomChecks::UNLOCK);
    }
  }

  if (!config.dl_extra_actions.empty()) {
    std::vector<base::StringPiece> dl_extra_actions_list = SplitStringPiece(
      config.dl_extra_actions, ",", base::TRIM_WHITESPACE, base::SPLIT_WANT_NONEMPTY);

    for (const base::StringPiece& dl_extra_action : dl_extra_actions_list) {
      std::vector<base::StringPiece> keyValue = SplitStringPiece(
        dl_extra_action, ":", base::TRIM_WHITESPACE, base::SPLIT_WANT_NONEMPTY);
      if (keyValue.size() != 2) {
        LOG(INFO) << "couldn't parse extra dl_extra_action " << dl_extra_action;
        continue;
      }
      DLCustomChecks::ExtraAction* extra_action = dl_checks->add_extra_actions();
      extra_action->set_name(keyValue[0].as_string());
      extra_action->set_value(keyValue[1].as_string());
    }
  }
```

整合成结构体，写入bin文件。

update_engine_config.txt



最终干活的是delta_generator



system/update_engine/payload_generator/generate_delta_main.cc

```
 payload_config.max_timestamp = FLAGS_max_timestamp;

  payload_config.device_sku = FLAGS_device_sku;

  if (!FLAGS_dl_action.empty()) {
    payload_config.dl_action = FLAGS_dl_action;
  }

  if (!FLAGS_dl_extra_actions.empty()) {
    payload_config.dl_extra_actions = FLAGS_dl_extra_actions;
  }
```





if (!FLAGS_in_file.empty()) {
    return ApplyPayload(FLAGS_in_file, payload_config) ? 0 : 1;
  }



最终ApplyPayload通过config文件生成bin



下载进去的核心是：DeltaPerformer

Wirte

ValidateManifest

DLCheckCompatibilityList

SetLockSecureBoot DLApplyExtraActions





#### 没有几个关键方法set_lock_system、has_lock_system、lock_system？

 lock_system是定义在protobuf里面的，set get has方法都是在编译过程中生成，生成命令如上

protoc --cpp_out=out/   system/update_engine/update_metadata.proto

![哈哈哈](../../../Share/哈哈哈.png)



![2022-09-15_10-51](../../../Share/2022-09-15_10-51.png)



X5 extra action编译命令:

```
export DL_ACTION := unlock ; export DL_EXTRA_ACTIONS := "frpreset:1,bluetooth_type:10086" ; make -j32 otapackage
```



1、电池校验（APK+update_engine+recovery）

2、兼容性校验DLCheckCompatibilityList

3、升级失败错误码返回 

4、dlaux/last_result.prop信息写入

5、去除编译时间戳校验，如果ota包的时间比当前的旧，默认清除enterprise的数据

6、dl_action和dl_extra_action，以及生成对应生成的meta数据，已经升级后，是否奏效

7、Enterprise





### update:

```
AB分区切换问题，拒绝升级方法查询

电量检测

兼容性检查DLCheckCompatibilityList

升级失败错误码返回

lock unlock

factory reset

enterprise reset

dl_action/dl_extra_action 写节点还在进行中
功能包是否每次验证

librecoverydl
UE_SIDELOAD

recovery reset问题
48成功没unlock问题

降级是否要清除数据？待确认，google patch问题


```





```
sudo apt-get install rename

rename "s/.bp/.bp.bak/" *.bp ; rename "s/.mk/.mk.bak/" *.mk
rename 's/\.bak$//' *.bak
```





![image-20220921152639310](Image/image-20220921152639310.png)



![image-20220921155038940](Image/image-20220921155038940.png)

界面上定义的内容，代码如上。

最终是否执行reset操作的方法是：setOtaActionValue setActionValue





![image-20220921175809569](Image/image-20220921175809569.png)

downgrade reset：

```
  
  if (manifest_.max_timestamp() < hardware_->GetBuildTimestamp()) {
    LOG(ERROR) << "The current OS build timestamp ("
               << hardware_->GetBuildTimestamp()
               << ") is newer than the maximum timestamp in the manifest ("
               << manifest_.max_timestamp() << ")";
    if (!hardware_->AllowDowngrade()) {
      //return ErrorCode::kSuccess;
    if (!install_plan_->powerwash_required && !install_plan_->enterprisewash_required) {
      install_plan_->powerwash_required = true;
    }
    }
    LOG(INFO) << "The current OS build allows downgrade, continuing to apply"
                 " the payload with an older timestamp.";
  }
```



### DLCheckCompatibilityList

![image-20220922122933164](Image/image-20220922122933164.png)

09-22 07:02:44.913 I/update_engine(  787): [INFO:delta_performer.cc(1808)] Lucas DLCheck---->DLCheckCompatibilityList: start.....
09-22 07:02:44.940 I/update_engine(  787): [INFO:delta_performer.cc(1889)] Lucas DLCheck---->Device id: OTA 44 device 44
09-22 07:02:44.968 I/update_engine(  787): [INFO:delta_performer.cc(1897)] Lucas DLCheck---->Hardware rev: OTA 0 device 1
09-22 07:02:44.998 I/update_engine(  787): [INFO:delta_performer.cc(1889)] Lucas DLCheck---->Device id: OTA 44 device 44
09-22 07:02:45.033 I/update_engine(  787): [INFO:delta_performer.cc(1897)] Lucas DLCheck---->Hardware rev: OTA 1 device 1
09-22 07:02:45.063 I/update_engine(  787): [INFO:delta_performer.cc(1905)] Lucas DLCheck---->Factory rev: OTA 3 device 3
09-22 07:02:45.078 I/update_engine(  787): [INFO:delta_performer.cc(1913)] Lucas DLCheck---->SKU: OTA m11_wlan_gms,m11_wwan_gms device m11_wlan_gms
09-22 07:02:45.086 I/update_engine(  787): [INFO:delta_performer.cc(1936)] Lucas DLCheck---->Standard OTA update permitted
09-22 07:02:45.093 I/update_engine(  787): [INFO:delta_performer.cc(1873)] Lucas DLCheck---->DLCheckProductNameList
09-22 07:02:45.102 I/update_engine(  787): [INFO:delta_performer.cc(1820)] Lucas DLCheck---->DLCheckCompatibilityList: end.....



patch:

```
diff --git a/payload_consumer/delta_performer.cc b/payload_consumer/delta_performer.cc
index 60839b8d..ed2e06da 100644
--- a/payload_consumer/delta_performer.cc
+++ b/payload_consumer/delta_performer.cc
@@ -1805,6 +1805,7 @@ ErrorCode DeltaPerformer::ValidateManifest() {
   }
 
   bool is_reset_required = true;
+  LOG(INFO) << "Lucas DLCheck---->DLCheckCompatibilityList: start.....";
   ErrorCode checkCode = DLCheckCompatibilityList(manifest_.dl_checks(), is_reset_required);
   if(checkCode != ErrorCode::kSuccess){
     return checkCode;
@@ -1816,6 +1817,7 @@ ErrorCode DeltaPerformer::ValidateManifest() {
   //lmx
   // TODO(garnold) we should be adding more and more manifest checks, such as
   // partition boundaries etc (see chromium-os:37661).
+  LOG(INFO) << "Lucas DLCheck---->DLCheckCompatibilityList: end.....";
 
   return ErrorCode::kSuccess;
 }
@@ -1835,13 +1837,13 @@ ErrorCode DeltaPerformer::DLCheckCompatibilityList(const DLCustomChecks dl_check
         switch(dl_checks.lock_system()) {
           case DLCustomChecks::LOCK:
             hardware_->SetLockSecureBoot();
-            LOG(INFO) << "IsSecureBoot-lock: " <<  hardware_->IsSecureBoot();
+            LOG(INFO) << "Lucas DLCheck---->IsSecureBoot-lock: " <<  hardware_->IsSecureBoot();
             //Returning error because the lock package should not modify A/B partitions
             return ErrorCode::kDLLock;
             break;
           case DLCustomChecks::UNLOCK:
             hardware_->SetUnlockSecureBoot();
-            LOG(INFO) << "IsSecureBoot-unlock: " <<  hardware_->IsSecureBoot();
+            LOG(INFO) << "Lucas DLCheck---->IsSecureBoot-unlock: " <<  hardware_->IsSecureBoot();
             //Returning error because the unlock package should not modify A/B partitions
             return ErrorCode::kDLUnlock;
             break;
@@ -1851,14 +1853,14 @@ ErrorCode DeltaPerformer::DLCheckCompatibilityList(const DLCustomChecks dl_check
       }
 
       if (dl_checks.extra_actions().size() > 0) {
-        LOG(ERROR) << "Applying Extra Actions";
+        LOG(INFO) << "Lucas DLCheck---->Applying Extra Actions";
         ErrorCode code = DLApplyExtraActions(dl_checks.extra_actions());
         switch (code) {
           case ErrorCode::kDLDoneExtraActions:
-            LOG(INFO) << "No ota update but all extra actions applyed";
+            LOG(INFO) << "Lucas DLCheck---->No ota update but all extra actions applyed";
             return code;
           case ErrorCode::kDLWrongExtraAction:
-            LOG(ERROR) << "No ota update and at least 1 extra action failed";
+            LOG(ERROR) << "Lucas DLCheck---->No ota update and at least 1 extra action failed";
             return code;
           default:
             LOG(WARNING) << "Unexpected DLApplyExtraActions return code: " << code;
@@ -1868,22 +1870,23 @@ ErrorCode DeltaPerformer::DLCheckCompatibilityList(const DLCustomChecks dl_check
 
       if (DLCheckProductNameList(compatibility_element.product_names(), compatibility_element.cross_product_names(),
           dl_checks.device_sku(), is_reset_required)) {
+        LOG(INFO) << "Lucas DLCheck---->DLCheckProductNameList";
         require_reset = is_reset_required;
         return ErrorCode::kSuccess;
       }
     }
   }
   if (wrong_device) {
-    LOG(ERROR) << "Device incompatible with OTA";
+    LOG(ERROR) << "Lucas DLCheck---->Device incompatible with OTA";
     return ErrorCode::kDLWrongDevice;
   } else {
-    LOG(ERROR) << "Wrong SKU";
+    LOG(ERROR) << "Lucas DLCheck---->Wrong SKU";
     return ErrorCode::kDLWrongSKU;
   }
 }
 
 bool DeltaPerformer::DLCheckDeviceId(uint64_t device_id_value){
-  LOG(INFO) << "Device id: OTA " << device_id_value << " device " << hardware_->GetDeviceModelId();
+  LOG(INFO) << "Lucas DLCheck---->Device id: OTA " << device_id_value << " device " << hardware_->GetDeviceModelId();
   if(device_id_value==hardware_->GetDeviceModelId())
     return true;
   else
@@ -1891,7 +1894,7 @@ bool DeltaPerformer::DLCheckDeviceId(uint64_t device_id_value){
 }
 
 bool DeltaPerformer::DLCheckHardwareRev(uint64_t hardware_rev_value){
-  LOG(INFO) << "Hardware rev: OTA " << hardware_rev_value << " device " << hardware_->GetDeviceHardwareRevision();
+  LOG(INFO) << "Lucas DLCheck---->Hardware rev: OTA " << hardware_rev_value << " device " << hardware_->GetDeviceHardwareRevision();
   if(hardware_rev_value==hardware_->GetDeviceHardwareRevision())
     return true;
   else
@@ -1899,7 +1902,7 @@ bool DeltaPerformer::DLCheckHardwareRev(uint64_t hardware_rev_value){
 }
 
 bool DeltaPerformer::DLCheckFactoryRev(uint64_t factory_rev_value){
-  LOG(INFO) << "Factory rev: OTA " << factory_rev_value << " device " << hardware_->GetDeviceFactoryRevision();
+  LOG(INFO) << "Lucas DLCheck---->Factory rev: OTA " << factory_rev_value << " device " << hardware_->GetDeviceFactoryRevision();
   if(factory_rev_value==hardware_->GetDeviceFactoryRevision())
     return true;
   else
@@ -1907,7 +1910,7 @@ bool DeltaPerformer::DLCheckFactoryRev(uint64_t factory_rev_value){
 }
 
 bool DeltaPerformer::DLCheckSKU(string sku_value){
-  LOG(INFO) << "SKU: OTA " << sku_value << " device " << hardware_->GetDeviceSKU();
+  LOG(INFO) << "Lucas DLCheck---->SKU: OTA " << sku_value << " device " << hardware_->GetDeviceSKU();
   if(sku_value.find(hardware_->GetDeviceSKU())!=string::npos)
     return true;
   else
@@ -1922,24 +1925,24 @@ bool DeltaPerformer::DLCheckProductNameList(const RepeatedPtrField<string>& prod
   if(product_names.size() == 0 && cross_product_names.size() == 0) {
     //retrocompatibility with old ota (remove or return false this if retrocompatibility is not permitted)
     if(DLCheckSKU(manifest_product_name)) {
-      LOG(WARNING) << "Found OTA without product_names compatibility but matching SKU, update permitted";
+      LOG(WARNING) << "Lucas DLCheck---->Found OTA without product_names compatibility but matching SKU, update permitted";
       return true;
     }
-    LOG(ERROR) << "Found OTA without product_names compatibility and not matching SKU, update not permitted";
+    LOG(ERROR) << "Lucas DLCheck---->Found OTA without product_names compatibility and not matching SKU, update not permitted";
     return false;
   }
   for (const string product_name : product_names) {
     if(DLCheckSKU(product_name)) {
-      LOG(INFO) << "Standard OTA update permitted";
+      LOG(INFO) << "Lucas DLCheck---->Standard OTA update permitted";
       return true;
     }
   }
   //if the device is unlocked check for cross update with reset (shall never enabled for end user)
-  LOG(INFO) << "IsSecureBoot: " <<  hardware_->IsSecureBoot();
+  LOG(INFO) << "Lucas DLCheck---->IsSecureBoot: " <<  hardware_->IsSecureBoot();
   if(!hardware_->IsSecureBoot()) {
     for (const string product_name : cross_product_names) {
       if(DLCheckSKU(product_name)) {
-        LOG(WARNING) << "cross OTA (without product_names compatibility), update permitted, a reset is applied";
+        LOG(WARNING) << "Lucas DLCheck---->cross OTA (without product_names compatibility), update permitted, a reset is applied";
         require_reset = true;
         return true;
       }
@@ -1952,7 +1955,7 @@ ErrorCode DeltaPerformer::DLApplyExtraActions(const RepeatedPtrField<DLCustomChe
   ErrorCode code = ErrorCode::kDLDoneExtraActions;
   for (const DLCustomChecks::ExtraAction action : extra_actions) {
     bool result = hardware_->ApplyExtraAction(action.name(), action.value());
-    LOG(INFO) << "Extra action: '" << action.name() << "':'" << action.value() << "' -> " << (result ? "pass" : "fail");
+    LOG(INFO) << "Lucas DLCheck---->Extra action: '" << action.name() << "':'" << action.value() << "' -> " << (result ? "pass" : "fail");
     if (!result) code = ErrorCode::kDLWrongExtraAction;
   }
   return code;
```





【梳理】

总体上共生成了4可执行个应用，

具体为：

android主系统使用的的服务端update_engine

客户端update_engine_client

recovery系统使用的update_engine_sideload

host上的升级包工具delta_generator。



这4个可执行应用，部分依赖于4个静态库（update_metadata-protos, libpayload_consumer, libupdate_engine_android, libpayload_generator）和1个共享库（libupdate_engine_client）。



```
update_metadata-protos (STATIC_LIBRARIES)
  --> update_metadata.proto <注意：这里是.proto文件>

libpayload_consumer (STATIC_LIBRARIES)
  --> common/action_processor.cc
      common/boot_control_stub.cc
      common/clock.cc
      common/constants.cc
      common/cpu_limiter.cc
      common/error_code_utils.cc
      common/hash_calculator.cc
      common/http_common.cc
      common/http_fetcher.cc
      common/file_fetcher.cc
      common/hwid_override.cc
      common/multi_range_http_fetcher.cc
      common/platform_constants_android.cc
      common/prefs.cc
      common/subprocess.cc
      common/terminator.cc
      common/utils.cc
      payload_consumer/bzip_extent_writer.cc
      payload_consumer/delta_performer.cc
      payload_consumer/download_action.cc
      payload_consumer/extent_writer.cc
      payload_consumer/file_descriptor.cc
      payload_consumer/file_writer.cc
      payload_consumer/filesystem_verifier_action.cc
      payload_consumer/install_plan.cc
      payload_consumer/payload_constants.cc
      payload_consumer/payload_verifier.cc
      payload_consumer/postinstall_runner_action.cc
      payload_consumer/xz_extent_writer.cc

libupdate_engine_android (STATIC_LIBRARIES)
  --> binder_bindings/android/os/IUpdateEngine.aidl         <注意：这里是.aidl文件>
      binder_bindings/android/os/IUpdateEngineCallback.aidl <注意：这里是.aidl文件>
      binder_service_android.cc
      boot_control_android.cc
      certificate_checker.cc
      daemon.cc
      daemon_state_android.cc
      hardware_android.cc
      libcurl_http_fetcher.cc
      network_selector_android.cc
      proxy_resolver.cc
      update_attempter_android.cc
      update_status_utils.cc
      utils_android.cc

update_engine (EXECUTABLES)
  --> main.cc

update_engine_sideload (EXECUTABLES)
  --> boot_control_android.cc
      hardware_android.cc
      network_selector_stub.cc
      proxy_resolver.cc
      sideload_main.cc
      update_attempter_android.cc
      update_status_utils.cc
      utils_android.cc
      boot_control_recovery_stub.cc

update_engine_client (EXECUTABLES)
  --> binder_bindings/android/os/IUpdateEngine.aidl         <注意：这里是.aidl文件>
      binder_bindings/android/os/IUpdateEngineCallback.aidl <注意：这里是.aidl文件>
      common/error_code_utils.cc
      update_engine_client_android.cc
      update_status_utils.cc

libpayload_generator (STATIC_LIBRARIES)
  --> payload_generator/ab_generator.cc
      payload_generator/annotated_operation.cc
      payload_generator/blob_file_writer.cc
      payload_generator/block_mapping.cc
      payload_generator/bzip.cc
      payload_generator/cycle_breaker.cc
      payload_generator/delta_diff_generator.cc
      payload_generator/delta_diff_utils.cc
      payload_generator/ext2_filesystem.cc
      payload_generator/extent_ranges.cc
      payload_generator/extent_utils.cc
      payload_generator/full_update_generator.cc
      payload_generator/graph_types.cc
      payload_generator/graph_utils.cc
      payload_generator/inplace_generator.cc
      payload_generator/payload_file.cc
      payload_generator/payload_generation_config.cc
      payload_generator/payload_signer.cc
      payload_generator/raw_filesystem.cc
      payload_generator/tarjan.cc
      payload_generator/topological_sort.cc
      payload_generator/xz_android.cc

delta_generator (EXECUTABLES)
  --> payload_generator/generate_delta_main.cc

```



![image-20221009170322524](Image/image-20221009170322524.png)



DownloadAction: ./payload_consumer/download_action.cc
FilesystemVerifierAction: ./payload_consumer/filesystem_verifier_action.cc
PostinstallRunnerAction: ./payload_consumer/postinstall_runner_action.cc







### 【Enterprise】

#### 1、产物

M10下载并编译

```
cd vendor/datalogic/dl35/prebuilts/system/espresso
git clone git@blqsrv819.dl.net:DL35-Priv/device/datalogic/Espresso-tools.git tools
cd -
./build/make/enterprise.sh
```



拷贝enterprise包的脚本

build/make/enterprise2.sh

```
VERSION=V1.0
ENTERPRISE_ESPRESSO=enterprise_espresso

cp out/target/product/dl36/enterprise.img out/target/product/dl36/$ENTERPRISE_ESPRESSO-$VERSION.img
cp out/target/product/dl36/espresso/espresso-packages/enterprise-signed-full.zip enterprise_package_M11_$VERSION.zip
cp out/target/product/dl36/espresso/espresso-packages/enterprise-signed-empty.zip enterprise_package_M11_$VERSION-empty.zip

zip $ENTERPRISE_ESPRESSO-$VERSION.zip -j out/target/product/dl36/$ENTERPRISE_ESPRESSO-$VERSION.img
```



生成enterprise包三个：

ls enterprise_*
enterprise_espresso-V1.0.zip                                  ---------img

enterprise_package_M11_V1.0-empty.zip             ---------ota empty

enterprise_package_M11_V1.0.zip                          ---------ota full



#### 2、代码移植

enterprise本质上就是一些权限比较大的apk，比如记录log、wifi权限等，GMS送测试版本不集成：

![image-20221011171145230](Image/image-20221011171145230.png)

通过ota包的形式刷进去设备

需要移植的部分大致如下：

（1）编译脚本

build/make/enterprise.sh

![image-20221011171430556](Image/image-20221011171430556.png)

注意以上：

需要source环境

需要改为dl36

备注上一条：you need to download Espresso-tools project then run a script



因为这个模块是单独从git仓库下载的



（2）实体内容

![image-20221011171617172](Image/image-20221011171617172.png)

上面那个是直接copy

下面这个是直接git clone下载：

git clone git@blqsrv819.dl.net:DL35-Priv/device/datalogic/Espresso-tools.git tools



通过编译成功生成包（编译+拷贝）：

./build/make/enterprise.sh  ; ./build/make/enterprise2.sh 

![image-20221011171828535](Image/image-20221011171828535.png)



（3）测试踩坑

a、将ota包push进入sdcard，然后升级提示无效包，发现设备名字对不上，修改meatadata

![image-20221011171957963](Image/image-20221011171957963.png)



b、继续调试，提示=SYSTEM_VERSION_INVALID

![image-20221011172047443](Image/image-20221011172047443.png)

发现enterprise的版本号要和系统本地版本的一模一样，于是需要修改如下：

device/datalogic/dl36/datalogic.mk

vendor/datalogic/dl36/prebuilts/system/espresso/enterprise/factory/metadata

vendor/datalogic/dl36/prebuilts/system/espresso/metadata-empty

最重要的修改为device/datalogic/dl36/datalogic.mk

版本一定要对，否则无效包。

![image-20221011172226038](Image/image-20221011172226038.png)

原理如下：

![image-20221011172301000](Image/image-20221011172301000.png)



c、走完这个坑，又来了一个新的

说签名无效，底层报的1005，

enterprise包的签名来源于哪里呢？ espresso.jar

解压出来：

![image-20221011172520052](Image/image-20221011172520052.png)

这个key和系统源码的对的上吗？

![image-20221011172622059](Image/image-20221011172622059.png)

两个key是一致的，那么ota包签名对了吗？

对比一下M11是否和M10保持一致：

![image-20221011172852802](Image/image-20221011172852802.png)

说明签名的没错，为何呢？

查看签名校验的代码：

![image-20221011180748048](Image/image-20221011180748048.png)

![image-20221011180759977](Image/image-20221011180759977.png)

第一次是普通的签名校验

如果失败，第二次是enterprisecerts的校验



而我们M11都没有enterprisecerts包，所以校验不过，而M10也没有，只有SX5有，看来是比较新的feature

build/make/target/product/security/

![image-20221011181138522](Image/image-20221011181138522.png)

![image-20221011181236734](Image/image-20221011181236734.png)



![image-20221011182142669](Image/image-20221011182142669.png)

这三部分移植过去。



**Note:**

enterprise key地址需要改成：

device/datalogic/security/enterprisekey



d、本以为已经踩完了，没想到又报错了：

![image-20221012141955318](Image/image-20221012141955318.png)

报了selinux问题：

```
10-12 04:51:14.828 I/auditd  ( 7833): type=1400 audit(0.0:313): avc: denied { create } for comm="ic.systemupdate" name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 04:51:14.828 W/ic.systemupdate( 7833): type=1400 audit(0.0:313): avc: denied { create } for name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 04:51:14.839 I/InputDispatcher( 1124): setInputWindows displayId=0 Window{c03e7b6 u0 NavigationBar0} Window{7e37239 u0 StatusBar} Wait...#0 Window{1583f88 u0 com.datalogic.systemupdate/com.datalogic.systemupdate.UpdateActivity} Window{585eaee u0 com.android.systemui.ImageWallpaper} 

```



完整日志：

```
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25927): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1
08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25927): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1
10-12 05:03:05.537 I/InputDispatcher( 1124): Focus entered window: Window{585df18 u0 com.datalogic.systemupdate/com.datalogic.systemupdate.UpdateActivity} in display 0
10-12 05:03:05.529 I/auditd  ( 7833): type=1400 audit(0.0:539): avc: denied { create } for comm="ic.systemupdate" name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=1
10-12 05:03:05.529 I/ic.systemupdate( 7833): type=1400 audit(0.0:539): avc: denied { create } for name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=1
10-12 05:03:05.541 D/hwcomposer(  581): (0:1) Layer+ (mva=0x0/sec=0/prot=0/alpha=1:0x87/blend=0002/dim=1/fmt=4868/range=1(0)/x=0 y=0 w=720 h=1280 s=0,0 -> x=0 y=0 w=720 h=1280/layer_type=0 ext_layer=-1 ds=0 fbdc=0) !
10-12 05:03:05.541 D/hwcomposer(  581): (0:2) Layer+ (mva=0x0/sec=0/prot=0/alpha=1:0x79/blend=0002/dim=0/fmt=4868/range=1(0)/x=46 y=0 w=720 h=450 s=832,450 -> x=0 y=439 w=720 h=450/layer_type=0 ext_layer=-1 ds=0 fbdc=0) !
10-12 05:03:05.533 I/auditd  ( 7833): type=1400 audit(0.0:540): avc: denied { create } for comm="ic.systemupdate" name="integrity" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=file permissive=1
10-12 05:03:05.533 I/ic.systemupdate( 7833): type=1400 audit(0.0:540): avc: denied { create } for name="integrity" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=file permissive=1
10-12 05:03:05.537 I/auditd  ( 7833): type=1400 audit(0.0:541): avc: denied { setattr } for comm="ic.systemupdate" name="metadata" dev="mmcblk0p47" ino=8195 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=file permissive=1
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541): avc: denied { setattr } for name="metadata" dev="mmcblk0p47" ino=8195 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=file permissive=1
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541): avc: denied { remove_name } for comm="ic.systemupdate" name="integrity" dev="mmcblk0p47" ino=8194 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
<4>[ 1530.209756] .(1)[7869:ic.systemupdate]audit: audit_lost=31 audit_rate_limit=5 audit_backlog_limit=64
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541):  avc: denied { remove_name } for comm="ic.systemupdate" name="metadata" dev="mmcblk0p47" ino=8195 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
<3>[ 1530.212234] .(1)[7869:ic.systemupdate]audit: rate limit exceeded
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541): avc: denied { remove_name } for comm="ic.systemupdate" name="Logger.apk" dev="mmcblk0p47" ino=8197 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541): avc: denied { remove_name } for comm="ic.systemupdate" name="SureFox.apk" dev="mmcblk0p47" ino=8198 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 05:03:05.537 I/ic.systemupdate( 7833): type=1400 audit(0.0:541): avc: denied { remove_name } for comm="ic.systemupdate" name="SureLock.apk" dev="mmcblk0p47" ino=8199 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 04:49:42.652 I/auditd  ( 8177): type=1400 audit(0.0:255): avc: denied { rmdir } for comm="ic.systemupdate" name="apks" dev="mmcblk0p47" ino=24580 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=1
10-12 04:49:42.652 I/ic.systemupdate( 8177): type=1400 audit(0.0:255): avc: denied { rmdir } for name="apks" dev="mmcblk0p47" ino=24580 scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=1
```



需要添加：

#============= system_app ==============
allow system_app enterprise_file:dir { create remove_name };
allow system_app enterprise_file:file { create setattr };



device/mediatek/sepolicy/basic/non_plat/

添加selinux读写目录和文件的权限：

system_app.te

allow system_app enterprise_file:file { open read write getattr create setattr };
allow system_app enterprise_file:dir { search getattr open read write setattr add_name create remove_name};



allow system_app dlaux_file:file { open read write getattr create setattr };
allow system_app dlaux_file:dir { search getattr open read write setattr add_name };



```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11/device/mediatek/sepolicy/basic$ git diff . 
diff --git a/non_plat/platform_app.te b/non_plat/platform_app.te
index 2871f34..305a048 100644
--- a/non_plat/platform_app.te
+++ b/non_plat/platform_app.te
@@ -121,8 +121,8 @@ allowxperm platform_app proc_mtk_jpeg:file ioctl {
 # Package: com.debug.loggerui
 allow platform_app proc_ccci_sib:file r_file_perms;
 # [115073][chengqian]add enterprise sepolicy
-allow platform_app enterprise_file:file { open read write getattr };
-allow platform_app enterprise_file:dir { search getattr open read write setattr add_name };
+allow system_app enterprise_file:file { open read write getattr create setattr unlink };
+allow system_app enterprise_file:dir { search getattr open read write setattr add_name create remove_name rmdir };
 # [115073][chengqian]add mbw sepolicy
 # [151920] mod by taosongnan for AgingTest app doesn't work properly 2022.8.9
 allow platform_app mbw_file:file { open read write getattr map };
@@ -131,7 +131,7 @@ allow platform_app mbw_file:dir { search getattr open read write setattr add_nam
 allow platform_app mtk_hal_wifi:binder call;
 
 # [127963]add by zhuanglinxuan for dlaux img
-allow platform_app dlaux_file:file { open read write getattr };
+allow platform_app dlaux_file:file { open read write getattr create setattr };
 allow platform_app dlaux_file:dir { search getattr open read write setattr add_name };
 
 #[136700]modify by lvjiahao for bsp api(charging profile) 2022-8-8
diff --git a/non_plat/system_app.te b/non_plat/system_app.te
index 0379060..d1709ed 100644
--- a/non_plat/system_app.te
+++ b/non_plat/system_app.te
@@ -59,11 +59,11 @@ allowxperm system_app proc_mtk_jpeg:file ioctl {
 allow system_app sysfs_fpsgo:dir search;
 allow system_app sysfs_fpsgo:file r_file_perms;
 # [115073][chengqian]add enterprise sepolicy
-allow system_app enterprise_file:file {open read write getattr };
-allow system_app enterprise_file:dir { search getattr open read write setattr add_name };
+allow system_app enterprise_file:file { open read write getattr create setattr unlink };
+allow system_app enterprise_file:dir { search getattr open read write setattr add_name create remove_name rmdir };
 
 # [127963]add by zhuanglinxuan for dlaux img
-allow system_app dlaux_file:file { open read write getattr };
+allow system_app dlaux_file:file { open read write getattr create setattr };
 allow system_app dlaux_file:dir { search getattr open read write setattr add_name };
 
 # [115073][chengqian]add mbw sepolicy

```





unlock定义：

 “adb root” command from the host pc;
 “adb remount” command from the host pc; (conditioned to bootloader unlock)
 ro.boot.selinux set to permissive;
 ro.secure set to 0;
 ro.debuggable set to 1;
 ro.allow.mock.location set to 1



为何升级完，会进入recovery？

空包，升级完会恢复出厂设置。

全包，升级完会装apk，不应该会恢复出厂设置

![image-20221013111657474](Image/image-20221013111657474.png)



进入了recovery，但是没有做任何事情，需要手动重启？

所以是有问题的，查看一下是否有recovery相关的提交。





### 【Duplicate notification "need reboot" after reboot from update successful 】

问题：

升级完，提示重启，然后重启。

重启后，先是提示“升级完成”，然后就再次出现“需要重启”的通知。

![image-20221107163857659](Image/image-20221107163857659.png)



【问题分析】

![2022-11-07_16-43](Image/2022-11-07_16-43.png)



是因为收到了onPayloadApplicationComplete的接口调用

再刚刚升级完会被调用，提示需要重启

onPayloadApplicationComplete



但是重启后，仍然被调用了。

追根溯源发现：

onPayloadApplicationComplete是UpdateEngine.java调用的：

![2022-11-07_16-49](../../../Share/2022-11-07_16-49.png)



onPayloadApplicationComplete最终也是被update_engine调用的。

![image-20221107165049518](Image/image-20221107165049518.png)



![image-20221107165134771](Image/image-20221107165134771.png)

CLEANUP_PREVIOUS_UPDATE是啥？



![image-20221107165250647](Image/image-20221107165250647.png)

CLEANUP_PREVIOUS_UPDATE是啥？

在开机以后会对BootControlAndroid,  HardwareAndroid,BinderUpdateEngineAndroidService等相关重要类进行初始化。初始化昨晚之后执行CleanupPreviousUpdateAction清理状态，CleanupPreviousUpdateAction需要等Bootcomplete之后才会真正执行。

CleanupPreviousUpdateAction会在Virtual A/B的设备上清除上次尝试更新的snapshots。对于非Virtual AB的设备，CleanupPreviousUpdateAction将直接返回。

如果是virtual AB设备，需要等sys.boot_completed值设为1，也就是boot complete之后，才进行清除快照的情况，如果没有则等待并2s查询一次。



参考文档：

https://cloud.tencent.com/developer/article/2011215



所以，下一步怎么处理？

1 测试X5的情况

2 

a.如果X5也存在CLEANUP_PREVIOUS_UPDATE动作，在App中改：

![image-20221107165721332](Image/image-20221107165721332.png)

![image-20221107165823213](Image/image-20221107165823213.png)

b.如果X5不存在CLEANUP_PREVIOUS_UPDATE动作，在Framework改：





### Enterprise升级后提示失败问题

OTA包+enterprise包升级后，会提示升级失败的问题

表面原因：

1 last_result.prop 没有RESET_TYPE=1字段，导致识别不出来

2 slot没有切换成功，两次都是_a



问题1好解决

问题2，为什么没有切换成功？



探索过的思路：

1 metadata被清除了，导致无法读取/metadata/ota的state merge_state等内容

2 ota.warm_reset属性没有设置为1，因为部分代码被注释了

3 metadata/ota/snapshot-boot的内容不对，以为是slot切换的根源



解决方案：

1 不让recovery默认重启

2 寻找enterprise和factoryreset的区别，来自于这条：

![image-20221118162405508](Image/image-20221118162405508.png)

为什么enterprisereset需要恢复到old slot？为什么factory可以继续？看代码：

![image-20221118162547777](Image/image-20221118162547777.png)

allow_forward_merge传的都是ture

那问题必然出现在：access(GetForwardMergeIndicatorPath().c_str(), F_OK) == 0)

发现是metadata/ota/allow-forward-merge下面的文件，

找了一遍，没有找到创建文件的地方

那是因为什么？有没有地方把他删除了呢？

![image-20221118162841329](Image/image-20221118162841329.png)

谁会调用RemoveFileIfExists或者RemoveAllUpdateState呢？

![image-20221118163241298](Image/image-20221118163241298.png)

看样子很像是：

UpdateForwardMergeIndicator

更新这个文件呢



然后看到了这条：

![image-20221118163349183](Image/image-20221118163349183.png)

UpdateForwardMergeIndicator如果wipe为false就会出现上面的问题



那么是谁调用FinishedSnapshotWrites了，并且传了false？

```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11$ ag "FinishedSnapshotWrites"  system/update_engine/  bootable/recovery/    system/core/fs_mgr/
system/update_engine/dynamic_partition_control_android.cc
876:      return snapshot_->FinishedSnapshotWrites(powerwash_required);
879:    LOG(INFO) << "Skip FinishedSnapshotWrites() because /metadata is not "

system/core/fs_mgr/libsnapshot/include/libsnapshot/snapshot.h
147:    bool FinishedSnapshotWrites(bool wipe);

system/core/fs_mgr/libsnapshot/snapshot.cpp
239:    // - For ForwardMerge, FinishedSnapshotWrites asserts that the existence of the indicator
256:bool SnapshotManager::FinishedSnapshotWrites(bool wipe) {
257:    LOG(INFO) << "Lucas-FinishedSnapshotWrites wipe=" << wipe
264:        LOG(INFO) << "FinishedSnapshotWrites already called before. Ignored.";

```



是update——enginie的dynamic_partition_control_android.cc来调用了snapshot。cpp的FinishedSnapshotWrites

看dynamic_partition_control_android.cc代码：

![image-20221118163639264](Image/image-20221118163639264.png)

是否wipe取决于时候powerwash_required？

```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11$ ag "FinishUpdate\("  system/update_engine/  bootable/recovery/    system/core/fs_mgr/
system/update_engine/dynamic_partition_control_android.h
48:  bool FinishUpdate(bool powerwash_required) override;

system/update_engine/payload_consumer/postinstall_runner_action.cc
353:      if (!boot_control_->GetDynamicPartitionControl()->FinishUpdate(

system/update_engine/common/dynamic_partition_control_stub.h
43:  bool FinishUpdate(bool powerwash_required) override;

system/update_engine/common/dynamic_partition_control_stub.cc
54:bool DynamicPartitionControlStub::FinishUpdate(bool powerwash_required) {

system/update_engine/common/dynamic_partition_control_interface.h
90:  virtual bool FinishUpdate(bool powerwash_required) = 0;

system/update_engine/dynamic_partition_control_android.cc
870:bool DynamicPartitionControlAndroid::FinishUpdate(bool powerwash_required) {
lucas@DLCNRDBS03:~/AOSP/Memor11_A11$ 

```



感觉距离终点越来越经了

system/update_engine/payload_consumer/postinstall_runner_action.cc

![image-20221118163855009](Image/image-20221118163855009.png)

factoryreset可以行，所以powerwash_required=true

但是enterprisereset也是需要调用的，没有调用，可咋办？把判断也加上：

![image-20221118164008683](Image/image-20221118164008683.png)

问题解决。



这个问题为什么托了那么久，找到方向真的很重要，特别是这种涉及多个模块的，并且无法顺利调试的。





【为什么开机不提示 Enterprise reset success】

因为在开机配置界面停留太久，SystemUpdateService正在更新，如果在进入桌面后，已经删除了dlaux/last_result.prop，则不会再次弹出

Enterprise reset success

想要测试，则需要快速进入桌面，然后才会显示出来。

```
adb wait-for-device  ; adb root  ; adb_while_do_cmd  "cat dlaux/last_result.prop"
```

![image-20221121113932542](Image/image-20221121113932542.png)



【A/B slot switch】

1118 image (a)

---- > 1118 ota (b)

 ---- > 1118 image (a) (download only)

不能开机。因为slot=b。

fastboot set_active a 

能开机。但是sdcard没有之前的内容

---- >1118 ota (b)

---- > 1118 image (a) (firmware upgrade)

slot=a

成功开机!



```
ldeng@dotorom:~/Test$ fastboot  getvar  all 
(bootloader) max-download-size: 0x8000000
(bootloader) variant: 
(bootloader) logical-block-size: 0x200
(bootloader) erase-block-size: 0x80000
(bootloader) hw-revision: ca00
(bootloader) battery-soc-ok: yes
(bootloader) battery-voltage: 4176mV
(bootloader) partition-size:sgpt: 8000
(bootloader) partition-type:sgpt: raw data
(bootloader) partition-size:flashinfo: 1000000
(bootloader) partition-type:flashinfo: raw data
(bootloader) partition-size:otp: 2b00000
(bootloader) partition-type:otp: raw data
(bootloader) partition-size:userdata: 5ec4f8000
(bootloader) partition-type:userdata: ext4
(bootloader) partition-size:dlconfig: 300000
(bootloader) partition-type:dlconfig: raw data
(bootloader) partition-size:mbw: 3200000
(bootloader) partition-type:mbw: raw data
(bootloader) partition-size:dlaux: a00000
(bootloader) partition-type:dlaux: raw data
(bootloader) partition-size:enterprise: 20000000
(bootloader) partition-type:enterprise: raw data
(bootloader) partition-size:factory: 100000
(bootloader) partition-type:factory: raw data
(bootloader) partition-size:vbmeta_vendor_b: 800000
(bootloader) partition-type:vbmeta_vendor_b: raw data
(bootloader) partition-size:vbmeta_system_b: 800000
(bootloader) partition-type:vbmeta_system_b: raw data
(bootloader) partition-size:vbmeta_b: 800000
(bootloader) partition-type:vbmeta_b: raw data
(bootloader) partition-size:super: 100000000
(bootloader) partition-type:super: raw data
(bootloader) partition-size:tee_b: 800000
(bootloader) partition-type:tee_b: raw data
(bootloader) partition-size:dtbo_b: 800000
(bootloader) partition-type:dtbo_b: raw data
(bootloader) partition-size:vendor_boot_b: 4000000
(bootloader) partition-type:vendor_boot_b: raw data
(bootloader) partition-size:boot_b: 2000000
(bootloader) partition-type:boot_b: raw data
(bootloader) partition-size:lk_b: 100000
(bootloader) partition-type:lk_b: raw data
(bootloader) partition-size:gz_b: 1000000
(bootloader) partition-type:gz_b: raw data
(bootloader) partition-size:sspm_b: 100000
(bootloader) partition-type:sspm_b: raw data
(bootloader) partition-size:scp_b: 100000
(bootloader) partition-type:scp_b: raw data
(bootloader) partition-size:spmfw_b: 100000
(bootloader) partition-type:spmfw_b: raw data
(bootloader) partition-size:md1dsp_b: 1000000
(bootloader) partition-type:md1dsp_b: raw data
(bootloader) partition-size:md1img_b: 6400000
(bootloader) partition-type:md1img_b: raw data
(bootloader) partition-size:vbmeta_vendor_a: b00000
(bootloader) partition-type:vbmeta_vendor_a: raw data
(bootloader) partition-size:vbmeta_system_a: 800000
(bootloader) partition-type:vbmeta_system_a: raw data
(bootloader) partition-size:vbmeta_a: 800000
(bootloader) partition-type:vbmeta_a: raw data
(bootloader) partition-size:tee_a: 500000
(bootloader) partition-type:tee_a: raw data
(bootloader) partition-size:dtbo_a: 800000
(bootloader) partition-type:dtbo_a: raw data
(bootloader) partition-size:vendor_boot_a: 4000000
(bootloader) partition-type:vendor_boot_a: raw data
(bootloader) partition-size:boot_a: 2000000
(bootloader) partition-type:boot_a: raw data
(bootloader) partition-size:lk_a: 100000
(bootloader) partition-type:lk_a: raw data
(bootloader) partition-size:gz_a: 1000000
(bootloader) partition-type:gz_a: raw data
(bootloader) partition-size:sspm_a: 100000
(bootloader) partition-type:sspm_a: raw data
(bootloader) partition-size:scp_a: 100000
(bootloader) partition-type:scp_a: raw data
(bootloader) partition-size:spmfw_a: 100000
(bootloader) partition-type:spmfw_a: raw data
(bootloader) partition-size:md1dsp_a: 1000000
(bootloader) partition-type:md1dsp_a: raw data
(bootloader) partition-size:md1img_a: 6400000
(bootloader) partition-type:md1img_a: raw data
(bootloader) partition-size:logo: b00000
(bootloader) partition-type:logo: raw data
(bootloader) partition-size:nvram: 4000000
(bootloader) partition-type:nvram: raw data
(bootloader) partition-size:proinfo: 300000
(bootloader) partition-type:proinfo: raw data
(bootloader) partition-size:sec1: 200000
(bootloader) partition-type:sec1: raw data
(bootloader) partition-size:seccfg: 800000
(bootloader) partition-type:seccfg: raw data
(bootloader) partition-size:protect2: ade000
(bootloader) partition-type:protect2: ext4
(bootloader) partition-size:protect1: 800000
(bootloader) partition-type:protect1: ext4
(bootloader) partition-size:metadata: 2000000
(bootloader) partition-type:metadata: raw data
(bootloader) partition-size:md_udc: 169a000
(bootloader) partition-type:md_udc: ext4
(bootloader) partition-size:nvdata: 4000000
(bootloader) partition-type:nvdata: ext4
(bootloader) partition-size:nvcfg: 2000000
(bootloader) partition-type:nvcfg: ext4
(bootloader) partition-size:frp: 100000
(bootloader) partition-type:frp: raw data
(bootloader) partition-size:expdb: 1400000
(bootloader) partition-type:expdb: raw data
(bootloader) partition-size:splash: 800000
(bootloader) partition-type:splash: raw data
(bootloader) partition-size:para: 80000
(bootloader) partition-type:para: raw data
(bootloader) partition-size:boot_para: 100000
(bootloader) partition-type:boot_para: raw data
(bootloader) partition-size:pgpt: 8000
(bootloader) partition-type:pgpt: raw data
(bootloader) partition-size:preloader_b: 40000
(bootloader) partition-type:preloader_b: raw data
(bootloader) partition-size:preloader_a: 40000
(bootloader) partition-type:preloader_a: raw data
(bootloader) partition-size:preloader: 40000
(bootloader) partition-type:preloader: raw data
(bootloader) serialno: 0123456789123456789S22F12345LOC1518E8
(bootloader) off-mode-charge: 1
(bootloader) warranty: yes
(bootloader) unlocked: no
(bootloader) secure: yes
(bootloader) kernel: lk
(bootloader) product: dl36
(bootloader) is-userspace: no
(bootloader) slot-retry-count:b: 1
(bootloader) slot-retry-count:a: 1
(bootloader) slot-unbootable:b: no
(bootloader) slot-unbootable:a: no
(bootloader) slot-successful:b: yes
(bootloader) slot-successful:a: yes
(bootloader) slot-count: 2
(bootloader) current-slot: b
(bootloader) has-slot:sgpt: no
(bootloader) has-slot:flashinfo: no
(bootloader) has-slot:otp: no
(bootloader) has-slot:userdata: no
(bootloader) has-slot:dlconfig: no
(bootloader) has-slot:mbw: no
(bootloader) has-slot:dlaux: no
(bootloader) has-slot:enterprise: no
(bootloader) has-slot:factory: no
(bootloader) has-slot:super: no
(bootloader) has-slot:vbmeta_vendor: yes
(bootloader) has-slot:vbmeta_system: yes
(bootloader) has-slot:vbmeta: yes
(bootloader) has-slot:tee: yes
(bootloader) has-slot:dtbo: yes
(bootloader) has-slot:vendor_boot: yes
(bootloader) has-slot:boot: yes
(bootloader) has-slot:lk: yes
(bootloader) has-slot:gz: yes
(bootloader) has-slot:sspm: yes
(bootloader) has-slot:scp: yes
(bootloader) has-slot:spmfw: yes
(bootloader) has-slot:md1dsp: yes
(bootloader) has-slot:md1img: yes
(bootloader) has-slot:logo: no
(bootloader) has-slot:nvram: no
(bootloader) has-slot:proinfo: no
(bootloader) has-slot:sec1: no
(bootloader) has-slot:seccfg: no
(bootloader) has-slot:protect2: no
(bootloader) has-slot:protect1: no
(bootloader) has-slot:metadata: no
(bootloader) has-slot:md_udc: no
(bootloader) has-slot:nvdata: no
(bootloader) has-slot:nvcfg: no
(bootloader) has-slot:frp: no
(bootloader) has-slot:expdb: no
(bootloader) has-slot:splash: no
(bootloader) has-slot:para: no
(bootloader) has-slot:boot_para: no
(bootloader) has-slot:pgpt: no
(bootloader) has-slot:preloader: yes
(bootloader) version-baseband: MOLY.LR12A.R3.MP.V225.4.P3
(bootloader) version-bootloader: dl36-f13182b9-20221115155547-2022111811
(bootloader) version-preloader: 
(bootloader) version: 0.5
all: Done!!
Finished. Total time: 0.012s
```



```
ldeng@dotorom:~/Test$ fastboot set_active a 
Setting current slot to 'a'                        OKAY [  0.010s]
Finished. Total time: 0.013s
```



能开机。但是sdcard没有之前的内容。



关于Download only, Firmware Upgrade, Format all的区别：

```
1. SP FlashTool ->firmware upgrade

step1：backup Nvram bin region

step2：format total flash

step3：download all

step4：restore Nvram bin region

 

另外， SP Flashtool->format whole flash：除了partition table与BMT Pool共计82个block，其余全部擦除


 
 
```



![mtk](Image/mtk.png)



```
Firmware Upgrade = update + factory reset(userdata+metadata reset) + misc reset
Download only =  update + userdata reset
Format all = update + factory reset + misc reset + other reset(exclude patition table and BMT Pool)
```



```
firmware upgrade不会擦NV，format all就全清除了，download only相当于factory reset ,但是其实还不如factory reset ,据我的了解它擦不了metadata
```



```
misc分区在 /dev/block/by-name/para下面，找下面的misc或者para
static const char *misc_part_name[] = {"misc", "para"};

static int misc_part_idx = -1;
   if (misc_part_idx < 0 || misc_part_idx >= BOOTCTRL_NUM_SLOTS) {
        if (partition_exists(misc_part_name[0]))
            misc_part_idx = 0;
        else
            misc_part_idx = 1;
    }
    
```





```
static void initDefaultBootControl(struct bootloader_control *bctrl) {
    int slot = 0;//默认就是slot a
    int ret = -1;
    struct slot_metadata *slotp;

    bctrl->magic = BOOTCTRL_MAGIC;
    bctrl->version = BOOTCTRL_VERSION;
    bctrl->nb_slot = BOOTCTRL_NUM_SLOTS;

    /* Set highest priority and reset retry count */
    for (slot = 0; slot < BOOTCTRL_NUM_SLOTS; slot++) {
        slotp = &bctrl->slot_info[slot];
        slotp->successful_boot = 0;

        /*
         * After the first time download, the successful bit of slot a should be set
         * to avoid the udc checkpoint issue that system first bootup time is 2 times
         * than Q which udc is disabled
         */
        if (slot == 0)
            slotp->successful_boot = 1; //第一次下载开机会设置successful_boot =1,这里我们可以客制化获取是否第一次开机

        slotp->priority = BOOT_CONTROL_MAX_PRI;
        slotp->tries_remaining = BOOT_CONTROL_MAX_RETRY;
    }

    bctrl->crc32_le = bootctrl_crc32(~0L, (const uint8_t*)bctrl, sizeof(struct bootloader_control) - sizeof(uint32_t));
}
```





```
/* Bootloader Control AB
 *
 * This struct can be used to manage A/B metadata. It is designed to
 * be put in the 'slot_suffix' field of the 'bootloader_message'
 * structure described above. It is encouraged to use the
 * 'bootloader_control' structure to store the A/B metadata, but not
 * mandatory.
 */
struct bootloader_control {
    // NUL terminated active slot suffix.
    char slot_suffix[4];
    // Bootloader Control AB magic number (see BOOT_CTRL_MAGIC).
    uint32_t magic;
    // Version of struct being used (see BOOT_CTRL_VERSION).
    uint8_t version;
    // Number of slots being managed.
    uint8_t nb_slot : 3;
    // Number of times left attempting to boot recovery.
    uint8_t recovery_tries_remaining : 3;
    // Status of any pending snapshot merge of dynamic partitions.
    uint8_t merge_status : 3;
    // Ensure 4-bytes alignment for slot_info field.
    uint8_t reserved0[1];
    // Per-slot information.  Up to 4 slots.
    struct slot_metadata slot_info[4];
    // Reserved for further use.
    uint8_t reserved1[8];
    // CRC32 of all 28 bytes preceding this field (little endian
    // format).
    uint32_t crc32_le;
} __attribute__((packed));
```



```
struct slot_metadata {
    // Slot priority with 15 meaning highest priority, 1 lowest
    // priority and 0 the slot is unbootable.
    uint8_t priority : 4;
    // Number of times left attempting to boot this slot.
    uint8_t tries_remaining : 3;
    // 1 if this slot has booted successfully, 0 otherwise.
    uint8_t successful_boot : 1;
    // 1 if this slot is corrupted from a dm-verity corruption, 0
    // otherwise.
    uint8_t verity_corrupted : 1;
    // Reserved for further use.
    uint8_t reserved : 7;
} __attribute__((packed));
```



```
    if(mode == READ_PARTITION) {
      if (boot_control.bootctrl_default.magic != BOOTCTRL_MAGIC) {
        if (partition_read(part_name, (uint64_t) OFFSETOF_SLOT_SUFFIX, (uint8_t *) &boot_control, (uint32_t) sizeof(boot_control)) <= 0) {
            pal_log_err("[%s] read boot_control fail\n", MOD);
            return ret;
        }
        if (checkBootControl(&boot_control) == 0)
            pal_log_info("[%s] boot control has initialized\n", MOD);
      }
      memcpy(bctrl, &boot_control, sizeof(struct bootloader_control));
    }
```



```
它把misc信息取出来,给bootloader_control,然后这里面有slot信息

```



```
MTK 恢复出厂设置会清除metadata，因为不清除这块是无法正确的访问data的，因为这块是fbe加密的，会导致无法开机。
Qcom平台则不一样，不清除仍然能开机。X5上恢复出厂设置不会清除metadata。

```



```
Disscuss with ODM, it can be summary as this:
Download only = update system + reset data patition
Firmware Upgrade = Download only + metadata reset + misc reset

And misc partition restore the slot info, if reset will use the default value(slot a), so select the "Firmware Upgrade" can be boot success.
```





**如何调试update_engine?**

Binder Service name:

"android.os.UpdateEngineService"



1. modify update_engine.rc

   ```diff
   diff --git a/update_engine.rc b/update_engine.rc
   index d9780237..a07084b0 100644
   --- a/update_engine.rc
   +++ b/update_engine.rc
   @@ -1,4 +1,4 @@
   -service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
   +service update_engine /system/bin/update_engine2 --logtostderr --logtofile --foreground
        class late_start
        user root
        group root system wakelock inet cache media_rw everybody
   ```

   ```
   adb_root_remount  ; adb push system/update_engine/update_engine.rc  /system/etc/init/update_engine.rc
   ```

   not found, not start

   

2. push to data dir

   ```
   adb_root_remount  ; adb push  out/target/product/dl36/system/bin/update_engine data/system/update_engine
   ```

   then, reboot

3.  check whether start

   ```
   adb root ; adb shell  "ps -AlZ |  grep engine"
   ```

   if start, you can kill it.

   ```
   adb shell kill -9 [pid]
   ```

4. start update_engine

   ```
   adb root ; adb shell  "chmod 0777 /data/system/update_engine ";adb shell  "/data/system/update_engine --logtostderr --logtofile --foreground " &
   ```

5. see logcat

   

   【NOTE】

   刚开始，adb logcat 没有日志，但是/data/misc/update_engine_log下面有

   为什么没有日志？

   ```
   service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
       class late_start
       user root
       group root system wakelock inet cache media_rw everybody
       writepid /dev/cpuset/system-background/tasks /dev/blkio/background/tasks
       disabled
   
   on property:ro.boot.slot_suffix=*
       enable update_engine
   
   ```

    **--logtostderr --logtofile --foreground** what means?

   adb shell  "/data/system/update_engine --logtostderr --logtofile & "





**如何调试update_engine?**  V2.0

1. modify update_engine.rc

   ```
   service update_engine /system/bin/update_engine2 --logtostderr --logtofile --foreground
       class late_start
       user root
       group root system wakelock inet cache media_rw everybody
       writepid /dev/cpuset/system-background/tasks /dev/blkio/background/tasks
       disabled
   
   on property:ro.boot.slot_suffix=*
       enable update_engine
       exec_background u:r:su:s0 -- /system/bin/sh /system/bin/update_engine_start.sh
   ```

2. create update_engine_start.sh

   ```
   /data/system/update_engine --logtostderr --logtofile --foreground
   ```

3. modify init.project.rc

   ```
       # start update_engine
       chmod 0777 /system/bin/update_engine_start.sh
       chmod 0777 /data/system/update_engine
   ```

4.  push to devices

   ```
   adb push out/target/product/dl36/system/bin/update_engine  data/system/update_engine 
   adb shell "chmod 0777 /data/system/update_engine " 
   ```

   

5. modify update_engine's code  

6. debug round loop 

```
mmm system/update_engine/ ; adb_root_remount ;   adb push out/target/product/dl36/system/bin/update_engine  data/system/update_engine  ; adb shell pidof update_engine  |  xargs -I pid adb shell kill -9 pid ;  adb shell "chmod 0777 /data/system/update_engine "; adb  shell system/bin/update_engine_start.sh  &  ; adb_start_ota ; 
```



### update_engine调试汇总

#### AOSP Pre Change:

- Solution 1

  ```diff
  ldeng@dotorom:~/code/AOSP/M11_A11/system/update_engine$ git diff update_engine.rc 
  diff --git a/update_engine.rc b/update_engine.rc
  index d9780237..1852e58d 100644
  --- a/update_engine.rc
  +++ b/update_engine.rc
  @@ -1,4 +1,4 @@
  -service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
  +service update_engine /system/bin/update_engine2 --logtostderr --logtofile --foreground
       class late_start
       user root
       group root system wakelock inet cache media_rw everybody
  @@ -7,3 +7,4 @@ service update_engine /system/bin/update_engine --logtostderr --logtofile --fore
   
   on property:ro.boot.slot_suffix=*
       enable update_engine
  +    exec_background u:r:su:s0 -- /system/bin/sh /system/bin/update_engine_start.sh
  ```

  ```diff
  ldeng@dotorom:~/code/AOSP/M11_A11/device/datalogic/dl36$ git diff 
  diff --git a/init.project.rc b/init.project.rc
  index 1b61888..3fbd4a0 100755
  --- a/init.project.rc
  +++ b/init.project.rc
  @@ -212,6 +212,12 @@ on post-fs-data
       chown system system /enterprise/factory/extended-description
       #[JAZZ_165975] add for system app acess the /enterprise/factory 2023.01.12 end
   
  +    # support update_engine
  +    copy /system/bin/update_engine /data/system/update_engine
  +    chown root shell /system/bin/update_engine_start.sh
  +    chmod 0777 /system/bin/update_engine_start.sh
  +    chmod 0777 /data/system/update_engine
  +
   on init
       # Refer to http://source.android.com/devices/tech/storage/index.html
       # It said, "Starting in Android 4.4, multiple external storage devices are surfaced to developers through
  ```

  ```diff
  ldeng@dotorom:~/code/AOSP/M11_A11/vendor/datalogic/dl36$ git diff . 
  diff --git a/dl36/device.mk b/dl36/device.mk
  index 2169666..a9df7f3 100644
  --- a/dl36/device.mk
  +++ b/dl36/device.mk
  @@ -10,3 +10,6 @@ PRODUCT_COPY_FILES += \
   #PRODUCT_PACKAGES += libdeviceDL_static_vendor
   #modify by frank for bsp api library libdeviceDL which will be in out_vnd   2022-12-15 end
   
  +PRODUCT_COPY_FILES += $(LOCAL_PATH)/update_engine_start.sh:system/bin/update_engine_start.sh
  ```

  update_engine_start.sh

  ```diff
  + /data/system/update_engine --logtostderr --logtofile --foreground
  ```

  

- Solution 2

  ```diff
  ucas@DLCNRDBS03:~/AOSP/Memor11_A11/system/update_engine$ git diff . 
  diff --git a/Android.bp b/Android.bp
  index e5a58937..6c03687a 100644
  --- a/Android.bp
  +++ b/Android.bp
  @@ -342,6 +342,7 @@ cc_binary {
       required: [
           "cacerts_google",
           "otacerts",
  +        "update_engine_start.sh",
       ],
   
       srcs: ["main.cc"],
  @@ -817,3 +818,10 @@ filegroup {
           "binder_bindings/android/brillo/IUpdateEngineStatusCallback.aidl",
       ],
   }
  +
  +// Script to update_engine_start.sh
  +sh_binary {
  +    name: "update_engine_start.sh",
  +    src: "update_engine_start.sh"
  +}
  +
  diff --git a/main.cc b/main.cc
  index 4377a158..28f27255 100644
  --- a/main.cc
  +++ b/main.cc
  @@ -51,7 +51,7 @@ int main(int argc, char** argv) {
     if (!FLAGS_foreground)
       PLOG_IF(FATAL, daemon(0, 0) == 1) << "daemon() failed";
   
  -  LOG(INFO) << "A/B Update Engine starting";
  +  LOG(INFO) << "Lucas-debug Breaking-Memor11_A11 source code, A/B Update Engine starting--------------";
   
     // xz-embedded requires to initialize its CRC-32 table once on startup.
     xz_crc32_init();
  diff --git a/update_engine.rc b/update_engine.rc
  index d9780237..fde47e6b 100644
  --- a/update_engine.rc
  +++ b/update_engine.rc
  @@ -1,4 +1,11 @@
  -service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
  +on post-fs-data
  +    #start update_engine
  +    copy /system/bin/update_engine /data/system/update_engine
  +    chown root shell /system/bin/update_engine_start.sh
  +    chmod 0777 /system/bin/update_engine_start.sh
  +    chmod 0777 /data/system/update_engine
  +
  +service update_engine /system/bin/update_engine2 --logtostderr --logtofile --foreground
       class late_start
       user root
       group root system wakelock inet cache media_rw everybody
  @@ -7,3 +14,5 @@ service update_engine /system/bin/update_engine --logtostderr --logtofile --fore
   
   on property:ro.boot.slot_suffix=*
       enable update_engine
  +    exec_background u:r:su:s0 -- /system/bin/sh /system/bin/update_engine_start.sh
  
  ```

- update_engine_start.sh

  ```diff
  + /data/system/update_engine --logtostderr --logtofile --foreground
  ```

- system/sepolicy/private/update_engine_start.te

- system/sepolicy//prebuilts/api/30.0/private/update_engine_start.te

  ```
  type update_engine_start, domain, coredomain;
  type update_engine_start_exec, system_file_type, exec_type, file_type;
  
  init_daemon_domain(update_engine_start)
  
  allow update_engine_start shell_exec:file rx_file_perms;
  allow update_engine_start toolbox_exec:file rx_file_perms;
  allow update_engine_start system_file:dir r_dir_perms;
  ```

  

#### Command:

total:

```
source_dl36 ; mmm system/update_engine/ ; adb_root_remount ;   adb push out/target/product/dl36/system/bin/update_engine  data/system/update_engine  ; adb shell pidof update_engine  |  xargs -I pid adb shell kill -9 pid ;  adb shell "chmod 0777 /data/system/update_engine " ; (adb  shell system/bin/update_engine_start.sh &) ; adb_start_ota ; 
```



compile:

```mmm system/update_engine/```



push bin：

```adb_root_remount ;   adb push out/target/product/dl36/system/bin/update_engine  data/system/update_engine  ;```



kill old process：

```adb shell pidof update_engine  |  xargs -I pid adb shell kill -9 pid ;```



start new bin:

```adb shell "chmod 0777 /data/system/update_engine "; adb  shell system/bin/update_engine_start.sh```



test：

```adb_start_ota```





很奇怪的发现，这样竟然也行？

```adb push  system/update_engine```

```diff
ldeng@dotorom:~/code/AOSP/M11_A11/system/update_engine$ git diff . 
diff --git a/dynamic_partition_control_android.cc b/dynamic_partition_control_android.cc
index 3103a381..d4649b02 100644
--- a/dynamic_partition_control_android.cc
+++ b/dynamic_partition_control_android.cc
@@ -761,12 +761,12 @@ bool DynamicPartitionControlAndroid::PrepareSnapshotPartitionsForUpdate(
   }
   auto ret = snapshot_->CreateUpdateSnapshots(manifest);
   if (!ret) {
-    LOG(ERROR) << "Cannot create update snapshots: " << ret.string();
+/*    LOG(ERROR) << "Cannot create update snapshots: " << ret.string();
     if (required_size != nullptr &&
         ret.error_code() == Return::ErrorCode::NO_SPACE) {
       *required_size = ret.required_size();
     }
-    return false;
+    return false;*/
   }
   return true;
 }

```

```diff
ldeng@dotorom:~/code/AOSP/M11_A11/system/core/fs_mgr$ git diff . 
diff --git a/fs_mgr/libsnapshot/snapshot.cpp b/fs_mgr/libsnapshot/snapshot.cpp
index 4178349ed..b94a90f6d 100644
--- a/fs_mgr/libsnapshot/snapshot.cpp
+++ b/fs_mgr/libsnapshot/snapshot.cpp
@@ -2140,11 +2140,11 @@ Return SnapshotManager::CreateUpdateSnapshots(const DeltaArchiveManifest& manife
     // TODO(b/134949511): remove this check. Right now, with overlayfs mounted, the scratch
     // partition takes up a big chunk of space in super, causing COW images to be created on
     // retrofit Virtual A/B devices.
-    if (device_->IsOverlayfsSetup()) {
+    /*if (device_->IsOverlayfsSetup()) {
         LOG(ERROR) << "Cannot create update snapshots with overlayfs setup. Run `adb enable-verity`"
                    << ", reboot, then try again.";
         return Return::Error();
-    }
+    }*/
 
     const auto& opener = device_->GetPartitionOpener();
     auto current_suffix = device_->GetSlotSuffix();

```



【How to keep the log of recovery】

normally, the log stored in this directly:

tmp/recovery.log

after reboot, the log is miss.



[Solution]

use origin code to save the log to the /enterprise/recovery/

after reboot, you can get the log from the /enterprise dir

```diff
ldeng@dotorom:~/code/AOSP/M11_A11/bootable/recovery$ git diff recovery.cpp  recovery_utils/include/recovery_utils/logging.h  recovery_utils/logging.cpp 
diff --git a/recovery.cpp b/recovery.cpp
index a31b33ce..f7c820d5 100644
--- a/recovery.cpp
+++ b/recovery.cpp
@@ -124,7 +124,7 @@ char* resetType = NULL;
 
 static constexpr const char* CACHE_ROOT = "/cache";
 
-static bool save_current_log = false;
+static bool save_current_log = true;
 static bool auto_reboot = false;
 const char* reason = nullptr;
 const char updateResultFile[] = "/dlaux/last_result.prop";
@@ -271,7 +271,8 @@ static void FinishRecovery(RecoveryUI* ui) {
     }
   #endif
 
-  copy_logs(save_current_log);
+  //copy_logs(save_current_log);
+  dl_copy_logs(save_current_log);
 
   // Reset to normal system boot so recovery won't cycle indefinitely.
   std::string err;
@@ -668,7 +669,7 @@ static Device::BuiltinAction PromptAndWait(Device* device, InstallResult status)
         } else {
           ui->SetBackground(RecoveryUI::ERROR);
           ui->Print("Installation aborted.\n");
-          copy_logs(save_current_log);
+          dl_copy_logs(save_current_log);
         }
         break;
       }
@@ -1195,12 +1196,13 @@ Device::BuiltinAction start_recovery(Device* device, const std::vector<std::stri
         ui->Print("Installation aborted.\n");
 
         sideload_auto_reboot = true;//[112836] add by yucaiyun for DL customized recovery 20211221
+        save_current_log = true;
 
         // When I/O error or bspatch/imgpatch error happens, reboot and retry installation
         // RETRY_LIMIT times before we abandon this OTA update.
         static constexpr int RETRY_LIMIT = 4;
         if (status == INSTALL_RETRY && retry_count < RETRY_LIMIT) {
-          copy_logs(save_current_log);
+          dl_copy_logs(save_current_log);
           retry_count += 1;
           set_retry_bootloader_message(retry_count, args);
           // Print retry count on screen.
@@ -1407,6 +1409,7 @@ Device::BuiltinAction start_recovery(Device* device, const std::vector<std::stri
       fprintf(fd, "MESSAGE=Enterprise Update Failure\n");
       fclose(fd);
       chmod(DL_SYSUPDT_LOG_FILE, 0666);
+      save_current_log = true;
     } else {
       status = INSTALL_SUCCESS;
       FILE *fd = fopen(DL_SYSUPDT_LOG_FILE, "w");
@@ -1433,6 +1436,7 @@ Device::BuiltinAction start_recovery(Device* device, const std::vector<std::stri
     if (!ui->IsTextVisible()) {
       sleep(5);
     }
+    save_current_log = true;
   }
 
 #ifdef DATALOGIC_SYSTEM_UPDATE
diff --git a/recovery_utils/include/recovery_utils/logging.h b/recovery_utils/include/recovery_utils/logging.h
index 6d09fcfe..2c055539 100644
--- a/recovery_utils/include/recovery_utils/logging.h
+++ b/recovery_utils/include/recovery_utils/logging.h
@@ -64,5 +64,7 @@ bool RestoreLogFilesAfterFormat(const std::vector<saved_log_file>& log_files);
 
 //[112836] add by yucaiyun for DL customized recovery 20211221
 void dl_copy_logs_files(const std::string& source, const std::string& destination, bool append);
+void dl_copy_logs(bool save_current_log);
+void rename_logs_file_bytime(const char* last_log_file, const char* last_kmsg_file);
 
 #endif  //_LOGGING_H
diff --git a/recovery_utils/logging.cpp b/recovery_utils/logging.cpp
index cca78edc..00507d18 100644
--- a/recovery_utils/logging.cpp
+++ b/recovery_utils/logging.cpp
@@ -50,6 +50,11 @@ constexpr const char* LAST_LOG_FILTER = "recovery/last_log";
 
 constexpr const char* CACHE_LOG_DIR = "/cache/recovery";
 
+constexpr const char* ENTERPRISE_LOG_FILE = "/enterprise/recovery/log";
+constexpr const char* ENTERPRISE_LAST_INSTALL_FILE = "/enterprise/recovery/last_install";
+constexpr const char* ENTERPRISE_LAST_KMSG_FILE = "/enterprise/recovery/last_kmsg";
+constexpr const char* ENTERPRISE_LAST_LOG_FILE = "/enterprise/recovery/last_log";
+
 static struct selabel_handle* logging_sehandle;
 
 void SetLoggingSehandle(selabel_handle* handle) {
@@ -159,6 +164,26 @@ void rotate_logs(const char* last_log_file, const char* last_kmsg_file) {
   }
 }
 
+void rename_logs_file_bytime(const char* last_log_file, const char* last_kmsg_file) {
+  time_t t = time(0);
+  char tmp[32]={0};
+  strftime(tmp, sizeof(tmp), "%Y%m%d_%H%M%S",localtime(&t));
+  //PLOG(ERROR) << "Lucas rename_logs_file_bytime now time=" << tmp;
+
+  std::string old_log = android::base::StringPrintf("%s", last_log_file);
+  std::string new_log = android::base::StringPrintf("%s.%s", last_log_file, tmp);
+  rename(old_log.c_str(), new_log.c_str());
+  //PLOG(ERROR) << "Lucas new_log.c_str()=" << new_log.c_str();
+
+
+  std::string old_kmsg = android::base::StringPrintf("%s", last_kmsg_file);
+  std::string new_kmsg = android::base::StringPrintf("%s.%s", last_kmsg_file, tmp);
+  rename(old_kmsg.c_str(), new_kmsg.c_str());
+  //PLOG(ERROR) << "Lucas new_kmsg.c_str()=" << new_kmsg.c_str();
+
+}
+
+
 // Writes content to the current pmsg session.
 static ssize_t __pmsg_write(const std::string& filename, const std::string& buf) {
   return __android_log_pmsg_file_write(LOG_ID_SYSTEM, ANDROID_LOG_INFO, filename.c_str(),
@@ -244,6 +269,43 @@ void copy_logs(bool save_current_log) {
   sync();
 }
 
+void dl_copy_logs(bool save_current_log) {
+  // We only rotate and record the log of the current session if explicitly requested. This usually
+  // happens after wipes, installation from BCB or menu selections. This is to avoid unnecessary
+  // rotation (and possible deletion) of log files, if it does not do anything loggable.
+  LOG(INFO) << "FinishRecovery is save_current_log ? " << (save_current_log==1 ? "true" : "false");
+  if (!save_current_log) {
+    return;
+  }
+
+  // Always write to pmsg, this allows the OTA logs to be caught in `logcat -L`.
+  copy_log_file_to_pmsg(Paths::Get().temporary_log_file(), ENTERPRISE_LAST_LOG_FILE);
+  copy_log_file_to_pmsg(Paths::Get().temporary_install_file(), ENTERPRISE_LAST_INSTALL_FILE);
+
+  // We can do nothing for now if there's no /Enterprise partition.
+  if (!HasEnterprise()) {
+    return;
+  }
+
+  ensure_path_mounted(ENTERPRISE_LAST_LOG_FILE);
+  ensure_path_mounted(ENTERPRISE_LAST_KMSG_FILE);
+  rename_logs_file_bytime(ENTERPRISE_LAST_LOG_FILE, ENTERPRISE_LAST_KMSG_FILE);
+
+  // Copy logs to Enterprise so the system can find out what happened.
+  copy_log_file(Paths::Get().temporary_log_file(), ENTERPRISE_LOG_FILE, true);
+  copy_log_file(Paths::Get().temporary_log_file(), ENTERPRISE_LAST_LOG_FILE, false);
+  copy_log_file(Paths::Get().temporary_install_file(), ENTERPRISE_LAST_INSTALL_FILE, false);
+  save_kernel_log(ENTERPRISE_LAST_KMSG_FILE);
+  chmod(ENTERPRISE_LOG_FILE, 0600);
+  chown(ENTERPRISE_LOG_FILE, AID_SYSTEM, AID_SYSTEM);
+  chmod(ENTERPRISE_LAST_KMSG_FILE, 0600);
+  chown(ENTERPRISE_LAST_KMSG_FILE, AID_SYSTEM, AID_SYSTEM);
+  chmod(ENTERPRISE_LAST_LOG_FILE, 0640);
+  chmod(ENTERPRISE_LAST_INSTALL_FILE, 0644);
+  chown(ENTERPRISE_LAST_INSTALL_FILE, AID_SYSTEM, AID_SYSTEM);
+  sync();
+}
+
 // Read from kernel log into buffer and write out to file.
 void save_kernel_log(const char* destination) {
   int klog_buf_len = klogctl(KLOG_SIZE_BUFFER, 0, 0);
```



【优化OTA升级时间长的问题】

```diff
ldeng@dotorom:~/code/AOSP/M11_A11/device/mediatek/common$ git diff 
diff --git a/BoardConfig.mk b/BoardConfig.mk
index 5754083..1aecdc3 100644
--- a/BoardConfig.mk
+++ b/BoardConfig.mk
@@ -267,7 +267,8 @@ endif
 BOARD_USES_SYSTEM_OTHER_ODEX := true
 
 # A/B OTA dexopt update_engine hookup
-AB_OTA_POSTINSTALL_CONFIG += \
+# optimize the ota update speed
+#AB_OTA_POSTINSTALL_CONFIG += \
     RUN_POSTINSTALL_system=true \
     POSTINSTALL_PATH_system=system/bin/otapreopt_script \
     FILESYSTEM_TYPE_system=ext4 \
ldeng@dotorom:~/code/AOSP/M11_A11/device/mediatek/common$ 

```





- OTA package with only lock/unlock

  ``` 
  ./build.sh dl36 package[user/userdebug] [aosp/gms] ota-lock/ota-unlock [jobs]
  ```

  actual param：

  ```otapackage="--otapackage --dl_action lock/unlock"```

  After reboot Notification:

  ``` You provided a LOCK/UNLOCK package, please use ADB sideload in Recovery to apply it.```

  

- normal full OTA package：

  ```
   ./build.sh dl36 full package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  actual param：

  ```otapackage="--otapackage --dl_action factoryreset"```

  After reboot Notification:

  ``` Firmware update success/failed!```

  

- full OTA package+Enterprise Reset：

  ```
  ./build.sh dl36 full package [user/userdebug] [aosp/gms] ota-enterprisereset [jobs]
  ```

  actual param：

  ```otapackage="--otapackage --dl_action enterprisereset"```

  After reboot Notification:

  ``` Firmware update and enterprise reset success/failed!```

  

- full OTA package+Factory Reset：

  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  actual param：

  ```otapackage="--otapackage --dl_extra_actions factoryreset:1"```

  After reboot Notification:

  ``` Firmware update and factory reset success/failed!```

  

- OTA package with only Enterprise Reset：

  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-enterprisereset [jobs]
  ```

  

  actual param：

  ```otapackage="--otapackage --dl_extra_actions enterprisereset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with only Factory Reset：

  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  

  actual param：

  ```otapackage="--otapackage --dl_extra_actions factoryreset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with only Frp Reset：

  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-frpsereset [jobs]
  ```

  

  actual param：

  ```otapackage="--otapackage --dl_extra_actions frpsereset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with extra action：

  For example, if you want to modify the bluetooth_type and factory_data_enable_adb in factory data.

  ```
  export FACTORY_DATA=bluetooth_type:1,factory_data_enable_adb:1;
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factorydata [jobs]
  ```

  actual param：

  ```otapackage="--otapackage --dl_extra_actions bluetooth_type:1,factory_data_enable_adb:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

  

- fake OTA package only for testing:

  ```
  export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; 
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factorydata [jobs]
  ```

  actual param：

  `````
  otapackage="--otapackage --dl_extra_actions mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`"
  `````

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```



### 【调试ota_from_target_files.py技巧】

每次编译花很多无须的时间，清除out目录

```
ag -g ota_from_target_files out*/  |  xargs -I file rm file  ; source_dl36 ;  mmm build/make/tools/releasetools/ ;  export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; ./build.sh dl36 package userdebug aosp ota-factorydata 32 
```

用这种方法，而且还不一定有用，必须全编译才生效。



【优化方法】

脚本后面加--targetfiles

```
	python out_sys/target/product/mssi_t_64_cn/images/split_build.py \
		--system-dir out_sys/target/product/mssi_t_64_cn/images \
		--vendor-dir out_vnd/target/product/$product/images \
		--kernel-dir out_vnd/target/product/$product/images \
		--output-dir out/target/product/$product/ $otapackage \
		--targetfiles
```

确保不会自动删除target file。

发现编译过程中，调用ota脚本的语句是：

```
python /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp/releasetools/ota_from_target_files.py -v --block -p /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp out/target/product/dl36/target_files.zip out/target/product/dl36/otapackage.zip 
```

直接调用源码脚本，并进入extra action

```
export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; python build/make/tools/releasetools/ota_from_target_files.py  --dl_extra_actions  $FACTORY_DATA   -v --block -p /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp out/target/product/dl36/target_files.zip out/target/product/dl36/otapackage.zip 
```



【编译test empty包】

```
source_dl36 ; export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; ./build.sh dl36 package userdebug aosp ota-factorydata 32 
```



















