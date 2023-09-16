### 版本命名规则

1.02.08.20220620

```
[第几个大版本].[准备发布第几个版本].[编译的第几个版本].[编译日期年月日]
```

BUILD FOR: MemorK Android 9 PRE_MR2

```
[项目名][Android大版本][版本类型_MRx]
LR：发布版本
MR：维护版本
```



### 如何修改编译版本号？

```
$ cat device/mobydata/memor_k/mobydata.mk
CUSTOM_TIMESTAMP ?= $(shell date +%s)
MD_BUILD_NUMBER := 1.02.08.$(shell date +%Y%m%d -d @$(CUSTOM_TIMESTAMP))

```



### 如何获取user版本的时间戳？

```
Download memor_k-build.prop-user-xxx.zip at first, unzip it you can find build.prop, 1655694606 is timestamp for this build, each build has different timestamp.
$ cat build.prop | grep fingerprint
# Do not try to parse description, fingerprint, or thumbprint
ro.build.fingerprint=Datalogic/memor_k_ww/memor_k:9/1.02.08.20220620/1655694606:user/release-
```



### Ubuntu下启动Flash Tool

```
http://wiki.mobile.dl.net/mediawiki/index.php/DL-35#Setting_up_SP_Flash_tool
https://androzoom.com/sp-flash-tool/#Using_SP_Flash_Tool_On_Linux

1、安装libmtp9代替libmtp
sudo apt-get install libusb-dev libmtp9 libmtp-runtime

2、在Ubuntu 20上面有很个坑，缺少这个libpng12：

Unable to install new version of '/lib/x86_64-linux-gnu/libpng12.so.0': No such file or directory

【解决办法】
https://askubuntu.com/questions/978294/how-to-fix-libpng12-so-0-cannot-open-shared-object-file-no-such-file-or-direc
https://www.linuxuprising.com/2018/05/fix-libpng12-0-missing-in-ubuntu-1804.html

3、刷机驱动显示错误：
STATUS_ERR(-1073676287)

由于USB驱动没装好导致的，参考：
https://blog.csdn.net/Suviseop/article/details/114126727

第一步：

sudo gedit /etc/udev/rules.d/53-android.rules

添加：
SUBSYSTEM=="usb", SYSFS{idVendor}=="0e8d", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}="0e8d", ATTR{idProduct}="20ff", SYMLINK+="android_adb"

第二步：

sudo gedit /etc/udev/rules.d/53-MTKinc.rules

添加：
SUBSYSTEM=="usb", SYSFS{idVendor}=="0e8d", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}="0e8d", ATTR{idProduct}="20ff", SYMLINK+="android_adb"
KERNEL=="ttyACM*", MODE="0666"

注意：idVendor  idProduct 通过命令lsusb可以获得。

例如：

Bus 001 Device 014: ID 0e8d:20ff MediaTek Inc.

第三步：重新加载驱动

　　sudo chmod a+rx /etc/udev/rules.d/53-android.rules
        sudo chmod a+rx /etc/udev/rules.d/53-MTKinc.rules
        sudo /etc/init.d/udev restart


```





### 版本发布流程

1. #### 编译前

   1）确认SPL版本

   在build/core/version_defaults.mk下面查找PLATFORM_SECURITY_PATCH，和odm确认这个是否对。

   2）确认内外部组件的版本

    默认情况下，会默认生成prebuilts_versions.txt

   3）Espresso资源包和ODM确认

   4）修改点确认和更新

   修改内容是否push，jazz上面严重问题是否切换resolved等。

   /vendor/mobydata/changelog/memork-changelog.txt

   5）修改版本号

   /device/mobydata/memor_k/mobydata.mk

   MD_BUILD_NUMBER := 1.02.09.$(shell date +%Y%m%d -d @$(CUSTOM_TIMESTAMP))

   ```
   $ cat device/mobydata/memor_k/mobydata.mk
   CUSTOM_TIMESTAMP ?= $(shell date +%s)
   MD_BUILD_NUMBER := 1.02.08.$(shell date +%Y%m%d -d @$(CUSTOM_TIMESTAMP))
   ```

   

   6）打TAG

   ```
   repo forall -j8 -c "pwd; git tag -f  1.02.09.20220711  origin/memork_dev; git push -f origin  1.02.09.20220711  origin/memork_dev "
   ```

   其他项目

   ```
   repo forall -j8 -c "pwd;git tag -f 1.01.01.20210508 origin/dl35_pie_dev;git push -f origin 1.01.01.20210508 origin/dl35_pie_dev:refs/heads/dl35_pie_rel"
   ```

   确认tag是否成功，查看gitLab

   ![2022-07-12_10-45](Image/2022-07-12_10-45.png)

   ![2022-07-12_10-45_1](Image/2022-07-12_10-45_1.png)

   6）Code freeze

   停止一切代码更新，剩下的都是编译动作了。

   

2. #### 启动编译

   https://blqsrv819.dl.net:20443/

   ![2022-07-12_10-53](Image/2022-07-12_10-53.png)

   userdebug版本无需ota包，选none

   userdebug版本需要填写timestamp：

   Download memor_k-build.prop-user-xxx.zip at first, unzip it you can find build.prop, 1655694606 is timestamp for this build, each build has different timestamp.

   *$ cat build.prop | grep fingerprint*

   *# Do not try to parse description, fingerprint, or thumbprint*

   *ro.build.fingerprint=Datalogic/memor_k_ww/memor_k:9/1.02.08.20220620/1655694606:user/release-keys*

   通过查看ro.build.fingerprint，来定位时间戳

   

   如果是Memor10，需要编译8个版本

   （正式版本+userdebug版本）*4

   aosp 国内

   us 美国

   ru 俄罗斯

   row 全球

   

   预编译的话，发aosp、us版本，发邮件出来跑GMS

   GMS跑过了，然后再准备正式编译

   如果没跑过，解问题，重新跑

   

3. #### 镜像整理

   如果是M10，需要执行制作差分包：

   ```
   source ./build/envsetup.sh
   lunch memor_k-user
   ./build/make/tools/releasetools/ota_from_target_files.py -s vendor/mediatek/proprietary/scripts/releasetools/releasetools.py  -i /tmp/old_target_files.zip  /tmp/new_target_files.zip  out/target/product/memor_k/inc-ota.zip
   ```

   

   创建OneDrive目录，相应的镜像上传至OneDrive

   ![image-20220711095423697](C:\Users\ldeng\AppData\Roaming\Typora\typora-user-images\image-20220711095423697.png)

   ```
   enterprise_espresso  企业定制相关
   
   inc-otas-3.00-3.01 基于上一个版本的ota差分包
   
   images-for-flash-tool  工具刷机包
   
   ota-packages-for-upgrade  OTA整包
   
   target-file-for-developer 全量target file
   
   userdebug-for-test-only 工具刷机包userdebug版本
   
   prebuilts_versions  prebuilts的版本信息
   
   memor10-changelog  修改点
   
   Jenkins_BuildID_M10_A10  Jenkins编译信息
   ```

   关于如何智能上传和下载，这个需要自动化程序，待完善。

   

4. #### 提测邮件

   需要包含的点：

   1、onedrive地址

   2、Jazz地址

   3、艾特的人

   

   Hi all,

    

   Please kindly be noted that **Memor 10 Android 10 prebuild version** was uploaded to OneDrive [![Folder icon](file:///C:/Users/ldeng/AppData/Local/Temp/msohtmlclip1/24/clip_image002.gif) 3.02.06.20220629_pretest](https://datalogicgroup-my.sharepoint.com/:f:/r/personal/andrea_gragnoli_datalogic_com/Documents/DL35/Mobilead/SW/dl35-10/3.02.06.20220629_pretest?csf=1&web=1&e=TZfFsv)

   You can find below artifacts in the link.

   \-   Images

   \-   OTA-packages

   \-   Enterprise_espresso

   \-   Changelog

    

   MR2 plan is JAZZ as below,

   https://rationalcld.dl.net/ccm/web/projects/MOB-Mobydata#action=com.ibm.team.apt.viewPlan&page=com.ibm.team.apt.web.ui.plannedItems&id=_iqXmsKRQEeyXnstN8xUdYw&planMode=com.ibm.team.apt.viewmodes.internal.gantt

    

   [@Huynh, Thanh](mailto:Thanh.Huynh@datalogic.com) [@Bui, Huong (R&D)](mailto:Huong.Bui@datalogic.com) Could you help to arrange your time for validating this prebuild version?

    

   Regards,

   Lucas

    

5. #### 测试与发布

   等待测试结果，评估Jazz的BUG，并等待GMS认证的结果

   测试经过3个流程：

   - ODM内部验证出结果
   - ODM送到3PL去做谷歌TA
   - ODM拿到TA证书，给到DL内部
   - 确实是否发布？
   
5. #### 善后

   如果确认发布，需要执行以下两项：

   1、Store the repo manifest

   Get this in Jenkins 'Repo Manifest', copy and push to GitLab repository
   
   https://blqsrv819.dl.net/DL35-Priv/jenkins

   类似这个：

   在Jekins上面点击这里：

   ![image-20220726174110390](Image/image-20220726174110390.png)

   然后，提交到：

   https://blqsrv819.dl.net/DL35-Priv/jenkins/memork-a9-manifests

   ![image-20220726174200450](Image/image-20220726174200450.png)

   
   
   2、Store Jekins Links
   
   Store the Jekins link which build the finnal release version in the txt file, named such as Jenkins_BuildID_MK_A9.txt
   
   ![image-20220726174348377](Image/image-20220726174348377.png)
   
   ![image-20220726174400812](Image/image-20220726174400812.png)
   
   







### Unlock

0、刷机factory.img

```
用flash tool或者fastboot命令刷机
```

1、设置，开发者模式，允许oem unlock

```
如果有imei，通过脚本装换出密码
如果没有imei，0741852
```

```
imei = '12345678901234' #insert your phone's 14-digits-long IMEI
psw = [None] * 7

for i in range(7):
    m = int(imei[i])
    m_7 = int(imei[i + 7])
    psw[i] = (m + m_7 + 7 * i) % 10

result = ''.join(str(p) for p in psw)

print(result)
```

2、fastboot解锁

```
adb reboot bootloader
fastboot  flashing  unlock
按以下音量上键
```

3、重启

fastboot reboot



查看imei：

adb shell service call iphonesubinfo 1





### Fingerprint信息

The fingerprint should follow the rules of : 
1.	
Rule	(BRAND)/$(PRODUCT)/ (DEVICE):$(VERSION.RELEASE)/$(ID)/$(VERSION.INCREMENTAL):$(TYPE)/$(TAGS)
Example	acme/myproduct/mydevice:10/LMYXX/3359:userdebug/test-keys
2.	BUILD ID can be same with VERSION.INCREMENTAL.
3．ro.build.version.incremental should be same with VERSION.INCREMENTAL.





### 如何确认是私有Key还是公有Key编译的镜像？

```
在device/datalogic/security目录下，
keytool -printcert --file platform.x509.pem


在out_sys/target/product/mssi_t_64_cn/system/priv-app/DLSettings目录下，
keytool -printcert --jarfile  DLSettings.apk

查看两个key是否一致，如下：
Owner: EMAILADDRESS=info.adc.it@datalogic.com, CN=Habanero, OU=Datalogic ADC s.r.l., O=Datalogic, L=Lippo di Calderara di Reno(BO), ST=Italy, C=IT
Italy是dl private key
china是dev key

```



### Private Key

```
Hi Marco,
I’ve pushed M11 A11 private key to https://blqsrv819.dl.net/DL_Private/M11/security .
Updated WIKI like below.

BTW, I’ll delete the M11 A11 private key from git@blqsrv819.dl.net:DL35-Priv/device/datalogic/security.git that I pushed last week.
FYI.


Build with DL private key[edit | edit source]
Note 1: DL private key location
 It need DL private key for release version to customer.
 Notice: Not share DL private key outside of Datalogic.
 The git server of DL private key:git@blqsrv819.dl.net:DL_Private/M11/security.git. 
 Branch:memor11_a11.
Note 2: Compile with DL private key
 Get these DL private keys and overlap these keys in /device/datalogic/security with these private keys.
 Compile with DL private key.



```



```
default.xml 示例：

<?xml version="1.0" encoding="UTF-8"?>

<manifest>

<! -- remote元素设置远程服务器属性，可以为多个：name设置远程服务器名，用于git fetch，git remote等操作；fetch 所有project的git url前缀；指定gerrit的服务器名，用于repo upload操作 -->

<remote name="origin"   fetch="gerrit.dd.net"   review="http://gerrit.dd.net"/>

<! -- default元素设定所有peoject的默认属性值：revision为git分支名，如master或refs/heads/master；remote为某一个remote元素的name属性值，用于指定使用哪一个远程服务器；sync-j为sync操作时的线程数-->

<default revision="master"  remote="origin"  sync-j="4" />

<! -- project元素指定一个需要clone的git仓库：path指定clone出来的git仓库在本地的地址；name唯一的名字表示project，用于拼接生成项目 git仓库的url；revision：指定需要获取的git提交点，可以定义成固定的branch，或者是明确的commit 哈希值 -->

<project path="fanxiao/fanxiaotest1" name="MA/Applications/app-a"  revision="master" />
<project path="fanxiao/fanxiaotest2" name="MA/Applications/app-b" revision="52cf9185ff1d" />
<project path="fanxiao/fanxiaotest3" name="fanxiaotest"  revision="master"/>

</manifest>
```



### 电脑本机不能使用scp传输的问题

问题：

```
lucas@DLCNRDBS03:~/AOSP/Memor11_A11/device/datalogic/datalogic-common$ scp -P 22  -r  ldeng@10.86.240.45:/home/ldeng/code/AOSP/Common_Code/artifacts/release/DLSystemUpdate/  ./ 
ssh: connect to host 10.86.240.45 port 22: Connection refused
```

是因为本机没有安装scp允许传输的服务，打开22号端口

```
sudo apt-get update
sudo apt-get install openssh-server
sudo ufw allow 22
```



### 为什么有的selinux明明有问题，却不会avc报错？

```
因为有dontaudit 注释掉了
```





### 编译Settings SystemUI，hiddenapi编译报错

```
FAILED: out/soong/hiddenapi/hiddenapi-stub-flags.txt 
out/soong/host/linux-x86/bin/hiddenapi list --public-stub-classpath=out/soong/.intermediates/frameworks/base/android_stubs_current/android_common/dex-withres/android_stubs_current.jar --system-stub-classpath=out/soong/.intermediates/frameworks/base/android_system_stubs_current/android_common/dex-withres/android_system_stubs_current.jar --test-stub-classpath=out/soong/.intermediates/frameworks/base/android_test_stubs_current/android_common/dex-withres/android_test_stubs_current.jar --core-platform-stub-classpath=out/soong/.intermediates/libcore/mmodules/core_platform_api/core.platform.api.stubs/android_common/dex/core.platform.api.stubs.jar --out-api-flags=out/soong/hiddenapi/hiddenapi-stub-flags.txt.tmp && ( if cmp -s out/soong/hiddenapi/hiddenapi-stub-flags.txt.tmp out/soong/hiddenapi/hiddenapi-stub-flags.txt ; then rm out/soong/hiddenapi/hiddenapi-stub-flags.txt.tmp ; else mv out/soong/hiddenapi/hiddenapi-stub-flags.txt.tmp out/soong/hiddenapi/hiddenapi-stub-flags.txt ; fi )
hiddenapi E 08-29 15:53:03 99133 99133 hiddenapi.cc:58] No boot DEX files specified
hiddenapi E 08-29 15:53:03 99133 99133 hiddenapi.cc:58] Command: out/soong/host/linux-x86/bin/hiddenapi list --public-stub-classpath=out/soong/.intermediates/frameworks/base/android_stubs_current/android_common/dex-withres/android_stubs_current.jar --system-stub-classpath=out/soong/.intermediates/frameworks/base/android_system_stubs_current/android_common/dex-withres/android_system_stubs_current.jar --test-stub-classpath=out/soong/.intermediates/frameworks/base/android_test_stubs_current/android_common/dex-withres/android_test_stubs_current.jar --core-platform-stub-classpath=out/soong/.intermediates/libcore/mmodules/core_platform_api/core.platform.api.stubs/android_common/dex/core.platform.api.stubs.jar --out-api-flags=out/soong/hiddenapi/hiddenapi-stub-flags.txt.tmp
hiddenapi E 08-29 15:53:03 99133 99133 hiddenapi.cc:58] Usage: hiddenapi [command_name] [options]...

```





### 咨询Max问题

1、服务是否移植到datalogic-services实现？

2、如何查看com.datalogic.interfaces com.datalogic.device的版本？

3、M11和dl36问题，提交权限问题，同步apk问题

4、DL_SCREEN_OFF_TIMEOUT一会system一会global



```
/data/app/~~Wog5LEEaZq3Oio0mOZXubg==/com.datalogic.server-FK77IIeZJ_5gBcZoXW2voA==/base.apk!libdatalogic_servers.so

```



### AS如何调试Settings模块？

![image-20220902111331551](Image/image-20220902111331551.png)

![image-20220902111353701](Image/image-20220902111353701.png)

1、先编译这个Settings-core库

```
make -j32 Settings-core
```

2、然后下面生成了lib

```
out/target/common/obj/JAVA_LIBRARIES/Settings-core_intermediates/classes.jar
```

3、AS加入lib编译：

![image-20220902202300701](Image/image-20220902202300701.png)

可以修改代码了。



不然会报hiddenapi的错误。

编译Settings：

```
export UNSAFE_DISABLE_HIDDENAPI_FLAGS=true ; make -j32 Settings
```

![image-20220902234440858](Image/image-20220902234440858.png)





### 调试framework services  update_engine

```
make -j32 framework-minus-apex

adb root;adb disable-verity;adb reboot;adb wait-for-device;adb root;adb remount

adb root ; adb disable-verity ;adb remount ; adb push  out/target/product/memor_k/system/framework/framework.jar    system/framework/framework.jar   ; adb shell "stop && start "
```



调试services

```
make -j32 services

adb root ; adb disable-verity ;adb remount ; adb push  out/target/product/memor_k/system/framework/services.jar    system/framework/services.jar   ; adb shell "stop && start " 

```



调试update_engine

```
adb root ; adb disable-verity ;adb remount ; adb push  out/target/product/memor_k/system/bin/update_engine    system/bin/update_engine    ;  adb push  out/target/product/memor_k/system/bin/update_engine_client system/bin/update_engine_client ;  adb shell "stop && start "
```

system分区开启了写保护，直接kill 常驻进程

```
adb root ; adb disable-verity ;adb remount ; adb push  out/target/product/memor_k/system/bin/update_engine    system/bin/update_engine    ;  adb push  out/target/product/memor_k/system/bin/update_engine_client system/bin/update_engine_client  ; adb shell "kill -9 $(pidof update_engine)"
```



调试Launcher3：

```
```





### 如何调试wifi apex相关模块？

1、编译命令

```
source build/envsetup.sh

lunch

make -j16 com.android.wifi
```

![image-20220811114251653](Image/image-20220811114251653.png)

2、push文件

```
adb push out/target/product/mssi_t_64_cn/system/apex/com.android.wifi.apex /data/local/tmp/
```

3、安装

```
adb shell 进去
pm install --apex  data/local/tmp/com.android.wifi.apex
reboot
```

![image-20220811114102726](Image/image-20220811114102726.png)

4、重启机器，即可生效：

![image-20220811114149627](Image/image-20220811114149627.png)

https://source.android.com/devices/tech/ota/apex?hl=zh-cn





### 如何调试sepolicy相关模块？

1、修改可能导致单编译报错的修改：

```
diff --git a/sys_plat_sepolicy/vendor/file.te b/sys_plat_sepolicy/vendor/file.te
index b0f939a..cfe8788 100755
--- a/sys_plat_sepolicy/vendor/file.te
+++ b/sys_plat_sepolicy/vendor/file.te
@@ -5,5 +5,5 @@ type battery_data, fs_type, sysfs_type;
 type sysfs_wakeups, fs_type, sysfs_type;
 type sysfs_locks, fs_type, sysfs_type;
 ##add datalogic scan per supporty
-type datalogic_perf_hal_exec, system_file_type, exec_type, file_type;
+#type datalogic_perf_hal_exec, system_file_type, exec_type, file_type;
 
diff --git a/sys_plat_sepolicy/vendor/file_contexts b/sys_plat_sepolicy/vendor/file_contexts
index 5edf82c..11c93a1 100755
--- a/sys_plat_sepolicy/vendor/file_contexts
+++ b/sys_plat_sepolicy/vendor/file_contexts
@@ -12,7 +12,7 @@
 /sys/devices/platform/factory_data(/.*)?                                  u:object_r:factory_data:s0
 /dev/block/platform/bootdevice/by-name/factory                            u:object_r:factory_block_device:s0
 #add datalogic scan per support
-/vendor/lib(64)?/libmtkperf_client_vendor.so                              u:object_r:datalogic_perf_hal_exec:s0
+#/vendor/lib(64)?/libmtkperf_client_vendor.so                              u:object_r:datalogic_perf_hal_exec:s0
 /sys/devices/platform/wakeup/eint_trig_left_key                           u:object_r:sysfs_wakeups:s0
 /sys/devices/platform/wakeup/eint_trig_right_key                          u:object_r:sysfs_wakeups:s0
 /sys/devices/platform/wakeup/eint_trig_pistol                             u:object_r:sysfs_wakeups:s0

```



2、

```
source

lunch

mmma system/sepolicy
```



- 为什么不选择make system_sepolicy?

因为sepolicy下面有很多富余的模块，不然只编译system_sepolicy，而且耗时差不多。

- 为什么不选择mmm system/sepolicy

因为mmma会编译本模块以及依赖，确保push进去能全局生效 。

- 为什么编译system/sepolicy下面，dl自己的selinux权限也能编译进去？

  因为是通过如下方式加载进去的：

  ```
  BOARD_SEPOLICY_DIRS += \
         $(DL_SEPOLICY_PATH)/vendor
  
  BOARD_PLAT_PUBLIC_SEPOLICY_DIR += \
      $(DL_SEPOLICY_PATH)/public
  
  BOARD_PLAT_PRIVATE_SEPOLICY_DIR += \
      $(DL_SEPOLICY_PATH)/private
  
  ```

  BOARD_SEPOLICY_DIRS

  ![image-20220826173946784](Image/image-20220826173946784.png)

- 而且sepolicy的编译 必须编译test模块，所以编译最多的部分最稳妥。



3、生成新的selinux策略目录后，如何push

```
adb push  out/target/product/dl36/system/etc/selinux/   /system/etc/  ; 
adb push  out/target/product/dl36/vendor/etc/selinux/   /vendor/etc/  ;
```

记住后面那个参数一定要加根目录符号。

还可能存在dm verify 和 secure boot 导致push数据恢复的问题。





Makefile判断文件是够存在的方法：

```
HAVE_ENTERPRISE_KEY_FILE := $(shell if [ -f  $(ENTERPRISE_KEY) ]; then echo true; else echo false; fi)
HAVE_ENTERPRISE_KEY_FILE := $(if $(wildcard $(ENTERPRISE_KEY)),true,false)
```

Note:

一定要注意$(ENTERPRISE_KEY)要用括号。

if后面的条件结果不能有空格





fastboot没法执行成功，虚拟机没有usb列表，归根结底是因为没有su权限，lsusb的时候没法枚举全面。



fastboot：

```
sudo chmod +s fastboot 
```



virtualbox usb:

```
sudo addgroup vboxusers
sudo adduser <username>

重启reboot

groups


查看虚拟机的ubs list：
VBoxManage list usbhost


```



```
fast_ninja fra^Cwork-minus-apex ; fast_ninja   services ;  ls out/target/product/dl36/system/framework/framework.jar -al ; adb_root_remount  ; adb push out/target/product/dl36/system/framework/framework.jar  /system/framework/framework.jar ; ls -al out/target/product/dl36/system/framework/services.jar ; adb_root_remount  ; adb push out/target/product/dl36/system/framework/services.jar  /system/framework/services.jar 
```





```
} else if (isDownloadsDocument(uri)) {
                String id = DocumentsContract.getDocumentId(uri);
                LogUtils.debugLog(SUB_TAG,  "Lucas isDownloadsDocument id=" + id);
                String path;
                if (id.startsWith("msf:")) { //MediaProvider (only Android 10 shall enter here)
                    path = id.split(":")[1];
                    Uri downloadsUri = getMediaStoreDownloadsExternalContentUri();
                    if (downloadsUri == null)
                        return null;
                    Uri mediaUri = ContentUris.withAppendedId(downloadsUri, Long.parseLong(path));
                    LogUtils.debugLog(SUB_TAG,  "Lucas isDownloadsDocument mediaUri=" + mediaUri);
                    return getDataColumn(context, mediaUri, null, null);
                } else {
                    final Uri contentUri = ContentUris.withAppendedId(
                            Uri.parse("content://downloads/all_downloads"),
                            Long.valueOf(id));
                    LogUtils.debugLog(SUB_TAG,  "Lucas isDownloadsDocument contentUri=" + contentUri);
                    return getDataColumn(context, contentUri, null, null);
                }

            }
```



**进入工厂模式**

```
*#**672#
```



scrcpy**无法开启问题**

Could not find any ADB device

```
开启开发者模式
/snap/bin/scrcpy.adb   devices
看看是否有你要的devices
不然要cp adb过去
```

```
adb devices ; scrcpy.adb  devices  ; scrcpy 
```





### 反射的几个知识点

1 非静态变量无法获取，所以提示这个

```
java.lang.NullPointerException: null receiver
	at java.lang.reflect.Field.get(Native Method)
	at com.mediatek.server.am.AmsExtImpl.enableAmsLog(AmsExtImpl.java:608)
```

加上判断是否静态？

```
boolean  isStatic  =  Modifier.isStatic(field1.getModifiers());
            if(isStatic && "boolean".equals(field1.getType().getName())){
            // 判断是否静态，是否bool
```

2 final变量也可以改？

```java
Field modifiersField = null;
try {
    //是final
    modifiersField = Field.class.getDeclaredField("modifiers");
    modifiersField.setAccessible(true);
    modifiersField.setInt(optionField, optionField.getModifiers() & ~Modifier.FINAL);
} catch (NoSuchFieldException e) {
    //非final
    Slog.e(TAG, "modifiers getDeclaredField failed");
    e.printStackTrace();
}
optionField.setAccessible(true);
optionField.set(null, isEnable);
```

3 完整源码：

```java
 /**
     * Usage : open dynamic log by command : adb shell dumpsys activity log tag:DEBUG_XXXX1,DEBUG_XXXX2 on
     * isEnable: boolean
     * options: tag:DEBUG_XXXX1,DEBUG_XXXX2
     * function: DEBUG_XXXX1 = true; DEBUG_XXXX2=true
     * **/
    private static void enableAmsLog(boolean isEnable, ArrayList<ProcessRecord> lruProcesses, String options) {
        options = options.replaceFirst("tag:", "");
        String[] option = options.split(",");

        Field optionField = null;
        Class clazz = null;
        if(TAG_CLASS_NAME == null || "".equals(TAG_CLASS_NAME)){
            clazz = ActivityManagerDebugConfig.class;
        } else {
            try {
                clazz = Class.forName(TAG_CLASS_NAME);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
        }

        for (int i = 0; i < option.length; i++) {
            try{
                try {
                    optionField = clazz.getDeclaredField(option[i]);
                } catch (NoSuchFieldException e) {
                    Slog.e(TAG, "option getDeclaredField failed");
                    e.printStackTrace();
                }

                Field modifiersField = null;
                try {
                    modifiersField = Field.class.getDeclaredField("modifiers");
                    modifiersField.setAccessible(true);
                    modifiersField.setInt(optionField, optionField.getModifiers() & ~Modifier.FINAL);
                } catch (NoSuchFieldException e) {
                    Slog.e(TAG, "modifiers getDeclaredField failed");
                    e.printStackTrace();
                }
                optionField.setAccessible(true);
                optionField.set(null, isEnable);
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }

        /*******start*********/
        Slog.e(TAG, "Loop start TAG_CLASS_NAME---->" + TAG_CLASS_NAME);
        Field[] fields;

        Slog.e(TAG, "clazz---->" + clazz.getName());
        System.out.println("failed before");
        fields = clazz.getDeclaredFields();
        System.out.println("failed after");

        //Field[] fields = ActivityManagerDebugConfig.class.getDeclaredFields();
        for (Field field1 : fields) {
            field1.setAccessible(true);
            Slog.e(TAG, "field1---->" + field1.getName());
            boolean  isStatic  =  Modifier.isStatic(field1.getModifiers());
            if(isStatic && "boolean".equals(field1.getType().getName())){
                Boolean value = null;
                try {
                    field1.setAccessible(true);
                    if(field1 != null) value = (Boolean) field1.get(null);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }
                Slog.e(TAG, TAG_CLASS_NAME + ".      " + field1 + "---->" + value);
            }
        }
        /*******end*********/
    }
}
```









