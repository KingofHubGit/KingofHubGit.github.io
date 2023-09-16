---
layout: post
title: modify patch
categories: Excel
description: some word here
keywords: keyword1, keyword2
---


### 閸忔娊妫村鈧張鍝勬倻鐎?
```
adb shell settings put secure user_setup_complete 1

adb shell settings put global device_provisioned 1
```

```
diff --git a/packages/SettingsProvider/res/values/defaults.xml b/packages/SettingsProvider/res/values/defaults.xml
index 4c0ac8641c2..0fd125d43d0 100644
--- a/packages/SettingsProvider/res/values/defaults.xml
+++ b/packages/SettingsProvider/res/values/defaults.xml
@@ -83,7 +83,7 @@
     <integer name="def_sound_trigger_detection_service_op_timeout" translatable="false">15000</integer>
 
     <bool name="def_lockscreen_disabled">false</bool>
-    <bool name="def_device_provisioned">false</bool>
+    <bool name="def_device_provisioned">ture</bool>
     <integer name="def_dock_audio_media_enabled">1</integer>
 
     <!-- Notifications use ringer volume -->
@@ -143,7 +143,7 @@
     <integer name="def_max_dhcp_retries">9</integer>
 
     <!-- Default for Settings.Secure.USER_SETUP_COMPLETE -->
-    <bool name="def_user_setup_complete">false</bool>
+    <bool name="def_user_setup_complete">true</bool>
 
     <!-- Default for Settings.Global.LOW_BATTERY_SOUND_TIMEOUT.
          0 means no timeout; battery sounds will always play

lucas@DLCNRDBS03:~/AOSP/Memor11_A11/vendor/mediatek/proprietary/packages/apps/SettingsProvider$ git diff . 
diff --git a/res/values/defaults.xml b/res/values/defaults.xml
index d882eda..95c98e2 100644
--- a/res/values/defaults.xml
+++ b/res/values/defaults.xml
@@ -84,7 +84,7 @@
     <integer name="def_sound_trigger_detection_service_op_timeout" translatable="false">15000</integer>
 
     <bool name="def_lockscreen_disabled">false</bool>
-    <bool name="def_device_provisioned">false</bool>
+    <bool name="def_device_provisionedtruee</bool>
     <integer name="def_dock_audio_media_enabled">1</integer>
 
     <!-- Notifications use ringer volume -->
@@ -144,7 +144,7 @@
     <integer name="def_max_dhcp_retries">9</integer>
 
     <!-- Default for Settings.Secure.USER_SETUP_COMPLETE -->
-    <bool name="def_user_setup_complete">false</bool>
+    <bool name="def_user_setup_complete">true</bool>
 
     <!-- Default for Settings.Global.LOW_BATTERY_SOUND_TIMEOUT.
          0 means no timeout; battery sounds will always play

```







### usb debug姒涙顓诲鈧崥?
```shell
diff --git a/core/main.mk b/core/main.mk
index c8ffe2d8e..05f8fdcce 100644
--- a/core/main.mk
+++ b/core/main.mk
@@ -160,7 +160,7 @@ endif
 include $(BUILD_SYSTEM)/definitions.mk
 
 # Bring in dex_preopt.mk
-include $(BUILD_SYSTEM)/dex_preopt.mk
+#include $(BUILD_SYSTEM)/dex_preopt.mk
 
 ifneq ($(filter user userdebug eng,$(MAKECMDGOALS)),)
 $(info ***************************************************************)
@@ -264,11 +264,11 @@ enable_target_debugging := true
 tags_to_install :=
 ifneq (,$(user_variant))
   # Target is secure in user builds.
-  ADDITIONAL_DEFAULT_PROPERTIES += ro.secure=1
+  ADDITIONAL_DEFAULT_PROPERTIES += ro.secure=0
   ADDITIONAL_DEFAULT_PROPERTIES += security.perf_harden=1
 
   ifeq ($(user_variant),user)
-    ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
+    ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=0
   endif
 
   ifeq ($(user_variant),userdebug)
@@ -304,7 +304,7 @@ ifeq (true,$(strip $(enable_target_debugging)))
   ADDITIONAL_BUILD_PROPERTIES += dalvik.vm.lockprof.threshold=500
 else # !enable_target_debugging
   # Target is less debuggable and adbd is off by default
-  ADDITIONAL_DEFAULT_PROPERTIES += ro.debuggable=0
+  ADDITIONAL_DEFAULT_PROPERTIES += ro.debuggable=1
 endif # !enable_target_debugging

```



### 瀵偓閸欐垼鈧懏膩瀵繘绮拋銈呯磻閸?
```
adb shell settings put global  development_settings_enabled  1
```



```java
diff --git a/packages/SettingsLib/src/com/android/settingslib/development/DevelopmentSettingsEnabler.java b/packages/SettingsLib/src/com/android/settingslib/development/DevelopmentSettingsEnabler.java
index b191f888aa1..43c1e2e67c4 100644
--- a/packages/SettingsLib/src/com/android/settingslib/development/DevelopmentSettingsEnabler.java
+++ b/packages/SettingsLib/src/com/android/settingslib/development/DevelopmentSettingsEnabler.java
@@ -43,7 +43,7 @@ public class DevelopmentSettingsEnabler {
         final UserManager um = (UserManager) context.getSystemService(Context.USER_SERVICE);
         final boolean settingEnabled = Settings.Global.getInt(context.getContentResolver(),
                 Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
-                Build.TYPE.equals("eng") ? 1 : 0) != 0;
+                1) != 0;
         final boolean hasRestriction = um.hasUserRestriction(
                 UserManager.DISALLOW_DEBUGGING_FEATURES);
         final boolean isAdmin = um.isAdminUser();

```



### pre dex 閸忔娊妫?

```shell
diff --git a/core/board_config.mk b/core/board_config.mk
index 86162b6f3..d8e72c3a4 100644
--- a/core/board_config.mk
+++ b/core/board_config.mk
@@ -104,9 +104,10 @@ _board_strip_readonly_list += $(_build_broken_var_list) \
   BUILD_BROKEN_NINJA_USES_ENV_VARS
 
 # Conditional to building on linux, as dex2oat currently does not work on darwin.
-ifeq ($(HOST_OS),linux)
-  WITH_DEXPREOPT := true
-endif
+#ifeq ($(HOST_OS),linux)
+#  WITH_DEXPREOPT := true
+#endif
+WITH_DEXPREOPT := false
 
 # ###############################################################
 # Broken build defaults
diff --git a/core/dex_preopt_config.mk b/core/dex_preopt_config.mk
index ccf53f522..2b281820c 100644
--- a/core/dex_preopt_config.mk
+++ b/core/dex_preopt_config.mk
@@ -19,7 +19,7 @@ ifeq ($(HOST_OS),linux)
   ifeq (eng,$(TARGET_BUILD_VARIANT))
     # For an eng build only pre-opt the boot image and system server. This gives reasonable performance
     # and still allows a simple workflow: building in frameworks/base and syncing.
-    WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY ?= true
+    WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY ?= false
   endif
   # Add mini-debug-info to the boot classpath unless explicitly asked not to.
   ifneq (false,$(WITH_DEXPREOPT_DEBUG_INFO))
@@ -28,13 +28,13 @@ ifeq ($(HOST_OS),linux)
 
   # Non eng linux builds must have preopt enabled so that system server doesn't run as interpreter
   # only. b/74209329
-  ifeq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
-    ifneq (true,$(WITH_DEXPREOPT))
-      ifneq (true,$(WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY))
-        $(call pretty-error, DEXPREOPT must be enabled for user and userdebug builds)
-      endif
-    endif
-  endif
+  #ifeq (,$(filter eng, $(TARGET_BUILD_VARIANT)))
+  #  ifneq (true,$(WITH_DEXPREOPT))
+  #    ifneq (true,$(WITH_DEXPREOPT_BOOT_IMG_AND_SYSTEM_SERVER_ONLY))
+  #      $(call pretty-error, DEXPREOPT must be enabled for user and userdebug builds)
+  #    endif
+  #  endif
+  #endif
 endif
 
 # Use the first preloaded-classes file in PRODUCT_COPY_FILES.
diff --git a/core/main.mk b/core/main.mk
index d877ec10d..80e8c152d 100644
--- a/core/main.mk
+++ b/core/main.mk
@@ -159,7 +159,7 @@ endif
 include $(BUILD_SYSTEM)/definitions.mk
 
 # Bring in dex_preopt.mk
-include $(BUILD_SYSTEM)/dex_preopt.mk
+#include $(BUILD_SYSTEM)/dex_preopt.mk
 
 ifneq ($(filter user userdebug eng,$(MAKECMDGOALS)),)
 $(info ***************************************************************)

```



### root姒涙顓诲鈧崥?


### selinux閸忔娊妫?

```
diff --git a/alps/system/core/init/selinux.cpp b/alps/system/core/init/selinux.cpp
index ce8348e..1b87d60 100644
--- a/alps/system/core/init/selinux.cpp
+++ b/alps/system/core/init/selinux.cpp
@@ -104,6 +104,8 @@ EnforcingStatus StatusFromCmdline() {
 }
 
 bool IsEnforcing() {
+       return false;
+       
     if (ALLOW_PERMISSIVE_SELINUX) {
         return StatusFromCmdline() == SELINUX_ENFORCING;
     }
     
```



### 閸忔娊妫碊M Verity

娑撯偓閵嗕礁鍙ч梻鐠侻 Verity閿?
閸?alps/vendor/mediatek/proprietary/bootable/bootloader/lk/platform/$(PLATFORM)/rules.mk 娑?
鐏忓棴绱?

    ifeq ($(MTK_DM_VERITY_OFF),yes)
        DEFINES += MTK_DM_VERITY_OFF
    endif

閺€閫涜礋瀵搫鍩楃€规矮绠?MTK_DM_VERITY_OFF閿?
        DEFINES += MTK_DM_VERITY_OFF

娑旂喎褰叉禒銉︽暭閹存劧绱濇禒鍖榚bug閻楀牊婀伴幍宥呯暰娑斿TK_DM_VERITY_OFF閿?
ifeq ($(strip $(TARGET_BUILD_VARIANT)),user)
    ifeq ($(MTK_DM_VERITY_OFF),yes)
        DEFINES += MTK_DM_VERITY_OFF
    endif
else
    DEFINES += MTK_DM_VERITY_OFF
endif

娣囶喗鏁奸崥宸杄build閿涘奔绱伴崣鎴犲箛閸︺劌绱戦張绡杘go閻ｅ矂娼伴幓鎰仛閿涙瓛our device has been unlocked and can't be trusted

鐠囧瓨妲戝鑼病娣囶喗鏁奸幋鎰娴滃棎鈧?
娴ｅ棙妲搁惄顔煎鏉╂ü绗夐懗鑺ヮ劀鐢瓕鐨熺拠鏇礉閹存垳婊戞导姘絺閻滀即鈧俺绻?adb push閺傚洣娆㈤崚鐨妝stem閸掑棗灏稊瀣倵娑撯偓閺冿箓鍣搁崥顖ょ礉push閻ㄥ嫭鏋冩禒鏈电窗鐞氼偉鍤滈崝銊︿划婢?

閺勵垰娲滄稉鍝勯挬閸欐壆娈憇ecure boot閺堝搫鍩楅敍灞筋嚠system閸掑棗灏張澶婂晸娣囨繃濮㈤敍灞筋嚤閼峰瓨妫ゅ▔鏇烆嚠system鏉╂稖顢戦崘娆忓弳閿涘苯褰ч棁鈧憰浣哥殺鐠囥儱濮涢懗钘夊彠閹哄宓嗛崣顖樷偓?閳ユ柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧?閻楀牊娼堟竟鐗堟閿涙碍婀伴弬鍥﹁礋CSDN閸楁矮瀵岄妴瀹巑linsan閵嗗秶娈戦崢鐔峰灡閺傚洨鐝烽敍宀勪紥瀵扮嫝C 4.0 BY-SA閻楀牊娼堥崡蹇氼唴閿涘矁娴嗘潪鍊燁嚞闂勫嫪绗傞崢鐔告瀮閸戝搫顦╅柧鐐复閸欏﹥婀版竟鐗堟閵?閸樼喐鏋冮柧鐐复閿涙ttps://blog.csdn.net/amlinsan/article/details/121038991



```
diff --git a/platform/mt6765/rules.mk b/platform/mt6765/rules.mk
index c209e18e..c98ca19c 100644
--- a/platform/mt6765/rules.mk
+++ b/platform/mt6765/rules.mk
@@ -522,8 +522,15 @@ LINKER_SCRIPT += $(BUILDDIR)/system-onesegment.ld
 MTK_AEE_PLATFORM_DEBUG_SUPPORT := yes
 DEFINES += MTK_AEE_PLATFORM_DEBUG_SUPPORT
 
-ifeq ($(MTK_DM_VERITY_OFF),yes)
-DEFINES += MTK_DM_VERITY_OFF
+#ifeq ($(MTK_DM_VERITY_OFF),yes)
+#DEFINES += MTK_DM_VERITY_OFF
+#endif
+ifeq ($(strip $(TARGET_BUILD_VARIANT)),user)
+    ifeq ($(MTK_DM_VERITY_OFF),yes)
+        DEFINES += MTK_DM_VERITY_OFF
+    endif
+else
+    DEFINES += MTK_DM_VERITY_OFF
 endif
 
 MTK_ENABLE_MPU_HAL_SUPPORT := yes

```



### 閸忔娊妫?*secure boot** 

閻楃懓绶涢敍?
push娴滃棔绗㈢憲鍖＄礉闁插秴鎯庢导姘划婢跺秲鈧?


閸?alps/vendor/mediatek/proprietary/bootable/bootloader/preloader/Makefile 娑?
鐏忓棴绱?

    @echo '#'define CUSTOM_SUSBDL_CFG $(MTK_SEC_USBDL) >> $@
    @echo '#'define CUSTOM_SBOOT_CFG $(MTK_SEC_BOOT) >> $@

閺€閫涜礋閿?
    @echo '#'define CUSTOM_SUSBDL_CFG ATTR_SUSBDL_DISABLE >> $@
    @echo '#'define CUSTOM_SBOOT_CFG ATTR_SBOOT_DISABLE >> $@

娑旂喎褰叉禒銉ュ涧闁藉牆顕甦ebug閻楀牊婀版潻娑滎攽娣囶喗鏁奸敍?
ifeq ($(TARGET_BUILD_VARIANT), user)
    @echo '#'define CUSTOM_SUSBDL_CFG $(MTK_SEC_USBDL) >> $@
    @echo '#'define CUSTOM_SBOOT_CFG $(MTK_SEC_BOOT) >> $@
else
    @echo '#'define CUSTOM_SUSBDL_CFG ATTR_SUSBDL_DISABLE >> $@
    @echo '#'define CUSTOM_SBOOT_CFG ATTR_SBOOT_DISABLE >> $@
endif
閳ユ柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧柡鈧?閻楀牊娼堟竟鐗堟閿涙碍婀伴弬鍥﹁礋CSDN閸楁矮瀵岄妴瀹巑linsan閵嗗秶娈戦崢鐔峰灡閺傚洨鐝烽敍宀勪紥瀵扮嫝C 4.0 BY-SA閻楀牊娼堥崡蹇氼唴閿涘矁娴嗘潪鍊燁嚞闂勫嫪绗傞崢鐔告瀮閸戝搫顦╅柧鐐复閸欏﹥婀版竟鐗堟閵?閸樼喐鏋冮柧鐐复閿涙ttps://blog.csdn.net/amlinsan/article/details/121038991



```
diff --git a/Makefile b/Makefile
index 2f0030e..ee33eb2 100644
--- a/Makefile
+++ b/Makefile
@@ -566,8 +566,10 @@ $(PRELOADER_OUT)/inc/proj_cfg.h: $(MTK_PATH_PLATFORM)/default.mak $(MTK_PATH_CUS
 $(PRELOADER_OUT)/inc/proj_cfg.h: $(ALL_DEPENDENCY_FILE)
        @mkdir -p $(dir $@)
        @echo // Auto generated. Import ProjectConfig.mk > $@
-       @echo '#'define CUSTOM_SUSBDL_CFG $(MTK_SEC_USBDL) >> $@
-       @echo '#'define CUSTOM_SBOOT_CFG $(MTK_SEC_BOOT) >> $@
+       #@echo '#'define CUSTOM_SUSBDL_CFG $(MTK_SEC_USBDL) >> $@
+       #@echo '#'define CUSTOM_SBOOT_CFG $(MTK_SEC_BOOT) >> $@
+       @echo '#'define CUSTOM_SUSBDL_CFG ATTR_SUSBDL_DISABLE >> $@
+       @echo '#'define CUSTOM_SBOOT_CFG ATTR_SBOOT_DISABLE >> $@
        @echo '#'define MTK_SEC_MODEM_AUTH $(MTK_SEC_MODEM_AUTH) >> $@
 ifdef MTK_SEC_SECRO_AC_SUPPORT
        @echo '#'define MTK_SEC_SECRO_AC_SUPPORT $(MTK_SEC_SECRO_AC_SUPPORT) >> $@

```



### 閸忔娊妫磖ecovery闁插秴鎯?

```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11/bootable/recovery$ git diff recovery_main.cpp 
diff --git a/recovery_main.cpp b/recovery_main.cpp
index 844815bf..ca6d46bf 100644
--- a/recovery_main.cpp
+++ b/recovery_main.cpp
@@ -577,17 +577,17 @@ int main(int argc, char** argv) {
 
       case Device::REBOOT:
         ui->Print("Rebooting...\n");
-        Reboot("userrequested,recovery");
+        //Reboot("userrequested,recovery");
         break;
 
       case Device::REBOOT_FROM_FASTBOOT:
         ui->Print("Rebooting...\n");
-        Reboot("userrequested,fastboot");
+        //Reboot("userrequested,fastboot");
         break;
 
       default:
         ui->Print("Rebooting...\n");
-        Reboot("unknown" + std::to_string(ret));
+        //Reboot("unknown" + std::to_string(ret));
         break;
     }
   }

```



### OEM unlock閺冪娀娓舵潏鎾冲弳鐎靛棛鐖?

```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11/frameworks/base$ git diff services/core/java/com/android/server/PersistentDataBlockService.java 
diff --git a/services/core/java/com/android/server/PersistentDataBlockService.java b/services/core/java/com/android/server/PersistentDataBlockService.java
index 00d8b0f1bed..b3934b1c8aa 100644
--- a/services/core/java/com/android/server/PersistentDataBlockService.java
+++ b/services/core/java/com/android/server/PersistentDataBlockService.java
@@ -564,14 +564,15 @@ public class PersistentDataBlockService extends SystemService {
                 return;
             }
 
-            enforceOemUnlockWritePermission();
+ /*           enforceOemUnlockWritePermission();
             enforceIsAdmin();
 
             if (enabled) {
                 // Do not allow oem unlock to be enabled if it's disallowed by a user restriction.
                 enforceUserRestriction(UserManager.DISALLOW_OEM_UNLOCK);
                 enforceUserRestriction(UserManager.DISALLOW_FACTORY_RESET);
-            }
+            }*/
+            Slog.e(TAG, "Lucas~~~~~~~~~~~~~~~~~~~~setOemUnlockEnabled=" + enabled);
             synchronized (mLock) {
                 doSetOemUnlockEnabledLocked(enabled);
                 computeAndWriteDigestLocked();

```



```
alias unlock_system='adb shell "getprop sys.oem_unlock_allowed" ; sleep 2; adb shell "service call persistent_data_block 6 i32 1" ; sleep 3; adb shell "getprop sys.oem_unlock_allowed"  ; sleep 2 ;  adb reboot bootloader  ; sleep 10 ;fastboot flashing unlock ;   sleep 60 ;fastboot reboot '
```







### 瀵偓閺堣桨绗夐崚鐘绘珟last_result閺傚洣娆?

```
ldeng@dotorom:~/code/AOSP/Common_Code/DLSystemUpdate$ git diff  app/src/main/java/com/datalogic/systemupdate/SystemUpgradeService.java
diff --git a/app/src/main/java/com/datalogic/systemupdate/SystemUpgradeService.java b/app/src/main/java/com/datalogic/systemupdate/SystemUpgradeService.java
index f3c2dab..d9d6f00 100644
--- a/app/src/main/java/com/datalogic/systemupdate/SystemUpgradeService.java
+++ b/app/src/main/java/com/datalogic/systemupdate/SystemUpgradeService.java
@@ -156,11 +156,13 @@ public class SystemUpgradeService extends Service {
 
     @Override
     public int onStartCommand(Intent intent, int flags, int startId) {

         mCtx = getApplicationContext();
         int action = 0;
         String mFile = null;

         mApplicationData = (ApplicationData) mCtx;
 
         if (intent != null) {
@@ -470,14 +472,14 @@ public class SystemUpgradeService extends Service {
         String errorMessage;
 
         //Check if the last update has been completed correctly.
-        mRecoveryToAndroid = new RecoveryToAndroid(mCtx, updateResultFilePath, true);
+        mRecoveryToAndroid = new RecoveryToAndroid(mCtx, updateResultFilePath, false);
         if(!mRecoveryToAndroid.isValidTxtFormat())
             return;
         resultCode   = mRecoveryToAndroid.getIntentErrorCode();
         updateType   = mRecoveryToAndroid.getIntentUpdateType();
         errorMessage = mRecoveryToAndroid.getErrorMessage();

@@ -637,12 +643,13 @@ public class SystemUpgradeService extends Service {
                 mBuilder.setContentIntent(null);
 
                 String partitionsSuffix = SystemProperties.get("ro.boot.slot_suffix");

 
                 Intent progressIntent = new Intent(SystemUpgradeUtils.APPLY_UPDATE_FINISH);
                 mContext.sendBroadcast(progressIntent);
             }
             else {

                 String notificationText = "Update failed! ";
                 int DLErrorCode = getErrorCode(updateEngine);
                 switch (DLErrorCode){
@@ -695,16 +702,17 @@ public class SystemUpgradeService extends Service {
                         notificationText += getString(R.string.install_error_default);
                         break;
                 }
                 mBuilder.setContentText(notificationText)
                         .setProgress(0, 0, false).setAutoCancel(true);
                 notificationManager.notify(NOTIFICATION_ID, mBuilder.build());
 
-                File resultFile = new File(updateResultFilePath);
+                /*File resultFile = new File(updateResultFilePath);
                 if(resultFile.exists()) {
                     Log.d(TAG, "Found update results error before rebooting... Erasing them...");
                     resultFile.delete();
-                }
+                }*/
+                Log.d(TAG, "do not Erasing them...");
 
                 Intent progressIntent = new Intent(SystemUpgradeUtils.APPLY_UPDATE_FAILED);
                 progressIntent.putExtra(SystemUpgradeUtils.ApplyUpdateErrorIntent.ExtraErrorCode,DLErrorCode);

```



### 閹绘劙鐝瓵B閸楀洨楠嘜TA閻ㄥ嫰鈧喎瀹?

```
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



### 姒涙顓诲鈧崥鐥慸b閸滃本宸块弶鍍b

```
diff --git a/packages/SystemUI/src/com/android/systemui/usb/UsbDebuggingActivity.java b/packages/SystemUI/src/com/android/systemui/usb/UsbDebuggingActivity.java
index 7561af77029..f60e8f242fd 100644
--- a/packages/SystemUI/src/com/android/systemui/usb/UsbDebuggingActivity.java
+++ b/packages/SystemUI/src/com/android/systemui/usb/UsbDebuggingActivity.java
@@ -98,6 +98,16 @@ public class UsbDebuggingActivity extends AlertActivity
         window.setCloseOnTouchOutside(false);
 
         setupAlert();
+
+        try{
+                IBinder b_adb = ServiceManager.getService(ADB_SERVICE);
+                IAdbManager adbservice = IAdbManager.Stub.asInterface(b_adb);
+                adbservice.allowDebugging(true, mKey);
+                finish();
+        }catch (Exception e) {
+                Log.e(TAG, "Unable to notify Usb service", e);
+        }
+
     }
 
     @Override
diff --git a/services/core/java/com/android/server/adb/AdbService.java b/services/core/java/com/android/server/adb/AdbService.java
index 5b16daa5e83..c61991ab366 100644
--- a/services/core/java/com/android/server/adb/AdbService.java
+++ b/services/core/java/com/android/server/adb/AdbService.java
@@ -258,7 +258,7 @@ public class AdbService extends IAdbManager.Stub {
         // make sure the ADB_ENABLED setting value matches the current state
         try {
             Settings.Global.putInt(mContentResolver,
-                    Settings.Global.ADB_ENABLED, mIsAdbUsbEnabled ? 1 : 0);
+                    Settings.Global.ADB_ENABLED, mIsAdbUsbEnabled ? 1 : 1);
             Settings.Global.putInt(mContentResolver,
                     Settings.Global.ADB_WIFI_ENABLED, mIsAdbWifiEnabled ? 1 : 0);
         } catch (SecurityException e) {

```



### UNSAFE_DISABLE_HIDDENAPI

```
project build/soong/
diff --git a/java/hiddenapi_singleton.go b/java/hiddenapi_singleton.go
index 95dd0bb0..7c30feec 100644
--- a/java/hiddenapi_singleton.go
+++ b/java/hiddenapi_singleton.go
@@ -60,6 +60,7 @@ type hiddenAPISingleton struct {
 // hiddenAPI singleton rules
 func (h *hiddenAPISingleton) GenerateBuildActions(ctx android.SingletonContext) {
        // Don't run any hiddenapi rules if UNSAFE_DISABLE_HIDDENAPI_FLAGS=true
+       // Lucas: export UNSAFE_DISABLE_HIDDENAPI_FLAGS=true && make -j32 Settings
        if ctx.Config().IsEnvTrue("UNSAFE_DISABLE_HIDDENAPI_FLAGS") {
                return
        }

```

### 閹垫挸宓冪敮鍝ユ暏閸棙鐖?

```
ldeng@dotorom:~/code/AOSP/M11_A11/frameworks/base$ git diff core/java/android/os/SystemProperties.java   core/java/android/provider/Settings.java 
diff --git a/core/java/android/os/SystemProperties.java b/core/java/android/os/SystemProperties.java
index c5e5cc40d54..6813846f6a7 100644
--- a/core/java/android/os/SystemProperties.java
+++ b/core/java/android/os/SystemProperties.java
@@ -96,6 +96,13 @@ public class SystemProperties {
         }
     }
 
+    private static void printCallTrace(String key) {
+        if (key != null && key.startsWith("ro.build.id")) {
+            Log.d(TAG, "lucas-read ystem property '" + key + "'",
+                    new Exception());
+        }
+    }
+
     // The one-argument version of native_get used to be a regular native function. Nowadays,
     // we use the two-argument form of native_get all the time, but we can't just delete the
     // one-argument overload: apps use it via reflection, as the UnsupportedAppUsage annotation
@@ -149,6 +156,7 @@ public class SystemProperties {
     @TestApi
     public static String get(@NonNull String key) {
         if (TRACK_KEY_ACCESS) onKeyAccess(key);
+        printCallTrace(key);
         return native_get(key);
     }
 
@@ -166,6 +174,7 @@ public class SystemProperties {
     @TestApi
     public static String get(@NonNull String key, @Nullable String def) {
         if (TRACK_KEY_ACCESS) onKeyAccess(key);
+        printCallTrace(key);
         return native_get(key, def);
     }
 
diff --git a/core/java/android/provider/Settings.java b/core/java/android/provider/Settings.java
index 7414bde8bb2..432eae54e40 100755
--- a/core/java/android/provider/Settings.java
+++ b/core/java/android/provider/Settings.java
@@ -2652,6 +2652,9 @@ public final class Settings {
         public boolean putStringForUser(ContentResolver cr, String name, String value,
                 String tag, boolean makeDefault, final int userHandle,
                 boolean overrideableByRestore) {
+            Exception print_trace = new Exception("lucas putStringForUser pkgname=" + cr.getPackageName() + ",name="+ name +", value=" + value +", tag=" + tag);
+            print_trace.printStackTrace();
+
             try {
                 Bundle arg = new Bundle();
                 arg.putString(Settings.NameValueTable.VALUE, value);
diff --git a/core/java/android/widget/Toast.java b/core/java/android/widget/Toast.java
index b35eb065e3f..8dd5d1e557d 100644
--- a/core/java/android/widget/Toast.java
+++ b/core/java/android/widget/Toast.java
@@ -477,6 +477,9 @@ public class Toast {
      *
      */
     public static Toast makeText(Context context, CharSequence text, @Duration int duration) {
+        // Lucas
+        Log.v(TAG, "Lucas Toast text :" + text  + ", duration=" + duration);
+
         return makeText(context, null, text, duration);
     }
 
@@ -487,7 +490,15 @@ public class Toast {
      * @hide
      */
     public static Toast makeText(@NonNull Context context, @Nullable Looper looper,
+
             @NonNull CharSequence text, @Duration int duration) {
+        android.util.Log.d("Lucas","--------------------------------");
+        StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
+        for (int i = 0; i < stackTraceElements.length; i++) {
+            android.util.Log.d("Lucas","testStackTraceElements = " + stackTraceElements[i]);
+        }
+        android.util.Log.d("Lucas","--------------------------------");
+
         if (Compatibility.isChangeEnabled(CHANGE_TEXT_TOASTS_IN_THE_SYSTEM)) {
             Toast result = new Toast(context, looper);
             result.mText = text;

```









