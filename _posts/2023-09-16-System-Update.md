---
layout: post
title: System Update
categories: Excel
description: some word here
keywords: keyword1, keyword2
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



#### 鎼存洖鐪伴幍鎾冲瘶+閸楀洨楠?

bootable/recovery/

build/make/





#### 濠ф劗鐖滅挧鍕灐

http://wiki.mobile.dl.net/mediawiki/index.php/SDK

https://dtcsrv838.dl.net/android-datalogic-common/prebuilts/DLSystemUpdateApp

https://dtcsrv838.dl.net/android-datalogic-common/source-code/DLSystemUpdateApp





#### X5娴狅絿鐖滈弻銉ф箙

I suggest you can learn it from SX5 A11 source code, access it in waylon閳ユ獨 domain in DLCNRDBS02 (10.86.240.14),

waylon@DLCNRDBS02: /home/waylon/project/x5_a11/LINUX/android/

psw:123456





### 閹绘劕宕岀紓鏍槯闁喎瀹?

鏉堝啫鎮嗙涵顒傛磸閿涘苯娴愰幀?
C cache閹垫挸绱?





system 1h 

vendor 0.5h





娑撹桨绮堟稊鍫ｎ洣鐏忓敇pdate_metadata.proto閸︹娍TATIC_LIBRARIES閻ㄥ嫮娴夋惔鏃傛窗瑜版洖鍞撮敍?
閻㈢喐鍨氭禍鍞榩date_metadata.pb.cpp閸滃瘈pdate_metadata.pb.h閺傚洣娆㈤敍?
![image-20220715151249596](/home/ldeng/.config/Typora/typora-user-images/image-20220715151249596.png)





```
adb shell am startservice -n com.datalogic.systemupdate/.SystemUpgradeService  --ei action 2 -e path "/sdcard/ota.zip"  --ei reset 0 --ei force_update 0 --ei reboot 1
```







### SX5閻╃鍙?

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





### 閸楀洨楠囬弬鐟扮础

1閵嗕够ideload缁惧灝鍩?

閺堝搫娅掕箛鍛淬€忕憰涔簅ot閺夊啴妾洪敍灞芥儊閸掓瑦鐥呭▔鏇＄箻閸忣櫣ideload

```
adb reboot sideload
adb sideload  full-ota-xx.zip
```



2閵嗕垢ython閼存碍婀伴崚?
```
python update_engine/scripts/update_device.py  --file full-ota-xx.zip
```

閺堫剝宸濇稉濠冩Ц鐎电畡pdate_engine_client閻ㄥ嫬鐨濈憗鍜冪礉鏉╂瑤閲滅€甸€涚艾婢舵牠鍎撮張澶夌贩鐠ф牭绱濇径褑鍤ф俊鍌欑瑓閿?
- 闂団偓鐟曚礁鐣ㄧ憗鍗籾do apt-get install python-protobuf閿?
- 闂団偓鐟曚垢ush update_engine_client 閵嗕够u缁涘〃in閺傚洣娆㈤敍?
- 闂団偓鐟曚垢ush 娑撯偓娴滄硞o鎼存搫绱?

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

- 鏉╂ɑ妲告导姘Г闁挎瑱绱濋幓鎰仛閿?
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

  閸ョ姳璐無ta閸栧懘鍣烽棃銏＄梾閺堝「ayload.bin閺傚洣娆㈤敍灞惧娴犮儲鐥呭▔鏇熷灇閸旂喆鈧?
  ![image-20220729115741315](Image/image-20220729115741315.png)

  ![image-20220729115714455](Image/image-20220729115714455.png)

  

https://www.thecustomdroid.com/how-to-extract-android-payload-bin-file/

https://blog.csdn.net/u011391629/article/details/103833785

閺勵垰娲滄稉鐑樺灉閻劌绶遍弰鐥琫morK閻ㄥ埣ta閸栧拑绱濇俊鍌涚亯娑撳秵妲窤B缁崵绮洪惃鍕剁礉鐏忓彉绗夋导姘辨晸閹存仠ayload.bin閺傚洣娆㈤妴?


閸戣櫣骞囬幎銉╂晩閿?
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





3閵嗕菇pdate_engine_client閸?
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



4閵嗕竸PK閸楀洨楠?normal mode

鐠佸墽鐤?-->缁崵绮洪崡鍥╅獓--->鏉╂稑鍙唕ecovery閻ｅ矂娼版潻娑滎攽閺囧瓨鏌?



5閵嗕礁鍩涢張鍝勪紣閸?
閺嗗倹妞傛稉宥嗘暜閹?
閵嗘劘顔曢幆鍐差洤閺嬫粏顩﹂弨顖涘瘮閿涘苯顩ф担鏇炰粵閿涚喐婀扮拹銊ょ瑐鏉╂ɑ妲竝ush閺傚洣娆?鐠嬪啰鏁ら幒銉ュ經閵?


6閵嗕線鈧俺绻僡db閸欐吔ntent閸掗攱婧€

```
adb shell am startservice -n com.datalogic.systemupdate/.SystemUpgradeService --ei action 2  -epath  enterprise/enterprise_package_M11_V1.0.zip   --ei reset 0 --ei force_update 0 --ei reboot 1
```





### 闊晛娼?

1閵?
```
Package is for product " << pkg_device << " but expected 
```

鐠佹儳顦稉宥堝厴unlock閿涘苯鎯侀崚娆庣窗get娑撳秴鍩岀仦鐐粹偓褝绱濈€佃壈鍤ф潻娆庨嚋閹躲儵鏁?

![image-20220805104424729](Image/image-20220805104424729.png)

2閵?
```
Update package is older than the current build, expected a build 
```

![image-20220805104446573](Image/image-20220805104446573.png)

閻炲棜顔戞稉濠勭椽鐠囨垹娈戦張顒€婀磇mage閸滃ta閸栧懎鍑＄紒蹇撳讲娴犮儳娲块幒銉ュ磳缁狙呮畱閿涘奔绲鹃弰顖涙拱閸︾櫡mage閻ㄥ嫭妞傞梻瀛樺煈娴兼艾浼撻崗鍫熺槷ota閸栧懎銇囬惃鍕剰閸愮偣鈧?
ota閸栧懐娈戦弮鍫曟？瀵板牏鍑界划鐧哥礉閸ュ搫鐣鹃弰鐥硂.build.date.utc

閺堫剙婀磇mage閻ㄥ嫭妞傞梻瀛樺瑏閸掓壆娈戦敍灞藉讲閼宠姤妲竢o.vendor.build.date.utc

閺堫剙婀磇mage閻ㄥ嫭妞傞梻瀛樺瑏閸掓壆娈戦敍灞藉讲閼宠姤妲竢o.vendor.build.date.utc

閺堫剙婀磇mage閻ㄥ嫭妞傞梻瀛樺瑏閸掓壆娈戦敍灞藉讲閼宠姤妲竢o.vendor.build.date.utc



- ota閸栧懐娈戦弮鍫曟？閹磋櫕鐓￠惇瀣煙濞夋洩绱?

鐟欙絽瀵橀敍灞借嫙閺屻儳婀匨ETA-INF娑撳娼伴惃鍒磂tadata

post-timestamp=1659589248

2022-08-04 13:00:48

閸︹暙ut_sys娑?


- 閺堫剙婀撮崠鍛畱閺冨爼妫块幋铏叀閻鏌熷▔鏇窗

  dl36/mk/vendor_build.prop

  ```
  16:ro.vendor.build.date.utc=1659594562
  33:ro.bootimage.build.date.utc=1659594562
  ```

2022-08-04 14:29:22

閸︹暙ut_vnd娑?


閸︹暈uildinfo.sh娑撳宸辩悰灞炬暭(闁灝鍘ta閺冨爼妫块幋宕囧劜閹?:

```
ro.build.date=Thu Aug  4 17:32:24 CST 2025
ro.build.date.utc=1754299944
```



build閺堝绶㈡径姘嚋閺冨爼妫块敍?
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



3閵嗕礁鍙忛柌蹇撳瘶娑撳秴鍘戠拋绔弌wngrade閿涘苯濮炴禍鍡楀帒鐠佸摜娈戦崣鍌涙殶娑旂喍绗夌悰宀嬬礉閹碘偓娴犮儱绻€妞ょ粯婀伴崷鎵椽鐠?
![image-20220802143529591](Image/image-20220802143529591.png)



4閵嗕焦妞傞梻瀛樺煈閸欐ɑ鍨氭稉鈧稉顏勬硶婢堆呮畱閺佹澘鐡ч敍灞炬Ц閸ョ姳璐熼張鍝勬珤鐞氱幎oot閸滃瘈nlock娴?
- 娑撳秷鍏榰nlock
- 閺冨爼妫块幋鍏呯瑝閼崇禌ownupgrade



5閵嗕焦濮ら柨娆欑窗Failed to load keys from releasekey.x509.pem

```
[  474.218103] I:Update package id: /sideload/package.zip
[  474.405627] E:Failed to read x509 certificate
[  474.615352] E:Failed to load keys from releasekey.x509.pem
[  474.710197] E:Failed to load keys
[  474.930994] I:current maximum temperature: 36000
[  474.931346] I:/sideload/package.zip
```

![image-20220803180106111](Image/image-20220803180106111.png)



閺堫剝宸濇稉濠冩Ц閸楀洨楠囨导姘箵閺嶏繝鐛?system/etc/security/otacerts.zip閺傚洣娆㈡稉瀣畱鐠囦椒鍔熼崪瀹眛apackage闁插矂娼伴惃鍕槈娑旓附妲搁崥锔跨閼锋番鈧?
![image-20220803180210908](Image/image-20220803180210908.png)

![image-20220803180250663](Image/image-20220803180250663.png)

閸氬酣娼伴崣鎴犲箛娑撳秳绔撮懛杈剧礉閸?system/etc/security/otacerts.zip娑撳娼伴惃鍕槈娑旓附妲搁柨娆戞畱閿涘矂娓剁憰浣告躬recovery濡€崇础娑撳獫ush閸掓媽绻栨稉顏嗘窗瑜版洩绱濋悞璺烘倵閸楀洨楠囬敍宀勬付鐟曚椒鎱ㄦ径宄泆g閵?


6閵嗕焦濮ら柨姗產ckage is for product m11 but expected

```
[  415.025342] E:Package is for product m11 but expected 
[  415.062221] E:result: 1 fact.secure_boot_lock : 0  metadataMap.find('ro.action.set_device_lock') 
```

閹偓閻ゆ垶妲哥憴锝夋敚unlock娴滃棗顕遍懛杈剧吹

閺勵垳娈戦妴?




### DLSystemUpdate/update_engine/recovery

1閵嗕胶绱拠鎴炴付閺傛壆娈慏LSystemUpdate閿?
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





2閵嗕焦鍧婇崝鐕痯dateEngine閻╃鍙ч惃鍒amework閻ㄥ嫭甯撮崣锝忕窗

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



婵″倷绗?閵?閿涘苯鍙ч梻鐠糴linux閹存劕濮涢崡鍥╅獓娴滃棎鈧?


3閵嗕焦澧﹀鈧瑂elinux閿涘本濮ら柨娆忣洤娑撳绱?

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



闂団偓鐟曚浇袙闂勩倗娈憇elinux閺夊啴妾烘俊鍌欑瑓閿?
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



4閵嗕線浜ｉ崚鎵儑娴滃奔閲滈梻顕€顣?

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

鐠佹儳顦悮鐜爄sable-verify娴滃棴绱?

闂団偓鐟曚焦澧界悰瀹巇b enable-verity閻掕泛鎮楅柌宥呮儙閸楀啿褰查妴?


閵嗘仴pdate_engine selinux闂傤噣顣介妴?
1閵嗕線鍣搁弬鎷岀獓娑撯偓娑撳绱濋崘鍛枂sd 婵傛垝绨￠敍灞筋樆缂冾喛绻曟稉宥堫攽閵?
閸撳秹娼版禍鏃€娼?avc log瀹歌尙绮℃稉宥呯摠閸?閿涘奔绲炬禒宥囧姧閹躲儱顩ф稉瀣晩鐠囶垽绱?

08-10 11:45:10.452   868   868 I auditd  : type=1400 audit(0.0:25927): avc: denied { dac_read_search } for comm="update_engine" capability=2 scontext=u:r:update_engine:s0 tcontext=u:r:update_engine:s0 tclass=capability permissive=1

dac_read_search

audit2allow娑撯偓娑撳绱?

allow update_engine self:capability dac_read_search;

缂傛牞鐦ч幎銉╂晩閿涘everallow閿涘瞼娅ㄦ惔锔跨閸氬骸濮炴稉濂穉c_override閿涘瞼鎴风紒顓熷Г闁挎瑣鈧?
鐏忔繆鐦惄瀛樺复  dac_override/dac_read_search 閺夊啴妾洪弨鎯х磻閿?


缂傛牞鐦?濞村鐦痯ass閵?
娴ｅ棙妲告潻娆戭潚閺傜懓绱￠幎濡榩date_engine閻ㄥ嫭娼堥梽鎰杹閻ㄥ嫯绻冩禍搴°亣閿涘奔绗夐崚鈺€绨化鑽ょ埠鐎瑰鍙忛敍灞绢劃閺傝纭堕崣顏囧厴娴ｆ粈璐熸径鍥偓澶涚礉闂団偓鐟曚礁顕伴幍鐐纯閸氬牏鎮婇弬瑙勵攳閵?


3閵嗕焦鐓￠惇?閸楁艾顓归敍?
https://blog.csdn.net/Donald_Zhuang/article/details/108786482

dac_override/dac_read_search  閸滃本鏋冩禒绉梬x閺夊啴妾哄Λ鈧弻銉ф祲閸忕绱濈拠瀛樻update_engine濞屸剝婀佺拠璇插絿婢舵牜鐤唖d閺傚洣娆㈤弶鍐閵?
鐠ㄥ奔鎶€濞屸€茬矆娑斿牏鏁ら敍灞芥礈娑撶皫pdate_engine瀹歌尙绮″ǎ璇插鏉╁洣绨dcard 缂佸嫭娼堥梽鎰剁窗



闂勫嘲鍙嗛幀璁充簰娑?rwxrwx---鐎佃壈鍤?閿涘本妫ゅ▔鏄猦mod 777閿涘苯宓嗘担鎸庢暭閹存劕濮涙禍鍡礉鏉╂ɑ妲告径杈Е娴滃棎鈧?
閸氼垰褰傛禍搴ょ箹缁″洦鏋冪粩鐙呯窗

https://blog.csdn.net/shift_wwx/article/details/85633801

娴犳梻绮忛弻銉ф箙 閸欐垹骞噑dcard娑撳娼?閻╊喖缍嶉敍灞界潣娴滃穲verybody鏉╂瑤閲滅紒鍕剁礉閹碘偓娴犮儳浼掗張杞扮閸旑煉绱漞verybody閸旂姳绗傞敍?


```
service update_engine /system/bin/update_engine --logtostderr --logtofile --foreground
    class late_start
    user root
    group root system wakelock inet cache media_rw everybody
    writepid /dev/cpuset/system-background/tasks /dev/blkio/background/tasks
    disabled
```

閹存劕濮涢崡鍥╅獓閵?


閹存劕濮涢崡鍥╅獓閵?
娑撯偓閺冿箓浜ｉ崚鐧瞐c_override/dac_read_search閻╃鍙ч梻顕€顣介敍灞肩瑝鐟曚焦瀵氶張娑氭纯閹恒儲鍧婇崝鐘垫閸氬秴宕熼敍灞炬綀闂勬劘绻冩禍搴°亣閿涘矂娓剁憰浣解偓鍐婵″倷缍嶉弨鐟邦嚠鎼存梹娼堥梽鎰┾偓?
婵″倷缍嶇涵顔款吇update_engine 閹枫儲婀乪verybody閺夊啴妾洪敍?
cat /proc/[pid]/status 

閺屻儳婀呴弰顖氭儊Groups閺堝鎽㈡禍娑欐殶鐎涙绱?9997娴狅綀銆僥verybody



![image-20220913104402763](Image/image-20220913104402763.png)



### 閵嗘劕妯婇崚鍡楀瘶閸掓湹缍旈妴?
1閵嗕胶绱拠鎴滆⒈娑撶尲argetfiles
python out_sys/target/product/mssi_t_64_cn/images/split_build.py --system-dir out_sys/target/product/mssi_t_64_cn/images --vendor-dir out_vnd/target/product/dl36/images --kernel-dir out_vnd/target/product/dl36/images --output-dir out/target/product/dl36 --otapackage --targetfiles
閿涘牅绔存稉鐚籵urce閿涘奔绔存稉鐚糰rget閿?
2閵嗕椒濞囬悽銊ヮ洤娑撳鎳℃禒銈囨晸閹存劕妯婇崚鍡楀瘶閿涘本鏁為幇蹇撳帥閹笛嗩攽Note娑擃厽顒炴?AB update:

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
zip is the new version target package.@Lucas鐠囨洝鐦惇?


鐠佹澘绶辨稉鈧€规俺顩﹂崚鐘绘珟out閻╊喖缍嶇紓鏍槯閿涘苯鎯侀崚娆庣窗閺堝“ash鐎甸€涚瑝娑撳﹦娈戦梻顕€顣介妴?




### 閵嗘劖濯剁憴顤籶date閵?
1閵嗕竸ndroid AB缁崵绮洪崢鐔烘晸閸旂喕鍏?

a. 閼崇晫绱拠鎱淭A閸忋劑鍣洪崠?
b. recovery 閿涘ideload+婢舵牜鐤哠D閸椻€冲磳缁狙勫灇閸?
c. DLSystemUpdate閸楀洨楠囬幋鎰

d. mssi瀵洖鍙嗛惃鍕剰閸愬吀绗呴敍灞芥▕閸掑棗瀵橀崚鏈电稊閿涘苯鑻熼崡鍥╅獓閹存劕濮?(閸愭瑥鍙唚iki)



2閵嗕笍L鐎规艾鍩楅柈銊ュ瀻閻ㄥ嫬宕岀痪?
a. lock/unlock

b. DL 閻㈠灚鐫?0% + 閻╃鍙ч弽锟犵崣DLCheckCompatibilityList+闁挎瑨顕ら惍浣界箲閸?

c. dlaux/last_result.prop娣団剝浼呴崘娆忓弳

d. Enterprise wash reset

ENTERPRISE_RESET

e.閸樺娅庨弮鍫曟？閹磋櫕鐗庢宀嬬礉婵″倹鐏塷ta閸栧懐娈戦弮鍫曟？濮ｆ柨缍嬮崜宥囨畱閺冄嶇礉姒涙顓诲〒鍛存珟enterprise閻ㄥ嫭鏆熼幑?
f. Metadata

g. factoryreset



缁楊兛绨╁▎鈩冣偓鑽ょ波閿?
1閵嗕胶鏁稿Ч鐘崇墡妤犲矉绱橝PK+update_engine+recovery閿?
2閵嗕礁鍚嬬€硅鈧勭墡妤犲瓕LCheckCompatibilityList

3閵嗕礁宕岀痪褍銇戠拹銉╂晩鐠囶垳鐖滄潻鏂挎礀 

4閵嗕龚laux/last_result.prop娣団剝浼呴崘娆忓弳

5閵嗕礁骞撻梽銈囩椽鐠囨垶妞傞梻瀛樺煈閺嶏繝鐛欓敍灞筋洤閺嬫笝ta閸栧懐娈戦弮鍫曟？濮ｆ柨缍嬮崜宥囨畱閺冄嶇礉姒涙顓诲〒鍛存珟enterprise閻ㄥ嫭鏆熼幑?
6閵嗕龚l_action閸滃畳l_extra_action閿涘奔浜掗崣濠勬晸閹存劕顕惔鏃傛晸閹存劗娈憁eta閺佺増宓侀敍灞藉嚒缂佸繐宕岀痪褍鎮楅敍灞炬Ц閸氾箑顨旈弫?
7閵嗕笒nterprise



VF A13 閺€鍓佹抄

GKI閳ユ柡鈧?G



鐞涖儱鍘杦iki閿涙艾妯婇崚鍡楀磳缁狙佲偓涔玜ctory瀹搞儱鍙?



recovery閿?
1閵嗕笍HAS_SDCARD

2閵嗕笍USE_SCAN_KEYS

3閵嗕笍DL_SYSTEM_UPDATE

4閵嗕沟inui

5閵嗕勾ibrecovery_ui

6閵嗕龚l_recovery



閻㈢敻鍣哄Λ鈧ù瀣剁礉sku閺嶏繝鐛欓敍瀹璷ck閸栧拑绱漞xtra action





#### update_engine

        "libdeviceDL_static_system",
        "librecoverydl",
        "librecovery_utils",
        "libotautil",



### 閸忓厖绨琹ock/unlock閵嗕公actoryreset閵嗕躬nterprisereset閵嗕龚l_extra_actions

```
ota閹垫挸瀵橀惃鍕閸婃瑱绱濋弬鏉款杻閺€顖涘瘮閻ㄥ嫬寮弫甯窗
--dl_action
factoryreset     metadata["ro.action.reset"] = "factory";
enterprisereset  metadata["ro.action.reset"] = "enterprise";
lock             metadata["ro.action.set_device_lock"] = "1";
unlock           metadata["ro.action.set_device_lock"] = "0";

--dl_extra_actions

key:value
ro.action.extra.[key]   -->  value   --> OTA metadata
update_engine --> /sys/bus/platform/devices/factory_data/[key] ---> value


閻楄鐣╅幆鍛枌閿涙瓲rpreset閿?
DoFrpReset

闁艾鐖堕幆鍛枌閿?apply_ota_extra_action
閸愭瑥鍙唂actory閺佺増宓?

濮ｆ柨顩ч崘娆欑窗
python [py tool] --dl_action unlock --dl_extra_actions frpreset:1,enable_adb:1

```

濠ф劗鐖滅粻鈧憰浣光偓鑽ょ波閿?
(1)ota_from_target_files.py

閺嶈宓侀悽鐔稿灇ota閸栧懐娈戦崨鎴掓姢閿涘矁袙閺嬫劕顕惔鏃傛畱閸欏倹鏆熼敍灞借嫙閸嬫矮绨℃稉銈勬娴滃绱?

1閵嗕焦甯撮崣妤€寮弫甯礉鐠у嘲顫愰悙?
2閵嗕礁鐨㈤崨鎴掓姢閸欏倹鏆熼弽鍥唶閸︹暜o.action.鐏炵偞鈧嶇礉鐎涙ê鍋嶉崷鈺玹a閸栧懐娈憁eta闁插矂娼?

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



閿?閿?
brillo_update_payload閺勵垰鍩楁担娓沘yload.bin娴犺绱?

閼存碍婀伴崗銉ュ經閿?
```
brillo_update_payload generate [閸欏倹鏆焆 [閸欏倹鏆熼崐绯?
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



鐠囪褰囬崚?-dl_action閿涘矁骞忛崣鏍у煂閸欏倹鏆熼崐纭风礉閻掕泛鎮楅崘宥夊櫢閺傜増妲х亸鍕煂--dl_action="${FLAGS_dl_action}"閸?


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

閺佹潙鎮庨幋鎰波閺嬪嫪缍嬮敍灞藉晸閸忣櫒in閺傚洣娆㈤妴?
update_engine_config.txt



閺堚偓缂佸牆鍏卞ú鑽ゆ畱閺勭棛elta_generator



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



閺堚偓缂佸湏pplyPayload闁俺绻僣onfig閺傚洣娆㈤悽鐔稿灇bin



娑撳娴囨潻娑樺箵閻ㄥ嫭鐗宠箛鍐╂Ц閿涙eltaPerformer

Wirte

ValidateManifest

DLCheckCompatibilityList

SetLockSecureBoot DLApplyExtraActions





#### 濞屸剝婀侀崙鐘遍嚋閸忔娊鏁弬瑙勭《set_lock_system閵嗕弓as_lock_system閵嗕勾ock_system閿?
閳ュ崹ock_system閺勵垰鐣炬稊澶婃躬protobuf闁插矂娼伴惃鍕剁礉set get has閺傝纭堕柈鑺ユЦ閸︺劎绱拠鎴ｇ箖缁嬪鑵戦悽鐔稿灇閿涘瞼鏁撻幋鎰嚒娴犮倕顩ф稉?
protoc --cpp_out=out/   system/update_engine/update_metadata.proto

![閸濆牆鎼遍崫鍦?../../../Share/閸濆牆鎼遍崫?png)



![2022-09-15_10-51](../../../Share/2022-09-15_10-51.png)



X5 extra action缂傛牞鐦ч崨鎴掓姢:

```
export DL_ACTION := unlock ; export DL_EXTRA_ACTIONS := "frpreset:1,bluetooth_type:10086" ; make -j32 otapackage
```



1閵嗕胶鏁稿Ч鐘崇墡妤犲矉绱橝PK+update_engine+recovery閿?
2閵嗕礁鍚嬬€硅鈧勭墡妤犲瓕LCheckCompatibilityList

3閵嗕礁宕岀痪褍銇戠拹銉╂晩鐠囶垳鐖滄潻鏂挎礀 

4閵嗕龚laux/last_result.prop娣団剝浼呴崘娆忓弳

5閵嗕礁骞撻梽銈囩椽鐠囨垶妞傞梻瀛樺煈閺嶏繝鐛欓敍灞筋洤閺嬫笝ta閸栧懐娈戦弮鍫曟？濮ｆ柨缍嬮崜宥囨畱閺冄嶇礉姒涙顓诲〒鍛存珟enterprise閻ㄥ嫭鏆熼幑?
6閵嗕龚l_action閸滃畳l_extra_action閿涘奔浜掗崣濠勬晸閹存劕顕惔鏃傛晸閹存劗娈憁eta閺佺増宓侀敍灞藉嚒缂佸繐宕岀痪褍鎮楅敍灞炬Ц閸氾箑顨旈弫?
7閵嗕笒nterprise





### update:

```
AB閸掑棗灏崚鍥ㄥ床闂傤噣顣介敍灞惧珕缂佹繂宕岀痪褎鏌熷▔鏇熺叀鐠?
閻㈢敻鍣哄Λ鈧ù?
閸忕厧顔愰幀褎顥呴弻顧奓CheckCompatibilityList

閸楀洨楠囨径杈Е闁挎瑨顕ら惍浣界箲閸?
lock unlock

factory reset

enterprise reset

dl_action/dl_extra_action 閸愭瑨濡悙纭呯箷閸︺劏绻樼悰灞艰厬
閸旂喕鍏橀崠鍛Ц閸氾附鐦″▎锟犵崣鐠?
librecoverydl
UE_SIDELOAD

recovery reset闂傤噣顣?
48閹存劕濮涘▽顡籲lock闂傤噣顣?

闂勫秶楠囬弰顖氭儊鐟曚焦绔婚梽銈嗘殶閹诡噯绱靛鍛€樼拋銈忕礉google patch闂傤噣顣?


```





```
sudo apt-get install rename

rename "s/.bp/.bp.bak/" *.bp ; rename "s/.mk/.mk.bak/" *.mk
rename 's/\.bak$//' *.bak
```





![image-20220921152639310](Image/image-20220921152639310.png)



![image-20220921155038940](Image/image-20220921155038940.png)

閻ｅ矂娼版稉濠傜暰娑斿娈戦崘鍛啇閿涘奔鍞惍浣割洤娑撳鈧?
閺堚偓缂佸牊妲搁崥锔藉⒔鐞涘eset閹垮秳缍旈惃鍕煙濞夋洘妲搁敍姝磂tOtaActionValue setActionValue





![image-20220921175809569](Image/image-20220921175809569.png)

downgrade reset閿?
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





閵嗘劖鈷婇悶鍡愨偓?
閹缍嬫稉濠傚彙閻㈢喐鍨氭禍?閸欘垱澧界悰灞奸嚋鎼存梻鏁ら敍?
閸忚渹缍嬫稉鐚寸窗

android娑撹崵閮寸紒鐔跺▏閻劎娈戦惃鍕箛閸旓紕顏瑄pdate_engine

鐎广垺鍩涚粩鐥穚date_engine_client

recovery缁崵绮烘担璺ㄦ暏閻ㄥ増pdate_engine_sideload

host娑撳﹦娈戦崡鍥╅獓閸栧懎浼愰崗绌宔lta_generator閵?


鏉?娑擃亜褰查幍褑顢戞惔鏃傛暏閿涘矂鍎撮崚鍡曠贩鐠ф牔绨?娑擃亪娼ら幀浣哥氨閿涘澆pdate_metadata-protos, libpayload_consumer, libupdate_engine_android, libpayload_generator閿涘鎷?娑擃亜鍙℃禍顐㈢氨閿涘潤ibupdate_engine_client閿涘鈧?


```
update_metadata-protos (STATIC_LIBRARIES)
  --> update_metadata.proto <濞夈劍鍓伴敍姘崇箹闁插本妲?proto閺傚洣娆?

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
  --> binder_bindings/android/os/IUpdateEngine.aidl         <濞夈劍鍓伴敍姘崇箹闁插本妲?aidl閺傚洣娆?
      binder_bindings/android/os/IUpdateEngineCallback.aidl <濞夈劍鍓伴敍姘崇箹闁插本妲?aidl閺傚洣娆?
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
  --> binder_bindings/android/os/IUpdateEngine.aidl         <濞夈劍鍓伴敍姘崇箹闁插本妲?aidl閺傚洣娆?
      binder_bindings/android/os/IUpdateEngineCallback.aidl <濞夈劍鍓伴敍姘崇箹闁插本妲?aidl閺傚洣娆?
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







### 閵嗘€憂terprise閵?
#### 1閵嗕椒楠囬悧?
M10娑撳娴囬獮鍓佺椽鐠?
```
cd vendor/datalogic/dl35/prebuilts/system/espresso
git clone git@blqsrv819.dl.net:DL35-Priv/device/datalogic/Espresso-tools.git tools
cd -
./build/make/enterprise.sh
```



閹风柉绀塭nterprise閸栧懐娈戦懘姘拱

build/make/enterprise2.sh

```
VERSION=V1.0
ENTERPRISE_ESPRESSO=enterprise_espresso

cp out/target/product/dl36/enterprise.img out/target/product/dl36/$ENTERPRISE_ESPRESSO-$VERSION.img
cp out/target/product/dl36/espresso/espresso-packages/enterprise-signed-full.zip enterprise_package_M11_$VERSION.zip
cp out/target/product/dl36/espresso/espresso-packages/enterprise-signed-empty.zip enterprise_package_M11_$VERSION-empty.zip

zip $ENTERPRISE_ESPRESSO-$VERSION.zip -j out/target/product/dl36/$ENTERPRISE_ESPRESSO-$VERSION.img
```



閻㈢喐鍨歟nterprise閸栧懍绗佹稉顏庣窗

ls enterprise_*
enterprise_espresso-V1.0.zip                                  ---------img

enterprise_package_M11_V1.0-empty.zip             ---------ota empty

enterprise_package_M11_V1.0.zip                          ---------ota full



#### 2閵嗕椒鍞惍浣盒╁?
enterprise閺堫剝宸濇稉濠傛皑閺勵垯绔存禍娑欐綀闂勬劖鐦潏鍐ㄣ亣閻ㄥ垷pk閿涘本鐦俊鍌濐唶瑜版樄og閵嗕簚ifi閺夊啴妾虹粵澶涚礉GMS闁焦绁寸拠鏇犲閺堫兛绗夐梿鍡樺灇閿?
![image-20221011171145230](Image/image-20221011171145230.png)

闁俺绻僶ta閸栧懐娈戣ぐ銏犵础閸掔柉绻橀崢鏄忣啎婢?
闂団偓鐟曚胶些濡炲秶娈戦柈銊ュ瀻婢堆嗗毀婵″倷绗呴敍?
閿?閿涘绱拠鎴ｅ壖閺?
build/make/enterprise.sh

![image-20221011171430556](Image/image-20221011171430556.png)

濞夈劍鍓版禒銉ょ瑐閿?
闂団偓鐟曚够ource閻滎垰顣?

闂団偓鐟曚焦鏁兼稉绡竘36

婢跺洦鏁炴稉濠佺閺夆槄绱皔ou need to download Espresso-tools project then run a script



閸ョ姳璐熸潻娆庨嚋濡€虫健閺勵垰宕熼悪顑跨矤git娴犳挸绨辨稉瀣祰閻?


閿?閿涘鐤勬担鎾冲敶鐎?
![image-20221011171617172](Image/image-20221011171617172.png)

娑撳﹪娼伴柇锝勯嚋閺勵垳娲块幒顧﹐py

娑撳娼版潻娆庨嚋閺勵垳娲块幒顧璱t clone娑撳娴囬敍?
git clone git@blqsrv819.dl.net:DL35-Priv/device/datalogic/Espresso-tools.git tools



闁俺绻冪紓鏍槯閹存劕濮涢悽鐔稿灇閸栧拑绱欑紓鏍槯+閹风柉绀夐敍澶涚窗

./build/make/enterprise.sh  ; ./build/make/enterprise2.sh 

![image-20221011171828535](Image/image-20221011171828535.png)



閿?閿涘绁寸拠鏇′刊閸?
a閵嗕礁鐨ta閸栧嵅ush鏉╂稑鍙唖dcard閿涘瞼鍔ч崥搴″磳缁狙勫絹缁€鐑樻￥閺佸牆瀵橀敍灞藉絺閻滄媽顔曟径鍥ф倳鐎涙顕稉宥勭瑐閿涘奔鎱ㄩ弨绛竐atadata

![image-20221011171957963](Image/image-20221011171957963.png)



b閵嗕胶鎴风紒顓＄殶鐠囨洩绱濋幓鎰仛=SYSTEM_VERSION_INVALID

![image-20221011172047443](Image/image-20221011172047443.png)

閸欐垹骞噀nterprise閻ㄥ嫮澧楅張顒€褰跨憰浣告嫲缁崵绮洪張顒€婀撮悧鍫熸拱閻ㄥ嫪绔村Ο鈥茬閺嶅嚖绱濇禍搴㈡Ц闂団偓鐟曚椒鎱ㄩ弨鐟邦洤娑撳绱?

device/datalogic/dl36/datalogic.mk

vendor/datalogic/dl36/prebuilts/system/espresso/enterprise/factory/metadata

vendor/datalogic/dl36/prebuilts/system/espresso/metadata-empty

閺堚偓闁插秷顩﹂惃鍕叏閺€閫涜礋device/datalogic/dl36/datalogic.mk

閻楀牊婀版稉鈧€规俺顩︾€电櫢绱濋崥锕€鍨弮鐘虫櫏閸栧懌鈧?
![image-20221011172226038](Image/image-20221011172226038.png)

閸樼喓鎮婃俊鍌欑瑓閿?
![image-20221011172301000](Image/image-20221011172301000.png)



c閵嗕浇铔嬬€瑰矁绻栨稉顏勬綑閿涘苯寮甸弶銉ょ啊娑撯偓娑擃亝鏌婇惃?
鐠囧顒烽崥宥嗘￥閺佸牞绱濇惔鏇炵湴閹躲儳娈?005閿?
enterprise閸栧懐娈戠粵鎯ф倳閺夈儲绨禍搴℃憿闁插苯鎲块敍?espresso.jar

鐟欙絽甯囬崙鐑樻降閿?
![image-20221011172520052](Image/image-20221011172520052.png)

鏉╂瑤閲渒ey閸滃瞼閮寸紒鐔哥爱閻胶娈戠€靛湱娈戞稉濠傛偋閿?
![image-20221011172622059](Image/image-20221011172622059.png)

娑撱倓閲渒ey閺勵垯绔撮懛瀵告畱閿涘矂鍋呮稊鍧a閸栧懐顒烽崥宥咁嚠娴滃棗鎮ч敍?
鐎佃鐦稉鈧稉濠?1閺勵垰鎯侀崪瀛?0娣囨繃瀵旀稉鈧懛杈剧窗

![image-20221011172852802](Image/image-20221011172852802.png)

鐠囧瓨妲戠粵鎯ф倳閻ㄥ嫭鐥呴柨娆欑礉娑撹桨缍嶉崨顫吹

閺屻儳婀呯粵鎯ф倳閺嶏繝鐛欓惃鍕敩閻緤绱?

![image-20221011180748048](Image/image-20221011180748048.png)

![image-20221011180759977](Image/image-20221011180759977.png)

缁楊兛绔村▎鈩冩Ц閺咁噣鈧氨娈戠粵鎯ф倳閺嶏繝鐛?

婵″倹鐏夋径杈Е閿涘瞼顑囨禍灞绢偧閺勭棜nterprisecerts閻ㄥ嫭鐗庢?


閼板本鍨滄禒鐞?1闁姤鐥呴張濉璶terprisecerts閸栧拑绱濋幍鈧禒銉︾墡妤犲奔绗夋潻鍥风礉閼板10娑旂喐鐥呴張澶涚礉閸欘亝婀丼X5閺堝绱濋惇瀣降閺勵垱鐦潏鍐╂煀閻ㄥ垿eature

build/make/target/product/security/

![image-20221011181138522](Image/image-20221011181138522.png)

![image-20221011181236734](Image/image-20221011181236734.png)



![image-20221011182142669](Image/image-20221011182142669.png)

鏉╂瑤绗侀柈銊ュ瀻缁夌粯顦叉潻鍥у箵閵?


**Note:**

enterprise key閸︽澘娼冮棁鈧憰浣规暭閹存劧绱?

device/datalogic/security/enterprisekey



d閵嗕焦婀版禒銉よ礋瀹歌尙绮￠煪鈺佺暚娴滃棴绱濆▽鈩冨厒閸掓澘寮甸幎銉╂晩娴滃棴绱?

![image-20221012141955318](Image/image-20221012141955318.png)

閹躲儰绨elinux闂傤噣顣介敍?
```
10-12 04:51:14.828 I/auditd  ( 7833): type=1400 audit(0.0:313): avc: denied { create } for comm="ic.systemupdate" name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 04:51:14.828 W/ic.systemupdate( 7833): type=1400 audit(0.0:313): avc: denied { create } for name="factory" scontext=u:r:system_app:s0 tcontext=u:object_r:enterprise_file:s0 tclass=dir permissive=0
10-12 04:51:14.839 I/InputDispatcher( 1124): setInputWindows displayId=0 Window{c03e7b6 u0 NavigationBar0} Window{7e37239 u0 StatusBar} Wait...#0 Window{1583f88 u0 com.datalogic.systemupdate/com.datalogic.systemupdate.UpdateActivity} Window{585eaee u0 com.android.systemui.ImageWallpaper} 

```



鐎瑰本鏆ｉ弮銉ョ箶閿?
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



闂団偓鐟曚焦鍧婇崝鐙呯窗

#============= system_app ==============
allow system_app enterprise_file:dir { create remove_name };
allow system_app enterprise_file:file { create setattr };



device/mediatek/sepolicy/basic/non_plat/

濞ｈ濮瀞elinux鐠囪鍟撻惄顔肩秿閸滃本鏋冩禒鍓佹畱閺夊啴妾洪敍?
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





unlock鐎规矮绠熼敍?
椋?閳ユ竵db root閳?command from the host pc;
椋?閳ユ竵db remount閳?command from the host pc; (conditioned to bootloader unlock)
椋?ro.boot.selinux set to permissive;
椋?ro.secure set to 0;
椋?ro.debuggable set to 1;
椋?ro.allow.mock.location set to 1



娑撹桨缍嶉崡鍥╅獓鐎瑰矉绱濇导姘崇箻閸忣櫢ecovery閿?
缁屽搫瀵橀敍灞藉磳缁狙冪暚娴兼碍浠径宥呭毉閸樺倽顔曠純顔衡偓?
閸忋劌瀵橀敍灞藉磳缁狙冪暚娴兼俺顥奱pk閿涘奔绗夋惔鏃囶嚉娴兼碍浠径宥呭毉閸樺倽顔曠純?
![image-20221013111657474](Image/image-20221013111657474.png)



鏉╂稑鍙嗘禍鍞昬covery閿涘奔绲鹃弰顖涚梾閺堝浠涙禒璁崇秿娴滃鍎忛敍宀勬付鐟曚焦澧滈崝銊╁櫢閸氼垽绱?

閹碘偓娴犮儲妲搁張澶愭６妫版娈戦敍灞剧叀閻绔存稉瀣Ц閸氾附婀乺ecovery閻╃鍙ч惃鍕絹娴溿們鈧?




### 閵嗘€恥plicate notification "need reboot" after reboot from update successful 閵?
闂傤噣顣介敍?
閸楀洨楠囩€瑰矉绱濋幓鎰仛闁插秴鎯庨敍宀€鍔ч崥搴ㄥ櫢閸氼垬鈧?
闁插秴鎯庨崥搴礉閸忓牊妲搁幓鎰仛閳ユ粌宕岀痪褍鐣幋鎰ㄢ偓婵撶礉閻掕泛鎮楃亸鍗炲晙濞嗏€冲毉閻滄壋鈧粓娓剁憰渚€鍣搁崥顖椻偓婵堟畱闁氨鐓￠妴?
![image-20221107163857659](Image/image-20221107163857659.png)



閵嗘劙妫舵０妯哄瀻閺嬫劑鈧?
![2022-11-07_16-43](Image/2022-11-07_16-43.png)



閺勵垰娲滄稉鐑樻暪閸掗绨nPayloadApplicationComplete閻ㄥ嫭甯撮崣锝堢殶閻?
閸愬秴鍨伴崚姘磳缁狙冪暚娴兼俺顫︾拫鍐暏閿涘本褰佺粈娲付鐟曚線鍣搁崥?
onPayloadApplicationComplete



娴ｅ棙妲搁柌宥呮儙閸氬函绱濇禒宥囧姧鐞氼偉鐨熼悽銊ょ啊閵?
鏉╄姤鐗村┃顖涚爱閸欐垹骞囬敍?
onPayloadApplicationComplete閺勭柗pdateEngine.java鐠嬪啰鏁ら惃鍕剁窗

![2022-11-07_16-49](../../../Share/2022-11-07_16-49.png)



onPayloadApplicationComplete閺堚偓缂佸牅绡冮弰顖濐潶update_engine鐠嬪啰鏁ら惃鍕┾偓?
![image-20221107165049518](Image/image-20221107165049518.png)



![image-20221107165134771](Image/image-20221107165134771.png)

CLEANUP_PREVIOUS_UPDATE閺勵垰鏆愰敍?


![image-20221107165250647](Image/image-20221107165250647.png)

CLEANUP_PREVIOUS_UPDATE閺勵垰鏆愰敍?
閸︺劌绱戦張杞颁簰閸氬簼绱扮€电ootControlAndroid,  HardwareAndroid,BinderUpdateEngineAndroidService缁涘娴夐崗鎶藉櫢鐟曚胶琚潻娑滎攽閸掓繂顫愰崠鏍モ偓鍌氬灥婵瀵查弰銊︽珓娑斿鎮楅幍褑顢慍leanupPreviousUpdateAction濞撳懐鎮婇悩鑸碘偓渚婄礉CleanupPreviousUpdateAction闂団偓鐟曚胶鐡態ootcomplete娑斿鎮楅幍宥勭窗閻喐顒滈幍褑顢戦妴?
CleanupPreviousUpdateAction娴兼艾婀猇irtual A/B閻ㄥ嫯顔曟径鍥︾瑐濞撳懘娅庢稉濠冾偧鐏忔繆鐦弴瀛樻煀閻ㄥ墕napshots閵嗗倸顕禍搴ㄦ姜Virtual AB閻ㄥ嫯顔曟径鍥风礉CleanupPreviousUpdateAction鐏忓棛娲块幒銉ㄧ箲閸ョ偑鈧?
婵″倹鐏夐弰鐥竔rtual AB鐠佹儳顦敍宀勬付鐟曚胶鐡憇ys.boot_completed閸婅壈顔曟稉?閿涘奔绡冪亸杈ㄦЦboot complete娑斿鎮楅敍灞惧鏉╂稖顢戝〒鍛存珟韫囶偆鍙庨惃鍕剰閸愮绱濇俊鍌涚亯濞屸剝婀侀崚娆戠搼瀵板懎鑻?s閺屻儴顕楁稉鈧▎掳鈧?


閸欏倽鈧啯鏋冨锝忕窗

https://cloud.tencent.com/developer/article/2011215



閹碘偓娴犮儻绱濇稉瀣╃濮濄儲鈧簼绠炴径鍕倞閿?
1 濞村鐦疿5閻ㄥ嫭鍎忛崘?
2 

a.婵″倹鐏塜5娑旂喎鐡ㄩ崷鈥揕EANUP_PREVIOUS_UPDATE閸斻劋缍旈敍灞芥躬App娑擃厽鏁奸敍?
![image-20221107165721332](Image/image-20221107165721332.png)

![image-20221107165823213](Image/image-20221107165823213.png)

b.婵″倹鐏塜5娑撳秴鐡ㄩ崷鈥揕EANUP_PREVIOUS_UPDATE閸斻劋缍旈敍灞芥躬Framework閺€鐧哥窗





### Enterprise閸楀洨楠囬崥搴㈠絹缁€鍝勩亼鐠愩儵妫舵０?
OTA閸?enterprise閸栧懎宕岀痪褍鎮楅敍灞肩窗閹绘劗銇氶崡鍥╅獓婢惰精瑙﹂惃鍕６妫?
鐞涖劑娼伴崢鐔锋礈閿?
1 last_result.prop 濞屸剝婀丷ESET_TYPE=1鐎涙顔岄敍灞筋嚤閼风鐦戦崚顐＄瑝閸戠儤娼?

2 slot濞屸剝婀侀崚鍥ㄥ床閹存劕濮涢敍灞艰⒈濞嗭繝鍏橀弰鐥廰



闂傤噣顣?婵傚€熜掗崘?
闂傤噣顣?閿涘奔璐熸禒鈧稊鍫熺梾閺堝鍨忛幑銏″灇閸旂噦绱?



閹恒垻鍌ㄦ潻鍥╂畱閹繆鐭鹃敍?
1 metadata鐞氼偅绔婚梽銈勭啊閿涘苯顕遍懛瀛樻￥濞夋洝顕伴崣?metadata/ota閻ㄥ墕tate merge_state缁涘鍞寸€?
2 ota.warm_reset鐏炵偞鈧勭梾閺堝顔曠純顔昏礋1閿涘苯娲滄稉娲劥閸掑棔鍞惍浣筋潶濞夈劑鍣存禍?
3 metadata/ota/snapshot-boot閻ㄥ嫬鍞寸€归€涚瑝鐎电櫢绱濇禒銉よ礋閺勭椀lot閸掑洦宕查惃鍕壌濠?


鐟欙絽鍠呴弬瑙勵攳閿?
1 娑撳秷顔€recovery姒涙顓婚柌宥呮儙

2 鐎电粯澹榚nterprise閸滃畺actoryreset閻ㄥ嫬灏崚顐礉閺夈儴鍤滄禍搴ょ箹閺夆槄绱?

![image-20221118162405508](Image/image-20221118162405508.png)

娑撹桨绮堟稊鍧媙terprisereset闂団偓鐟曚焦浠径宥呭煂old slot閿涚喍璐熸禒鈧稊鍧抋ctory閸欘垯浜掔紒褏鐢婚敍鐔烘箙娴狅絿鐖滈敍?
![image-20221118162547777](Image/image-20221118162547777.png)

allow_forward_merge娴肩姷娈戦柈鑺ユЦture

闁綁妫舵０妯虹箑閻掕泛鍤悳鏉挎躬閿涙瓫ccess(GetForwardMergeIndicatorPath().c_str(), F_OK) == 0)

閸欐垹骞囬弰鐥琫tadata/ota/allow-forward-merge娑撳娼伴惃鍕瀮娴犺绱?

閹靛彞绨℃稉鈧柆宥忕礉濞屸剝婀侀幍鎯у煂閸掓稑缂撻弬鍥︽閻ㄥ嫬婀撮弬?
闁絾妲搁崶鐘辫礋娴犫偓娑斿牞绱甸張澶嬬梾閺堝婀撮弬瑙勫Ω娴犳牕鍨归梽銈勭啊閸涱澁绱?

![image-20221118162841329](Image/image-20221118162841329.png)

鐠嬩椒绱扮拫鍐暏RemoveFileIfExists閹存牞鈧尟emoveAllUpdateState閸涱澁绱?

![image-20221118163241298](Image/image-20221118163241298.png)

閻鐗辩€涙劕绶㈤崓蹇旀Ц閿?
UpdateForwardMergeIndicator

閺囧瓨鏌婃潻娆庨嚋閺傚洣娆㈤崨?


閻掕泛鎮楅惇瀣煂娴滃棜绻栭弶鈽呯窗

![image-20221118163349183](Image/image-20221118163349183.png)

UpdateForwardMergeIndicator婵″倹鐏墂ipe娑撶alse鐏忓彉绱伴崙铏瑰箛娑撳﹪娼伴惃鍕６妫?


闁絼绠為弰顖濈殱鐠嬪啰鏁inishedSnapshotWrites娴滃棴绱濋獮鏈电瑬娴肩姳绨alse閿?
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



閺勭椃pdate閳ユ柡鈧攨nginie閻ㄥ垼ynamic_partition_control_android.cc閺夈儴鐨熼悽銊ょ啊snapshot閵嗕竣pp閻ㄥ嚔inishedSnapshotWrites

閻獛ynamic_partition_control_android.cc娴狅絿鐖滈敍?
![image-20221118163639264](Image/image-20221118163639264.png)

閺勵垰鎯亀ipe閸欐牕鍠呮禍搴㈡閸婃獤owerwash_required閿?
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



閹扮喕顫庣捄婵堫瀲缂佸牏鍋ｇ搾濠冩降鐡掑﹦绮℃禍?
system/update_engine/payload_consumer/postinstall_runner_action.cc

![image-20221118163855009](Image/image-20221118163855009.png)

factoryreset閸欘垯浜掔悰宀嬬礉閹碘偓娴狀櫠owerwash_required=true

娴ｅ棙妲竐nterprisereset娑旂喐妲搁棁鈧憰浣界殶閻劎娈戦敍灞剧梾閺堝鐨熼悽顭掔礉閸欘垰鎷崝鐑囩吹閹跺﹤鍨介弬顓濈瘍閸旂姳绗傞敍?
![image-20221118164008683](Image/image-20221118164008683.png)

闂傤噣顣界憴锝呭枀閵?


鏉╂瑤閲滈梻顕€顣芥稉杞扮矆娑斿牊澧禍鍡涘亝娑斿牅绠欓敍灞惧閸掔増鏌熼崥鎴犳埂閻ㄥ嫬绶㈤柌宥堫洣閿涘瞼澹掗崚顐ｆЦ鏉╂瑧顫掑☉澶婂挤婢舵矮閲滃Ο鈥虫健閻ㄥ嫸绱濋獮鏈电瑬閺冪姵纭舵い鍝勫焺鐠嬪啳鐦惃鍕┾偓?




閵嗘劒璐熸禒鈧稊鍫濈磻閺堣桨绗夐幓鎰仛 Enterprise reset success閵?
閸ョ姳璐熼崷銊ョ磻閺堟椽鍘ょ純顔炬櫕闂堛垹浠犻悾娆忋亰娑斿拑绱漇ystemUpdateService濮濓絽婀弴瀛樻煀閿涘苯顩ч弸婊冩躬鏉╂稑鍙嗗宀勬桨閸氬函绱濆鑼病閸掔娀娅庢禍鍝緇aux/last_result.prop閿涘苯鍨稉宥勭窗閸愬秵顐煎鐟板毉

Enterprise reset success

閹疇顩﹀ù瀣槸閿涘苯鍨棁鈧憰浣告彥闁喕绻橀崗銉︻攽闂堫澁绱濋悞璺烘倵閹靛秳绱伴弰鍓с仛閸戠儤娼甸妴?
```
adb wait-for-device  ; adb root  ; adb_while_do_cmd  "cat dlaux/last_result.prop"
```

![image-20221121113932542](Image/image-20221121113932542.png)



閵嗘€?B slot switch閵?
1118 image (a)

---- > 1118 ota (b)

 ---- > 1118 image (a) (download only)

娑撳秷鍏樺鈧張鎭掆偓鍌氭礈娑撶皧lot=b閵?
fastboot set_active a 

閼宠棄绱戦張鎭掆偓鍌欑稻閺勭椀dcard濞屸剝婀佹稊瀣閻ㄥ嫬鍞寸€?
---- >1118 ota (b)

---- > 1118 image (a) (firmware upgrade)

slot=a

閹存劕濮涘鈧張?



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



閼宠棄绱戦張鎭掆偓鍌欑稻閺勭椀dcard濞屸剝婀佹稊瀣閻ㄥ嫬鍞寸€瑰箍鈧?


閸忓厖绨珼ownload only, Firmware Upgrade, Format all閻ㄥ嫬灏崚顐窗

```
1. SP FlashTool ->firmware upgrade

step1閿涙瓬ackup Nvram bin region

step2閿涙瓲ormat total flash

step3閿涙瓰ownload all

step4閿涙estore Nvram bin region

 

閸欙箑顦婚敍?SP Flashtool->format whole flash閿涙岸娅庢禍鍞抋rtition table娑撳叮MT Pool閸忚精顓?2娑撶寵lock閿涘苯鍙炬担娆忓弿闁劍鎽濋梽?

 
 
```



![mtk](Image/mtk.png)



```
Firmware Upgrade = update + factory reset(userdata+metadata reset) + misc reset
Download only =  update + userdata reset
Format all = update + factory reset + misc reset + other reset(exclude patition table and BMT Pool)
```



```
firmware upgrade娑撳秳绱伴幙顨碫閿涘畺ormat all鐏忓崬鍙忓〒鍛存珟娴滃棴绱漝ownload only閻╃缍嬫禍宸塧ctory reset ,娴ｅ棙妲搁崗璺虹杽鏉╂ü绗夋俊淇ctory reset ,閹诡喗鍨滈惃鍕啊鐟欙絽鐣犻幙锔跨瑝娴滃攲etadata
```



```
misc閸掑棗灏崷?/dev/block/by-name/para娑撳娼伴敍灞惧娑撳娼伴惃鍒磇sc閹存牞鈧嵅ara
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
    int slot = 0;//姒涙顓荤亸杈ㄦЦslot a
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
            slotp->successful_boot = 1; //缁楊兛绔村▎鈥茬瑓鏉炶棄绱戦張杞扮窗鐠佸墽鐤唖uccessful_boot =1,鏉╂瑩鍣烽幋鎴滄粦閸欘垯浜掔€广垹鍩楅崠鏍箯閸欐牗妲搁崥锔绢儑娑撯偓濞嗏€崇磻閺?
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
鐎瑰啯濡竚isc娣団剝浼呴崣鏍у毉閺?缂佹獏ootloader_control,閻掕泛鎮楁潻娆撳櫡闂堛垺婀乻lot娣団剝浼?

```



```
MTK 閹垹顦查崙鍝勫范鐠佸墽鐤嗘导姘闂勵槗etadata閿涘苯娲滄稉杞扮瑝濞撳懘娅庢潻娆忔健閺勵垱妫ゅ▔鏇燁劀绾喚娈戠拋鍧楁６data閻ㄥ嫸绱濋崶鐘辫礋鏉╂瑥娼￠弰鐥渂e閸旂姴鐦戦惃鍕剁礉娴兼艾顕遍懛瀛樻￥濞夋洖绱戦張鎭掆偓?Qcom楠炲啿褰撮崚娆庣瑝娑撯偓閺嶅嚖绱濇稉宥嗙闂勩倓绮涢悞鎯板厴瀵偓閺堟亽鈧繈5娑撳﹥浠径宥呭毉閸樺倽顔曠純顔荤瑝娴兼碍绔婚梽顦揺tadata閵?
```



```
Disscuss with ODM, it can be summary as this:
Download only = update system + reset data patition
Firmware Upgrade = Download only + metadata reset + misc reset

And misc partition restore the slot info, if reset will use the default value(slot a), so select the "Firmware Upgrade" can be boot success.
```





**婵″倷缍嶇拫鍐槸update_engine?**

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

   

   閵嗘€TE閵?
   閸掓艾绱戞慨瀣剁礉adb logcat 濞屸剝婀侀弮銉ョ箶閿涘奔绲鹃弰?data/misc/update_engine_log娑撳娼伴張?
   娑撹桨绮堟稊鍫熺梾閺堝妫╄箛妤嬬吹

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





**婵″倷缍嶇拫鍐槸update_engine?**  V2.0

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



### update_engine鐠嬪啳鐦Ч鍥ㄢ偓?
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



push bin閿?
```adb_root_remount ;   adb push out/target/product/dl36/system/bin/update_engine  data/system/update_engine  ;```



kill old process閿?
```adb shell pidof update_engine  |  xargs -I pid adb shell kill -9 pid ;```



start new bin:

```adb shell "chmod 0777 /data/system/update_engine "; adb  shell system/bin/update_engine_start.sh```



test閿?
```adb_start_ota```





瀵板牆顨岄幀顏嗘畱閸欐垹骞囬敍宀冪箹閺嶉鐝堕悞鏈电瘍鐞涘矉绱?

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



閵嗘€榦w to keep the log of recovery閵?
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



閵嗘劒绱崠鏈濼A閸楀洨楠囬弮鍫曟？闂€璺ㄦ畱闂傤噣顣介妴?
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

  actual param閿?
  ```otapackage="--otapackage --dl_action lock/unlock"```

  After reboot Notification:

  ``` You provided a LOCK/UNLOCK package, please use ADB sideload in Recovery to apply it.```

  

- normal full OTA package閿?
  ```
   ./build.sh dl36 full package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  actual param閿?
  ```otapackage="--otapackage --dl_action factoryreset"```

  After reboot Notification:

  ``` Firmware update success/failed!```

  

- full OTA package+Enterprise Reset閿?
  ```
  ./build.sh dl36 full package [user/userdebug] [aosp/gms] ota-enterprisereset [jobs]
  ```

  actual param閿?
  ```otapackage="--otapackage --dl_action enterprisereset"```

  After reboot Notification:

  ``` Firmware update and enterprise reset success/failed!```

  

- full OTA package+Factory Reset閿?
  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  actual param閿?
  ```otapackage="--otapackage --dl_extra_actions factoryreset:1"```

  After reboot Notification:

  ``` Firmware update and factory reset success/failed!```

  

- OTA package with only Enterprise Reset閿?
  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-enterprisereset [jobs]
  ```

  

  actual param閿?
  ```otapackage="--otapackage --dl_extra_actions enterprisereset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with only Factory Reset閿?
  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factoryreset [jobs]
  ```

  

  actual param閿?
  ```otapackage="--otapackage --dl_extra_actions factoryreset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with only Frp Reset閿?
  ```
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-frpsereset [jobs]
  ```

  

  actual param閿?
  ```otapackage="--otapackage --dl_extra_actions frpsereset:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

- OTA package with extra action閿?
  For example, if you want to modify the bluetooth_type and factory_data_enable_adb in factory data.

  ```
  export FACTORY_DATA=bluetooth_type:1,factory_data_enable_adb:1;
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factorydata [jobs]
  ```

  actual param閿?
  ```otapackage="--otapackage --dl_extra_actions bluetooth_type:1,factory_data_enable_adb:1"```

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```

  

  

- fake OTA package only for testing:

  ```
  export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; 
  ./build.sh dl36 package [user/userdebug] [aosp/gms] ota-factorydata [jobs]
  ```

  actual param閿?
  `````
  otapackage="--otapackage --dl_extra_actions mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`"
  `````

  Upgrade Notification:

  ``` Update failed! No ota update but all extra actions applyed```



### 閵嗘劘鐨熺拠鏄絫a_from_target_files.py閹垛偓瀹秆佲偓?
濮ｅ繑顐肩紓鏍槯閼哄崬绶㈡径姘￥妞よ崵娈戦弮鍫曟？閿涘本绔婚梽顦晆t閻╊喖缍?

```
ag -g ota_from_target_files out*/  |  xargs -I file rm file  ; source_dl36 ;  mmm build/make/tools/releasetools/ ;  export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; ./build.sh dl36 package userdebug aosp ota-factorydata 32 
```

閻劏绻栫粔宥嗘煙濞夋洩绱濋懓灞肩瑬鏉╂ü绗夋稉鈧€规碍婀侀悽顭掔礉韫囧懘銆忛崗銊х椽鐠囨垶澧犻悽鐔告櫏閵?


閵嗘劒绱崠鏍ㄦ煙濞夋洏鈧?
閼存碍婀伴崥搴ㄦ桨閸?-targetfiles

```
	python out_sys/target/product/mssi_t_64_cn/images/split_build.py \
		--system-dir out_sys/target/product/mssi_t_64_cn/images \
		--vendor-dir out_vnd/target/product/$product/images \
		--kernel-dir out_vnd/target/product/$product/images \
		--output-dir out/target/product/$product/ $otapackage \
		--targetfiles
```

绾喕绻氭稉宥勭窗閼奉亜濮╅崚鐘绘珟target file閵?
閸欐垹骞囩紓鏍槯鏉╁洨鈻兼稉顓ㄧ礉鐠嬪啰鏁ta閼存碍婀伴惃鍕嚔閸欍儲妲搁敍?
```
python /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp/releasetools/ota_from_target_files.py -v --block -p /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp out/target/product/dl36/target_files.zip out/target/product/dl36/otapackage.zip 
```

閻╁瓨甯寸拫鍐暏濠ф劗鐖滈懘姘拱閿涘苯鑻熸潻娑樺弳extra action

```
export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; python build/make/tools/releasetools/ota_from_target_files.py  --dl_extra_actions  $FACTORY_DATA   -v --block -p /home/ldeng/code/AOSP/M11_A11/out/target/product/dl36/temp out/target/product/dl36/target_files.zip out/target/product/dl36/otapackage.zip 
```



閵嗘劗绱拠鎲坋st empty閸栧懌鈧?
```
source_dl36 ; export FACTORY_DATA=mini_for_test:1,factory_data_final_test_date_time:"buildVersion-"`date "+%Y%m%d.%H%M%S"`; ./build.sh dl36 package userdebug aosp ota-factorydata 32 
```



















