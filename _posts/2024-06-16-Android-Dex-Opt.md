---
layout: post
title: Trigger Workflow of Android Dex Optimizations 
categories: [android, DexOpt]
description: some word here
keywords: android, dex2oat, DexOpt
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---

![android_dex](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/android_dex.png)

[TOC]

# Android DexOpt七种触发流程解析【原创硬核】

> 众所周知，DexOpt是安卓应用性能优化非常重要的手段，相当于将应用对虚拟机的多层调用直接转化成了arm机器码。Dex优化过和没优化过，效果千差万别。本文深入解析android系统DexOpt机制的触发流程。



## 1 DexOpt简介

### 1.1 简要原理

​	  通俗来讲，相当于外交官开发布会（Java），此前是用人工同声翻译（JVM），转达到各个国家的媒体记者那，现在人类开发了同声翻译器（DexOpt），这个翻译会基于每个国家的语言文化的规则（profile）进行翻译成各国记者（各CPU架构）能快速听懂的语言（机器码）。

![DexOpt.jpg](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/DexOpt.jpg)

app经过DexOpt之后，运行在安卓虚拟机上，可以快速和底层硬件用机器码沟通，从而实现优化执行链路。



​		基本原理就是app存在大量的直接或者间接对系统framework层代码的调用，对于系统应用来说，其运行环境在编译期间是可以确定的，那么系统层的这些大量代码在设备上已经是尽可能的 .art 化了的,并且 frameworks image 和 frameworks code 是可以直接提供给oat中的cpmpiled method 直接调用和访问的，而不需要在程序启动的时候动态创建，这样无疑能很大程度提升程序运行速度。此外，oat 文件包含了不少对 dex 文件进行 preload 的数据，省去了大量内存开辟和赋值的指令。

![img](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/01cb7ee0d67a84c579a4e8fe1b5d21c9.png)



Android早期版本是Dalvik虚拟机，从Android 5.0 开始引入ART虚拟机。

Dalvik虚拟机：

```
dex files ----> dexopt  ----> odex files
```

ART虚拟机：

```
dex files ----> dex2oat  ----> oat files
```

由于早期称这个过程为dexopt， 后面称这个过程为dex2oat， 现在统称这个过程为DexOpt。

![img](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/807220-a9132fd83683f2e7)

### 1.2 演变史

Android DexOpt的演变有3个大阶段：

- Android 5.0之前，运行在Dalvik虚拟机上，Dalvik虚拟机会在执行dex文件前对dex文件做优化，依赖于JIT技术，生成可执行**odex**文件，保存到 data/dalvik-cache 目录，最后把Apk文件中的dex文件删除。

  此时生成的odex文件后缀依然是dex ，它是一个dex文件，里面仍然是字节码，而不是本地机器码。

- Android 5.0～Android 8.0，使用ART虚拟机，ART虚拟机使用AOT预编译生成**oat文件**。oat文件是ART虚拟机运行的文件，是ELF格式二进制文件。oat文件包含dex和编译的本地机器指令，因此比Android5.0之前的odex文件更大。
  此时生成的oat文件后缀是odex ，它是一个oat文件，里面仍然是本地机器码，而不是字节码。

- Android 8.0至今， dex2oat会直接生成两个oat文件 (即 **vdex文件 和 odex文件** )。其中 odex 文件是从vdex 文件中提取了部分模块生成的一个新的可执行二进制码文件，odex 从vdex 中提取后，vdex 的大小就减少了。App在首次安装的时候，odex 文件就会生成在` /system/app/<packagename>/oat/ `下。
  在系统运行过程中，虚拟机将其 从 `/system/app` 下 copy 到 `/data/dalvik-cache/` 下。



Android 8 以后，将会生成以下文件：

- `.vdex`：包含一些可加快验证速度的其他元数据（有时还有 APK 的未压缩 DEX 代码）。
- `.odex`：包含 APK 中已经过 AOT 编译的方法代码。
- `.art (optional)`：包含 APK 中列出的某些字符串和类的 ART 内部表示，用于加快应用启动速度。



拿到Android13的实机上查询发现，特点如下：

- 系统编译阶段生成的优化文件：

  ```
  /system/priv-app/ABC/ABC.apk
  /system/priv-app/ABC/oat/arm64/ABC.vdex
  /system/priv-app/ABC/oat/arm64/ABC.odex
  ```

- 空闲编译产生的优化文件：

  ```
  ./system/system_ext/priv-app/ABC/ABC.apk
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.vdex
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.art
  ./data/dalvik-cache/arm64/system@system_ext@priv-app@ABC@ABC.apk@classes.dex
  ```

- 系统编译生成的jar文件：

  ```
  /system/framework/ABC.vdex
  /system/framework/arm64/ABC.art
  /system/framework/arm64/ABC.oat
  /system/framework/arm64/ABC.vdex
  ```

简约地理解如下：

- `vdex` 是用来安装/启动快速验证的，

- `art`是用来i阿快应用启动的，

- 而上面的`odex / dex / oat` 格式本质上都是ELF文件，是程序运行本身。



### 1.3 过滤器

ART 如何编译 DEX 代码还有个compile filter以参数的形式来决定：从 Android O 开始，有四个官方支持的过滤器：

- **verify**：只运行 DEX 代码验证。
- **quicken**：运行 DEX 代码验证，并优化一些 DEX 指令，以获得更好的解释器性能。
- **speed-profile**：运行 DEX 代码验证，并对配置文件中列出的方法进行 AOT 编译。
- **speed**：运行 DEX 代码验证，并对所有方法进行 AOT 编译。

verify 和quicken 他俩都没执行编译，之后代码执行需要跑解释器。而speed-profile 和 speed 都执行了编译，区别是speed-profile根据profile记录的热点函数来编译，属于部分编译，而speed属于全编。

执行效率上：

```
verify < quicken < speed-profile < speed
```

编译速度上：

```
verify > quicken > speed-profile > speed
```



> 理论上，生成的优化文件越大，编译耗时越长，优化越彻底，运行速度理应越快。



以下这些属性代表了，不同原因（Reason）做dexopt，将会使用不同的过滤器。

比如AB OTA升级，建议使用`speed-profile`，因为OTA本身比较耗时，选择这种方式可以让升级后，性能快速提升。

比如OTA升级开机 或者首次开机，建议使用`verify`，因为不能消耗太多时间在这上面，否则影响开机速度。

```
 # getprop |   grep pm.dexopt
[pm.dexopt.ab-ota]: [speed-profile]
[pm.dexopt.bg-dexopt]: [speed-profile]
[pm.dexopt.boot-after-ota]: [verify]
[pm.dexopt.cmdline]: [verify]
[pm.dexopt.first-boot]: [verify]
[pm.dexopt.inactive]: [verify]
[pm.dexopt.install]: [speed-profile]
[pm.dexopt.install-bulk]: [speed-profile]
[pm.dexopt.install-bulk-downgraded]: [verify]
[pm.dexopt.install-bulk-secondary]: [verify]
[pm.dexopt.install-bulk-secondary-downgraded]: [extract]
[pm.dexopt.install-fast]: [skip]
[pm.dexopt.post-boot]: [extract]
[pm.dexopt.shared]: [speed]
```

PKMS中的 dexopt 实现仅适用于 Android 13 及更低版本。

在 Android 14 中，它已被 ART 服务取代，并且将在下一个版本中从软件包管理系统中移除。



### 1.2 DexOpt触发条件

![image-20240730155857821](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240730155857821.png)

>  此外，还有使用adb命令手动触发，本质上属于系统空闲触发的流程。



## 2 DexOpt触发流程解析

### 2.1 编译阶段

这里讲的编译，指的是系统AOSP编译。

对系统应用（app prebuils）而言，是否编译阶段开启/关闭DexOpt，只需要在Android编译文件上配置即可。

`Android.bp`

```makefile
android_app {
    name: "xxxxx",
+    dex_preopt: {
+    	enabled: false,
+    },
}
```

`Android.mk`

```makefile
LOCAL_MODULE := xxxxx
+ LOCAL_DEX_PREOPT := false
```

如果是系统服务要开启DexOpt，配置方法稍有不同，本文不做研究。

如果系统应用配置了enable DexOpt， 则会在系统编译的时候，在apk原位置，生成oat路径，里面有odex和vdex文件（Android 13），这两个文件可能比apk源文件还大。

```shell
/system/priv-app/ABC/ABC.apk
/system/priv-app/ABC/oat/arm64/ABC.vdex
/system/priv-app/ABC/oat/arm64/ABC.odex
```

总结如下，

- 如果配置所有系统应用都开启DexOpt，则会**增大系统分区**，编译时间也会增长，但是开机后就优化好了，系统比较流畅。

  >  思想：空间换时间 

- 如果所有系统应用都关闭DexOpt，则也会在开机后空闲的时候进行DexOpt， 则会增加data分区大小，但**系统分区要小很多**。

  >  思想：时间换空间



**编译阶段是如何触发优化的？**

具体的流程稍微有些复杂，挑关键的讲。

`build/make/core/make.mk`

```
include $(BUILD_SYSTEM)/dex_preopt.mk
```



`dex_preopt.mk`

```
include $(BUILD_SYSTEM)/dex_preopt_config.mk
```



`dex_preopt_config.mk`，所有prebuilts默认是否enable， 可以通过ENABLE_PREOPT来配置。

```
# The default value for LOCAL_DEX_PREOPT
DEX_PREOPT_DEFAULT ?= $(ENABLE_PREOPT)
```

但这个只是其中一种方式。



build/make/core/java.mk

```
include $(BUILD_SYSTEM)/dex_preopt_odex_install.mk
```

`dex_preopt_odex_install.mk`是控制是否编译dex的关键。

LOCAL_DEX_PREOPT最终是true还是false，由很多因素决定。

```makefile
# Setting LOCAL_DEX_PREOPT based on WITH_DEXPREOPT, LOCAL_DEX_PREOPT, etc
LOCAL_DEX_PREOPT := $(strip $(LOCAL_DEX_PREOPT))
# 未定义则使用DEX_PREOPT_DEFAULT
ifndef LOCAL_DEX_PREOPT # LOCAL_DEX_PREOPT undefined
  LOCAL_DEX_PREOPT := $(DEX_PREOPT_DEFAULT)
endif

# 只要是false，最终DEX_PREOPT_DEFAULT会被清空
ifeq (false,$(LOCAL_DEX_PREOPT))
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
# Disable preopt for tests.
ifneq (,$(filter $(LOCAL_MODULE_TAGS),tests))
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
# If we have product-specific config for this module?
ifneq (,$(filter $(LOCAL_MODULE),$(DEXPREOPT_DISABLED_MODULES)))
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
# Disable preopt for DISABLE_PREOPT
ifeq (true,$(DISABLE_PREOPT))
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
# Disable preopt if not WITH_DEXPREOPT
ifneq (true,$(WITH_DEXPREOPT))
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
ifdef LOCAL_UNINSTALLABLE_MODULE
  LOCAL_DEX_PREOPT :=
endif

# DEX_PREOPT_DEFAULT被清除
# Disable preopt if the app contains no java code.
ifeq (,$(strip $(built_dex)$(my_prebuilt_src_file)$(LOCAL_SOONG_DEX_JAR)))
  LOCAL_DEX_PREOPT :=
endif
```

DEX_PREOPT_DEFAULT只要被清除，就默认不做dex优化。

可以认为以上开关，基本都不会进去，DEX_PREOPT_DEFAULT不会被清除，只有人为调试需要去修改，才会清除LOCAL_DEX_PREOPT。

所以说大部分时候，prebuilts是否做dex优化，取决于在Android.bp / Android.mk 文件中的配置（LOCAL_DEX_PREOPT := true）。



**那么LOCAL_DEX_PREOPT是怎么控制是否优化的动作？**

```makefile
# LOCAL_DEX_PREOPT为true,就会创建dexpreopt.config
# 有dexpreopt.config就会做dexopt了，这里很不其眼，但是是重要的分叉口。
ifdef LOCAL_DEX_PREOPT
  ifeq (,$(filter PRESIGNED,$(LOCAL_CERTIFICATE)))
    # Store uncompressed dex files preopted in /system
    ifeq ($(BOARD_USES_SYSTEM_OTHER_ODEX),true)
      ifeq ($(call install-on-system-other, $(my_module_path)),)
        LOCAL_UNCOMPRESS_DEX := true
      endif  # install-on-system-other
    else  # BOARD_USES_SYSTEM_OTHER_ODEX
      LOCAL_UNCOMPRESS_DEX := true
    endif
  endif
  my_create_dexpreopt_config := true
endif

ifeq ($(my_create_dexpreopt_config), true)
	# 创建dexpreopt.config的json文件
endif
```

还得组装一个编译脚本用来执行！`dexpreopt.sh`

```makefile
my_dexpreopt_script := $(intermediates)/dexpreopt.sh
  my_dexpreopt_zip := $(intermediates)/dexpreopt.zip
  .KATI_RESTAT: $(my_dexpreopt_script)
  $(my_dexpreopt_script): PRIVATE_MODULE := $(LOCAL_MODULE)
  $(my_dexpreopt_script): PRIVATE_GLOBAL_SOONG_CONFIG := $(DEX_PREOPT_SOONG_CONFIG_FOR_MAKE)
  $(my_dexpreopt_script): PRIVATE_GLOBAL_CONFIG := $(DEX_PREOPT_CONFIG_FOR_MAKE)
  $(my_dexpreopt_script): PRIVATE_MODULE_CONFIG := $(my_dexpreopt_config)
  $(my_dexpreopt_script): $(DEXPREOPT_GEN)
  $(my_dexpreopt_script): $(my_dexpreopt_jar_copy)
  $(my_dexpreopt_script): $(my_dexpreopt_config) $(DEX_PREOPT_SOONG_CONFIG_FOR_MAKE) $(DEX_PREOPT_CONFIG_FOR_MAKE)
	@echo "$(PRIVATE_MODULE) dexpreopt gen"
	$(DEXPREOPT_GEN) \
	-global_soong $(PRIVATE_GLOBAL_SOONG_CONFIG) \
	-global $(PRIVATE_GLOBAL_CONFIG) \
	-module $(PRIVATE_MODULE_CONFIG) \
	-dexpreopt_script $@ \
	-out_dir $(OUT_DIR)
```

通过dexpreopt gen来生成dexpreopt.sh。

进一步探索`dexpreopt gen`

```shell
build/soong/dexpreopt$ tree -L 2
.
├── Android.bp
├── class_loader_context.go
├── class_loader_context_test.go
├── config.go
├── dexpreopt_gen
│   ├── Android.bp
│   └── dexpreopt_gen.go
├── dexpreopt.go
├── DEXPREOPT_IMPLEMENTATION.md
├── dexpreopt_test.go
├── OWNERS
└── testing.go
```

dexpreopt_gen又是调用dexpreopt.go来生成针对于当前应用的的dexpreopt.sh。

dexpreopt.go的关键函数dexpreoptCommand如下：

```go
func dexpreoptCommand(ctx android.PathContext, globalSoong *GlobalSoongConfig, global *GlobalConfig,
	module *ModuleConfig, rule *android.RuleBuilder, archIdx int, profile android.WritablePath,
	appImage bool, generateDM bool) {
	
	cmd := rule.Command().
		Text(`ANDROID_LOG_TAGS="*:e"`).
		Tool(globalSoong.Dex2oat).
		Flag("--avoid-storing-invocation").
		FlagWithOutput("--write-invocation-to=", invocationPath).ImplicitOutput(invocationPath).
		Flag("--runtime-arg").FlagWithArg("-Xms", global.Dex2oatXms).
		// ......
		
    	// 选择哪一种过滤器
		if !android.PrefixInList(preoptFlags, "--compiler-filter=") {
		var compilerFilter string
		if systemServerJars.ContainsJar(module.Name) {
			// Jars of system server, use the product option if it is set, speed otherwise.
			if global.SystemServerCompilerFilter != "" {
				compilerFilter = global.SystemServerCompilerFilter
			} else {
				compilerFilter = "speed"
			}
		} else if contains(global.SpeedApps, module.Name) || contains(global.SystemServerApps, module.Name) {
			// Apps loaded into system server, and apps the product default to being compiled with the
			// 'speed' compiler filter.
			compilerFilter = "speed"
		} else if profile != nil {
			// For non system server jars, use speed-profile when we have a profile.
			compilerFilter = "speed-profile"
		} else if global.DefaultCompilerFilter != "" {
			compilerFilter = global.DefaultCompilerFilter
		} else {
			compilerFilter = "quicken"
		}
		if module.EnforceUsesLibraries {
			// If the verify_uses_libraries check failed (in this case status file contains a
			// non-empty error message), then use "verify" compiler filter to avoid compiling any
			// code (it would be rejected on device because of a class loader context mismatch).
			cmd.Text("--compiler-filter=$(if test -s ").
				Input(module.EnforceUsesLibrariesStatusFile).
				Text(" ; then echo verify ; else echo " + compilerFilter + " ; fi)")
		} else {
			cmd.FlagWithArg("--compiler-filter=", compilerFilter)
		}
	}
```



**到底是哪一种过滤器？**

编译完成，在Android13查看某一个apk的编译`dexpreopt.sh`。

```makefile
#!/bin/bash
# ... ...
# 先检测是否存在某个文件，如果不存在，则选择quicken
--compiler-filter=$(if test -s  out_sys/target/common/obj/APPS/SearchLauncherQuickStep_intermediates/enforce_uses_libraries.status  ; then echo verify ; else echo quicken ; fi) --generate-mini-debug-info --compilation-reason=prebuilt
# ... ...
```

生成的shell脚本在：`out_sys/target/product/mssi_t_64_cn/obj/APPS/ABC_intermediates/dexpreopt.sh`

> 最终会调用dexpreopt.sh去调用dex2oat编译产生dex文件在out目录下，然后打包进image中。



最终发现Android13编译阶段使用的是quicken优化，为啥不选择speed或者speed-profile？前面不是讲了speed-profile性能优于quicken吗？



为了解答这个疑惑，我专门针对于某个系统应用分别做了好几种优化，然后对比。

![image-20240731122003766](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240731122003766.png)

```shell
$ md5sum dexpreopt*.zip
574eb0cfd2ae866f2d96040bd35e8510  dexpreopt_everythings.zip
cc7bbcff1dd679dd1a06ede4be1353af  dexpreopt_quicken.zip
cc7bbcff1dd679dd1a06ede4be1353af  dexpreopt_speed_profile.zip
78d3e0e7947a9d87747dcbea83e9bad2  dexpreopt_speed.zip
cc7bbcff1dd679dd1a06ede4be1353af  dexpreopt_verify.zip
574eb0cfd2ae866f2d96040bd35e8510  dexpreopt.zip

$ du -sh dexpreopt*.zip 
16M	dexpreopt_everythings.zip
5.8M	dexpreopt_quicken.zip
5.8M	dexpreopt_speed_profile.zip
16M	    dexpreopt_speed.zip
5.8M	dexpreopt_verify.zip
16M	dexpreopt.zip

```

最终发现，在Android 13上面，

verify quicken speed-profile产生的文件竟然是一模一样的，elf dump出来信息也是一样的。



同样的操作，到Android 11上面去调查，

```shell
$ md5sum dexpreopt*.zip 
14a51b30280102bea201e5b43a37c68a  dexpreopt_quciken.zip
fa98f4ec18de0fa3e1ccb2ee160ed0dc  dexpreopt_speed_profile.zip
3a7ea1665e3777fdb8bcd5b7170629ec  dexpreopt_speed.zip
da4e5e795cd77901d84274995c45d95e  dexpreopt_verify.zip

$ du -sh dexpreopt*.zip
2.8M	dexpreopt_quciken.zip
2.9M	dexpreopt_speed_profile.zip
7.1M	dexpreopt_speed.zip
2.7M	dexpreopt_verify.zip
```

verify quicken speed-profile 却是不一样的。



大胆猜测：

- 针对于系统应用，在不同平台verify quicken speed-profile 这些过滤器表现行为有差异，在Android11上面有细微差距，在Android 13上面已经是一样的。
- 针对于第三方应用怎样呢？可以自行研究。



总结编译阶段生成dex文件的方法：

- 编译阶段是通过main.mk等一系列include，加载dex_preopt_odex_install.mk
- dex_preopt_odex_install.mk会去打包config和产生dexpreopt.sh
- 而dexpreopt.sh的产生，依赖于dexpreopt_gen和dexpreopt_gen等go程序
- prebuilt编译完，恰好调用dexpreopt.sh去生成odex vdex等优化文件到out目录
- 系统image打包的时候，将dex优化文件一起打包。



### 2.2 OTA升级

是否开启OTA升级阶段进行DexOpt， 取决于`AB_OTA_POSTINSTALL_CONFIG`是否配置。

```shell
# This is an example post-install script. This script will be executed by the
# update_engine right after finishing writing all the partitions, but before
# marking the new slot as active. To enable running this program, insert these
# lines in your product's .mk file (without the # at the beginning):

# AB_OTA_POSTINSTALL_CONFIG += \
#   RUN_POSTINSTALL_system=true \
#   POSTINSTALL_PATH_system=bin/postinst_example \
#   FILESYSTEM_TYPE_system=ext4 \
```

Android 13中：

```shell
# A/B OTA dexopt update_engine hookup
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/mtk_plpath_utils_ota \
    POSTINSTALL_OPTIONAL_vendor=true
endif

```

配置这一系列环境变量`AB_OTA_POSTINSTALL_CONFIG`之后，会在编译OTA的时候打包进入image，

在执行OTA升级时候，update_engine会判断是否存在`partition.postinstall_path`，判断`postinstall_path`是否为空，来决定是否做DexOpt。

发生在`postinstall_runner_action.cc`的`PerformPartitionPostinstall`函数

```cpp
// Skip all the partitions that don't have a post-install step.
  while (current_partition_ < install_plan_.partitions.size() &&
         !install_plan_.partitions[current_partition_].run_postinstall) {
    VLOG(1) << "Skipping post-install on partition "
            << install_plan_.partitions[current_partition_].name;
    // Attempt to mount a device if it has postinstall script configured, even
    // if we want to skip running postinstall script.
    // This is because we've seen bugs like b/198787355 which is only triggered
    // when you attempt to mount a device. If device fails to mount, it will
    // likely fail to mount during boot anyway, so it's better to catch any
    // issues earlier.
    // It's possible that some of the partitions aren't mountable, but these
    // partitions shouldn't have postinstall configured. Therefore we guard this
    // logic with |postinstall_path.empty()|.
    const auto& partition = install_plan_.partitions[current_partition_];
    // 判断postinstall_path是否为空
    if (!partition.postinstall_path.empty()) {
      const auto mountable_device = partition.readonly_target_path;
      if (!MountPartition(partition)) {
        return CompletePostinstall(ErrorCode::kPostInstallMountError);
      }
      LogBuildInfoForPartition(fs_mount_dir_);
      if (!utils::UnmountFilesystem(fs_mount_dir_)) {
        return CompletePartitionPostinstall(
            1, "Error unmounting the device " + mountable_device);
      }
    }
    current_partition_++;
  }
```

如果`postinstall_path`不为空了，将会组装成脚本命令command。

```cpp
// 将postinstall_path组装成abs_path
string abs_path =
      base::FilePath(fs_mount_dir_).Append(postinstall_path).value();
  if (!base::StartsWith(
          abs_path, fs_mount_dir_, base::CompareCase::SENSITIVE)) {
    LOG(ERROR) << "Invalid relative postinstall path: "
               << partition.postinstall_path;
    return CompletePostinstall(ErrorCode::kPostinstallRunnerError);
  }

  LOG(INFO) << "Performing postinst (" << partition.postinstall_path << " at "
            << abs_path << ") installed on mountable device "
            << mountable_device;

  // Logs the file format of the postinstall script we are about to run. This
  // will help debug when the postinstall script doesn't match the architecture
  // of our build.
  LOG(INFO) << "Format file for new " << partition.postinstall_path
            << " is: " << utils::GetFileFormat(abs_path);

  // Runs the postinstall script asynchronously to free up the main loop while
  // it's running.
  vector<string> command = {abs_path};
// 将参数叠加组装成command
#ifdef __ANDROID__
  // In Brillo and Android, we pass the slot number and status fd.
  command.push_back(std::to_string(install_plan_.target_slot));
  command.push_back(std::to_string(kPostinstallStatusFd));
#else
  // Chrome OS postinstall expects the target rootfs as the first parameter.
  command.push_back(partition.target_path);
#endif  // __ANDROID__

// 启动一个线程开始执行命令
  current_command_ = Subprocess::Get().ExecFlags(
      command,
      Subprocess::kRedirectStderrToStdout,
      {kPostinstallStatusFd},
      base::Bind(&PostinstallRunnerAction::CompletePartitionPostinstall,
                 base::Unretained(this)));
  // Subprocess::Exec should never return a negative process id.
  CHECK_GE(current_command_, 0);

```

```cpp
// The file descriptor number from the postinstall program's perspective where
// it can report status updates. This can be any number greater than 2 (stderr),
// but must be kept in sync with the "bin/postinst_progress" defined in the
// sample_images.sh file.
const int kPostinstallStatusFd = 3;
```

最终组装成的命令为：

```
"/postinstall/system/bin/otapreopt_script 1 3"
```

```shell
# 参数1  slot 
TARGET_SLOT="$1"
# 参数2 进度文件描述符（ > 2）
STATUS_FD="$2"

if [ "$TARGET_SLOT" = "0" ] ; then
  TARGET_SLOT_SUFFIX="_a"
elif [ "$TARGET_SLOT" = "1" ] ; then
  TARGET_SLOT_SUFFIX="_b"
else
  echo "Unknown target slot $TARGET_SLOT"
  exit 1
fi
```



```shell
PREPARE=$(cmd otadexopt prepare)
# Note: Ignore preparation failures. Step and done will fail and exit this.
#       This is necessary to support suspends - the OTA service will keep
#       the state around for us.

PROGRESS=$(cmd otadexopt progress)
print -u${STATUS_FD} "global_progress $PROGRESS"

i=0
while ((i<MAXIMUM_PACKAGES)) ; do
  #更新DEXOPT_PARAMS，就是下一个包名
  DEXOPT_PARAMS=$(cmd otadexopt next)

  /system/bin/otapreopt_chroot $STATUS_FD $TARGET_SLOT_SUFFIX $DEXOPT_PARAMS >&- 2>&-

  PROGRESS=$(cmd otadexopt progress)
  print -u${STATUS_FD} "global_progress $PROGRESS"

  DONE=$(cmd otadexopt done)
  if [ "$DONE" = "OTA incomplete." ] ; then
    sleep 1
    i=$((i+1))
    continue
  fi
  break
done
done
```

`cmd otadexopt prepare`是准备所有要做的dexopt指令。

`cmd otadexopt progress`是声明dexopt的进度。

`cmd otadexopt next` 是驱动执行dexopt的指令。

` /system/bin/otapreopt_chroot $STATUS_FD $TARGET_SLOT_SUFFIX $DEXOPT_PARAMS >&- 2>&-`

从列表里面挨个挨个取出`DEXOPT_PARAMS`。

```java
    public static OtaDexoptService main(Context context,
            PackageManagerService packageManagerService) {
        OtaDexoptService ota = new OtaDexoptService(context, packageManagerService);
        ServiceManager.addService("otadexopt", ota);
        // ... ...
        return ota;
    }
```

`OtaDexoptService`是这个服务载体。

`otadexopt`使用命令传参数，会调用`OtaDexoptShellCommand`（ShellCommand的子类）

```java
    @Override
    public int onCommand(String cmd) {
        if (cmd == null) {
            return handleDefaultCommands(null);
        }

        final PrintWriter pw = getOutPrintWriter();
        try {
            switch(cmd) {
                case "prepare":
                    return runOtaPrepare();
                case "cleanup":
                    return runOtaCleanup();
                case "done":
                    return runOtaDone();
                case "step":
                    return runOtaStep();
                case "next":
                    return runOtaNext();
                case "progress":
                    return runOtaProgress();
                default:
                    return handleDefaultCommands(cmd);
            }
        } catch (RemoteException e) {
            pw.println("Remote exception: " + e);
        }
        return -1;
    }
```

`runOtaNext`最终会调用`nextDexoptCommand`

```java
 @Override
    public synchronized String nextDexoptCommand() throws RemoteException {
        if (mDexoptCommands == null) {
            throw new IllegalStateException("dexoptNextPackage() called before prepare()");
        }

        if (mDexoptCommands.isEmpty()) {
            return "(all done)";
        }
		
        //移除第0位，把第1位提前到列表顶端
        String next = mDexoptCommands.remove(0);

        if (getAvailableSpace() > 0) {
            dexoptCommandCountExecuted++;
            current_time = System.currentTimeMillis();
            // 打印执行每个应用dexopt的时间消费
            Log.d(TAG, "Next command: " + next + ", previous command took : " + (current_time - previous_time) + " ms");
            previous_time = current_time;
            return next;
        } else {
            if (DEBUG_DEXOPT) {
                Log.w(TAG, "Not enough space for OTA dexopt, stopping with "
                        + (mDexoptCommands.size() + 1) + " commands left.");
            }
            mDexoptCommands.clear();
            return "(no free space)";
        }
    }
```

- `otapreopt_script`会遍历所有包名，调用`otapreopt_chroot`传入包名

- `otapreopt_chroot`里面集成调用`/system/bin/otapreopt`

- `/system/bin/otapreopt`调用`installd`的接口
- `installd`调用`dex2oat32`来做DexOpt

比如，以`ABC`应用为例：

```
06-08 12:01:49.680 D/OTADexopt( 1294): Next command: 10 dexopt /system/priv-app/ABC/ABC.apk 1000 com.xxxx.systemupdate arm64 -3 ! 6232 speed-profile ! PCL[]{} platform:privapp:targetSdkVersion=32 false 33 primary.prof ! ab-ota

06-08 12:01:50.438 V/installd(13071): Running /apex/com.android.art/bin/dex2oat32 in=ABC.apk out=/data/ota/_b/dalvik-cache/arm64/system@priv-app@ABC@ABC.apk@classes.dex
```



**如何定制OTA做dex优化的应用列表？**

应用列表来源：

```java
    public static final List<String> OTA_DEX_BLACK_LIST_OF_PACKAGES = List.of(
            "com.google.android.youtube",
            "com.google.android.apps.messaging",
            "com.google.android.googlequicksearchbox",
            "com.android.vending",
            "com.google.android.gm",
            "com.google.android.apps.maps",
            "com.google.android.apps.photos",
            "com.google.android.videos"
    );

@Override
    public synchronized void prepare() throws RemoteException {

        final List<PackageStateInternal> important;
        final List<PackageStateInternal> others;
        Predicate<PackageStateInternal> isPlatformPackage = pkgSetting ->
                PLATFORM_PACKAGE_NAME.equals(pkgSetting.getPkg().getPackageName());
        // Important: the packages we need to run with ab-ota compiler-reason.
        final Computer snapshot = mPackageManagerService.snapshotComputer();
        final Collection<? extends PackageStateInternal> allPackageStates =
                snapshot.getPackageStates().values();
        // 通过DexOptHelper.getPackagesForDexopt方法，获取系统认为重要的包名important
        important = DexOptHelper.getPackagesForDexopt(allPackageStates,mPackageManagerService,
                DEBUG_DEXOPT);

        // Remove Platform Package from A/B OTA b/160735835.
        // 移除包名为android的包
        important.removeIf(isPlatformPackage);
        
        // MY Customizations: 移除在OTA_DEX_BLACK_LIST_OF_PACKAGES列表中的元素
        // 这个列表是不算重要，但是做dex优化时间比较长的apk
        if(DexOptHelper.isOptimizationDexCR()){
            Predicate<PackageStateInternal> FilterPartialPackage = pkgSetting ->
                    OTA_DEX_BLACK_LIST_OF_PACKAGES.contains(pkgSetting.getPkg().getPackageName());
            important.removeIf(FilterPartialPackage);
        }
        // 此时important包含了所有我们想要 “在OTA阶段去做dex优化“ 的包名列表
		
        // Others: we should optimize this with the (first-)boot compiler-reason.
        others = new ArrayList<>(allPackageStates);
        others.removeAll(important);
        others.removeIf(PackageManagerServiceUtils.REMOVE_IF_NULL_PKG);
        others.removeIf(isPlatformPackage);
        // 此时others包含了所有我们想要 “放在OTA升级后开机阶段去做dex优化“ 的包名列表
```



`DexOptHelper.getPackagesForDexopt`是怎么界定**重要**的包名的？

```java
public final static Predicate<PackageStateInternal> REMOVE_IF_NULL_PKG =
            pkgSetting -> pkgSetting.getPkg() == null;    

/***
输入：
pkgSettings：初始包名集合
packageManagerService：PKMS
debug： 是否打印包名
****/
public static List<PackageStateInternal> getPackagesForDexopt(
            Collection<? extends PackageStateInternal> pkgSettings,
            PackageManagerService packageManagerService,
            boolean debug) {
        List<PackageStateInternal> result = new LinkedList<>();
        ArrayList<PackageStateInternal> remainingPkgSettings = new ArrayList<>(pkgSettings);

        // First, remove all settings without available packages
        // 从初始包名集合中，移除包名为空的process
        remainingPkgSettings.removeIf(REMOVE_IF_NULL_PKG);

    	// 建立存储remainingPkgSettings长度的sortTemp
        ArrayList<PackageStateInternal> sortTemp = new ArrayList<>(remainingPkgSettings.size());

        final Computer snapshot = packageManagerService.snapshotComputer();

    	// MY Customizations
        // Give priority to xxxx apps.
        // 如果是以"com.xxxx"开头，将排在sortTemp的第1梯队
        if (isOptimizationDexCR()) {
            applyPackageFilter(snapshot, pkgSetting -> pkgSetting.getPkg().getPackageName().startsWith("com.xxxx"), result,
                    remainingPkgSettings, sortTemp, packageManagerService);
        }

        // Give priority to core apps.
        // 如果是核心应用isCoreApp=true，将排在sortTemp的第2梯队
        applyPackageFilter(snapshot, pkgSetting -> pkgSetting.getPkg().isCoreApp(), result,
                remainingPkgSettings, sortTemp, packageManagerService);

        // Give priority to system apps that listen for pre boot complete.
        // 如果是监听ACTION_PRE_BOOT_COMPLETED广播的系统应用，将排在sortTemp的第3梯队
        Intent intent = new Intent(Intent.ACTION_PRE_BOOT_COMPLETED);
        final ArraySet<String> pkgNames = getPackageNamesForIntent(intent, UserHandle.USER_SYSTEM);
        applyPackageFilter(snapshot, pkgSetting -> pkgNames.contains(pkgSetting.getPackageName()), result,
                remainingPkgSettings, sortTemp, packageManagerService);

        // Give priority to apps used by other apps.
        // 如果是  这个应用被上面的核心应用使用过  并做了dex优化，将排在sortTemp的第4梯队
        DexManager dexManager = packageManagerService.getDexManager();
        applyPackageFilter(snapshot, pkgSetting ->
                        dexManager.getPackageUseInfoOrDefault(pkgSetting.getPackageName())
                                .isAnyCodePathUsedByOtherApps(),
                result, remainingPkgSettings, sortTemp, packageManagerService);

        // Filter out packages that aren't recently used, add all remaining apps.
        // TODO: add a property to control this?
        // 移除最近没有被使用过的应用列表，，剩余的apk将排在sortTemp的第5梯队
        Predicate<PackageStateInternal> remainingPredicate;
        if (!remainingPkgSettings.isEmpty()
                && packageManagerService.isHistoricalPackageUsageAvailable()) {
            if (debug) {
                Log.i(TAG, "Looking at historical package use");
            }
            // Get the package that was used last.
            PackageStateInternal lastUsed = Collections.max(remainingPkgSettings,
                    Comparator.comparingLong(
                            pkgSetting -> pkgSetting.getTransientState()
                                    .getLatestForegroundPackageUseTimeInMills()));
            if (debug) {
                Log.i(TAG, "Taking package " + lastUsed.getPackageName()
                        + " as reference in time use");
            }
            long estimatedPreviousSystemUseTime = lastUsed.getTransientState()
                    .getLatestForegroundPackageUseTimeInMills();
            // Be defensive if for some reason package usage has bogus data.
            if (estimatedPreviousSystemUseTime != 0) {
                final long cutoffTime = estimatedPreviousSystemUseTime - SEVEN_DAYS_IN_MILLISECONDS;
                remainingPredicate = pkgSetting -> pkgSetting.getTransientState()
                        .getLatestForegroundPackageUseTimeInMills() >= cutoffTime;
            } else {
                // No meaningful historical info. Take all.
                remainingPredicate = pkgSetting -> true;
            }
            sortPackagesByUsageDate(remainingPkgSettings, packageManagerService);
        } else {
            // No historical info. Take all.
            remainingPredicate = pkgSetting -> true;
        }
        applyPackageFilter(snapshot, remainingPredicate, result, remainingPkgSettings, sortTemp,
                packageManagerService);
     	// 此时，根据包名的邮箱策略，已经将应用根据1-5梯队优先级，已经确立好了，存放在result

        if (debug) {
            splitLog(TAG, "Packages to be dexopted: " + packagesToString(result));
            splitLog(TAG, "Packages skipped from dexopt: " + packagesToString(remainingPkgSettings));
        }

        return result;
    }
```

总结大致流程如下：

![OTA_dexopt](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/OTA_dexopt.jpg)

### 2.3 系统首次启动

开机启动的时候，`SystemServer.java`要启动服务群

```java
        // Manages A/B OTA dexopting. This is a bootstrap service as we need it to rename
        // A/B artifacts after boot, before anything else might touch/need them.
        // Note: this isn't needed during decryption (we don't have /data anyways).
        // 启动otadexopt服务
        if (!mOnlyCore) {
            boolean disableOtaDexopt = SystemProperties.getBoolean("config.disable_otadexopt",
                    false);
            if (!disableOtaDexopt) {
                t.traceBegin("StartOtaDexOptService");
                try {
                    Watchdog.getInstance().pauseWatchingCurrentThread("moveab");
                    OtaDexoptService.main(mSystemContext, mPackageManagerService);
                } catch (Throwable e) {
                    reportWtf("starting OtaDexOptService", e);
                } finally {
                    Watchdog.getInstance().resumeWatchingCurrentThread("moveab");
                    t.traceEnd();
                }
            }
        }
        
        //.....
       
       //调用PKMS的updatePackagesIfNeeded进行包更新
       if (!mOnlyCore) {
            t.traceBegin("UpdatePackagesIfNeeded");
            try {
                Watchdog.getInstance().pauseWatchingCurrentThread("dexopt");
                mPackageManagerService.updatePackagesIfNeeded();
            } catch (Throwable e) {
                reportWtf("update packages", e);
            } finally {
                Watchdog.getInstance().resumeWatchingCurrentThread("dexopt");
            }
            t.traceEnd();
        }
```

`PackageManagerService.java`

```java
    // 调用DexOptHelper的performPackageDexOptUpgradeIfNeeded
    public void updatePackagesIfNeeded() {
        mDexOptHelper.performPackageDexOptUpgradeIfNeeded();
    }
```

非常重要的类：`DexOptHelper.java`

开机的时候必然调用`performPackageDexOptUpgradeIfNeeded`方法。

```java
 @RequiresPermission(Manifest.permission.READ_DEVICE_CONFIG)
    public void performPackageDexOptUpgradeIfNeeded() {
        PackageManagerServiceUtils.enforceSystemOrRoot(
                "Only the system can request package update");

        // 由于SystemUI对于用户体验极其重要，所以不管如何，优先对其进行dexopt优化
        // The default is "true".
        if (!"false".equals(DeviceConfig.getProperty("runtime", "dexopt_system_ui_on_boot"))) {
            // System UI is important to user experience, so we check it after a mainline update or
            // an OTA. It may need to be re-compiled in these cases.
            if (hasBcpApexesChanged() || mPm.isDeviceUpgrading()) {
                checkAndDexOptSystemUi();
            }
        }

        // causeUpgrade：判断是否是OTA升级上来执行的dex opt。  判断依据是两次的buildFingerprint不一样才触发
        // We need to re-extract after an OTA.
        /****
            final VersionInfo ver = mSettings.getInternalVersion();
            mIsUpgrade =!buildFingerprint.equals(ver.fingerprint);
        ****/
        boolean causeUpgrade = mPm.isDeviceUpgrading();

        // First boot or factory reset.
        // Note: we also handle devices that are upgrading to N right now as if it is their
        //       first boot, as they do not have profile data.
        // causeFirstBoot： 如果是第一次开机（刷完机/恢复出厂设置之后）， 或者从Android N升级上来。
        boolean causeFirstBoot = mPm.isFirstBoot() || mPm.isPreNUpgrade();
        if (DEBUG_DEXOPT) {
            Log.d(TAG, "causeFirstBoot =" + causeFirstBoot + ", causeUpgrade=" + causeUpgrade);
        }

        //既不是OTA升级上来的， 也不是第一次开机，则return
        // 可以理解为，平时手动重启手机 就是这种情况。
        if (!causeUpgrade && !causeFirstBoot) {
            return;
        }
		
        // 接下来看看第一次开机重启是怎样的做dexopt的？
        final Computer snapshot = mPm.snapshotComputer();
        List<PackageStateInternal> pkgSettings =
                getPackagesForDexopt(snapshot.getPackageStates().values(), mPm);
		
        // MY Customizations
        // 只过滤com.xxxx开头的包， 以及如下list特定包名
        /****
            public static final List<String> FIRST_BOOT_WHITELIST_OF_PACKAGES = List.of(
            "com.android.systemui",
            "com.google.android.gms",
            "com.google.android.setupwizard",
            "com.android.launcher3",
            "com.android.settings"
    		);
        ****/
        if(isOptimizationDexCR()){
            Predicate<PackageStateInternal> fliterNonWhiteListPackage = pkgSetting ->
                    !pkgSetting.getPkg().getPackageName().startsWith("com.xxxx") && !FIRST_BOOT_WHITELIST_OF_PACKAGES.contains(pkgSetting.getPkg().getPackageName());
            pkgSettings.removeIf(fliterNonWhiteListPackage);
        }

        List<AndroidPackage> pkgs = new ArrayList<>(pkgSettings.size());
        for (int index = 0; index < pkgSettings.size(); index++) {
            pkgs.add(pkgSettings.get(index).getPkg());
        }

        if (DEBUG_DEXOPT) {
            for (int i = 0; i < pkgs.size(); i++) {
                Log.d(TAG, "performDexOptUpgrade pkgs[" + i + "]=" + pkgs.get(i).getPackageName());
            }
        }

        final long startTime = System.nanoTime();
        // 调用performDexOptUpgrade
        // 如果是Android N升级上来，需要弹出对话框，等待完成
        // 第一次开机： REASON_FIRST_BOOT
        // OTA升级上来开机： REASON_BOOT_AFTER_OTA
        final int[] stats = performDexOptUpgrade(pkgs, mPm.isPreNUpgrade() /* showDialog */,
                causeFirstBoot ? REASON_FIRST_BOOT : REASON_BOOT_AFTER_OTA,
                false /* bootComplete */);
        if (DEBUG_DEXOPT) {
            Log.d(TAG, "performDexOptUpgrade return stats =" + Arrays.toString(stats));
        }

        // 统计总共做dex优化各指标和时间
        final int elapsedTimeSeconds =
                (int) TimeUnit.NANOSECONDS.toSeconds(System.nanoTime() - startTime);

        final Computer newSnapshot = mPm.snapshotComputer();

        MetricsLogger.histogram(mPm.mContext, "opt_dialog_num_dexopted", stats[0]);
        MetricsLogger.histogram(mPm.mContext, "opt_dialog_num_skipped", stats[1]);
        MetricsLogger.histogram(mPm.mContext, "opt_dialog_num_failed", stats[2]);
        MetricsLogger.histogram(mPm.mContext, "opt_dialog_num_total",
                getOptimizablePackages(newSnapshot).size());
        MetricsLogger.histogram(mPm.mContext, "opt_dialog_time_s", elapsedTimeSeconds);
    }
```

`performDexOptUpgrade`也是非常重要的方法，分发DexOpt任务的

```java
/**
     * Performs dexopt on the set of packages in {@code packages} and returns an int array
     * containing statistics about the invocation. The array consists of three elements,
     * which are (in order) {@code numberOfPackagesOptimized}, {@code numberOfPackagesSkipped}
     * and {@code numberOfPackagesFailed}.
     */
/**
pkgs： 需要做dex优化的包名列表
showDialog：如果是Android N升级上来，需要弹出对话框，并等待完成 
compilationReason： 优化的理由，根据这个来选择用什么方式
bootComplete： 开机是否完成
**/
    public int[] performDexOptUpgrade(List<AndroidPackage> pkgs, boolean showDialog,
            final int compilationReason, boolean bootComplete) {
        int numberOfPackagesVisited = 0;
        int numberOfPackagesOptimized = 0;
        int numberOfPackagesSkipped = 0;
        int numberOfPackagesFailed = 0;
        final int numberOfPackagesToDexopt = pkgs.size();

        // 遍历所有包
        for (AndroidPackage pkg : pkgs) {
            numberOfPackagesVisited++;

            boolean useProfileForDexopt = false;
			// 再次从PKMS的角度 确认是否是：
            // 1. 首次开机
            // 2. 是否OTA升级上来的
            // 3. 必要条件： 包是系统应用
            if ((mPm.isFirstBoot() || mPm.isDeviceUpgrading()) && pkg.isSystem()) {
                // Copy over initial preopt profiles since we won't get any JIT samples for methods
                // that are already compiled.
                File profileFile = new File(getPrebuildProfilePath(pkg));
                // Copy profile if it exists.
                // 做dexopt选择哪个profile？
                if (profileFile.exists()) {
                   // ... ...
                } else {
                   // ... ...
                }
            }

            // 通过canOptimizePackage方法，部分应用不支持做dexopt的过滤掉
            if (!mPm.mPackageDexOptimizer.canOptimizePackage(pkg)) {
                if (DEBUG_DEXOPT) {
                    Log.i(TAG, "Skipping update of non-optimizable app " + pkg.getPackageName());
                }
                numberOfPackagesSkipped++;
                continue;
            }

            if (DEBUG_DEXOPT) {
                Log.i(TAG, "Updating app " + numberOfPackagesVisited + " of "
                        + numberOfPackagesToDexopt + ": " + pkg.getPackageName());
            }

            //如果是Android N升级上来，需要弹出对话框，并等待完成 
            if (showDialog) {
                try {
                    ActivityManager.getService().showBootMessage(
                            mPm.mContext.getResources().getString(R.string.android_upgrading_apk,
                                    numberOfPackagesVisited, numberOfPackagesToDexopt), true);
                } catch (RemoteException e) {
                }
                synchronized (mLock) {
                    mDexOptDialogShown = true;
                }
            }
			//  ... ...

            // checkProfiles is false to avoid merging profiles during boot which
            // might interfere with background compilation (b/28612421).
            // Unfortunately this will also means that "pm.dexopt.boot=speed-profile" will
            // behave differently than "pm.dexopt.bg-dexopt=speed-profile" but that's a
            // trade-off worth doing to save boot time work.
            int dexoptFlags = bootComplete ? DexoptOptions.DEXOPT_BOOT_COMPLETE : 0;
            if (compilationReason == REASON_FIRST_BOOT) {
                // TODO: This doesn't cover the upgrade case, we should check for this too.
                dexoptFlags |= DexoptOptions.DEXOPT_INSTALL_WITH_DEX_METADATA_FILE;
            }
            // 进入下一个方法：performDexOptTraced
            // 输入是 DexoptOptions， 这个类基本涵括了dexopt的信息
            int primaryDexOptStatus = performDexOptTraced(new DexoptOptions(
                    pkg.getPackageName(),
                    pkgCompilationReason,
                    dexoptFlags));

            switch (primaryDexOptStatus) {
                case PackageDexOptimizer.DEX_OPT_PERFORMED:
                    numberOfPackagesOptimized++;
                    break;
                case PackageDexOptimizer.DEX_OPT_SKIPPED:
                    numberOfPackagesSkipped++;
                    break;
                case PackageDexOptimizer.DEX_OPT_CANCELLED:
                    // ignore this case
                    break;
                case PackageDexOptimizer.DEX_OPT_FAILED:
                    numberOfPackagesFailed++;
                    break;
                default:
                    Log.e(TAG, "Unexpected dexopt return code " + primaryDexOptStatus);
                    break;
            }
        }

        return new int[]{numberOfPackagesOptimized, numberOfPackagesSkipped,
                numberOfPackagesFailed};
    }
```

`performDexOptTraced`

```java
    private int performDexOptTraced(DexoptOptions options) {
        /// M: Add for Mtprof tool
        mPm.sMtkSystemServerIns.addBootEvent("PMS:performDexOpt:" + options.getPackageName());
        Trace.traceBegin(TRACE_TAG_PACKAGE_MANAGER, "dexopt");
        try {
            return performDexOptInternal(options);
        } finally {
            Trace.traceEnd(TRACE_TAG_PACKAGE_MANAGER);
        }
    }
```

`performDexOptInternal`

```java
    // Run dexopt on a given package. Returns true if dexopt did not fail, i.e.
    // if the package can now be considered up to date for the given filter.
    private int performDexOptInternal(DexoptOptions options) {
        AndroidPackage p;
        PackageSetting pkgSetting;
        synchronized (mPm.mLock) {
            p = mPm.mPackages.get(options.getPackageName());
            pkgSetting = mPm.mSettings.getPackageLPr(options.getPackageName());
            if (p == null || pkgSetting == null) {
                // Package could not be found. Report failure.
                return PackageDexOptimizer.DEX_OPT_FAILED;
            }
            mPm.getPackageUsage().maybeWriteAsync(mPm.mSettings.getPackagesLocked());
            mPm.mCompilerStats.maybeWriteAsync();
        }
        final long callingId = Binder.clearCallingIdentity();
        try {
            return performDexOptInternalWithDependenciesLI(p, pkgSetting, options);
        } finally {
            Binder.restoreCallingIdentity(callingId);
        }
    }
```

`performDexOptInternalWithDependenciesLI`

```java
    private int performDexOptInternalWithDependenciesLI(AndroidPackage p,
            @NonNull PackageStateInternal pkgSetting, DexoptOptions options) {
        // System server gets a special path.
        // 如果是android system server进程，直接使用dexoptSystemServer来做优化
        if (PLATFORM_PACKAGE_NAME.equals(p.getPackageName())) {
            return mPm.getDexManager().dexoptSystemServer(options);
        }

        // Select the dex optimizer based on the force parameter.
        // Note: The force option is rarely used (cmdline input for testing, mostly), so it's OK to
        //       allocate an object here.
        PackageDexOptimizer pdo = options.isForce()
                ? new PackageDexOptimizer.ForcedUpdatePackageDexOptimizer(mPm.mPackageDexOptimizer)
                : mPm.mPackageDexOptimizer;

        // Dexopt all dependencies first. Note: we ignore the return value and march on
        // on errors.
        // Note that we are going to call performDexOpt on those libraries as many times as
        // they are referenced in packages. When we do a batch of performDexOpt (for example
        // at boot, or background job), the passed 'targetCompilerFilter' stays the same,
        // and the first package that uses the library will dexopt it. The
        // others will see that the compiled code for the library is up to date.
        Collection<SharedLibraryInfo> deps = SharedLibraryUtils.findSharedLibraries(pkgSetting);
        final String[] instructionSets = getAppDexInstructionSets(
                AndroidPackageUtils.getPrimaryCpuAbi(p, pkgSetting),
                AndroidPackageUtils.getSecondaryCpuAbi(p, pkgSetting));
        if (!deps.isEmpty()) {
            DexoptOptions libraryOptions = new DexoptOptions(options.getPackageName(),
                    options.getCompilationReason(), options.getCompilerFilter(),
                    options.getSplitName(),
                    options.getFlags() | DexoptOptions.DEXOPT_AS_SHARED_LIBRARY);
            for (SharedLibraryInfo info : deps) {
                AndroidPackage depPackage = null;
                PackageSetting depPackageSetting = null;
                synchronized (mPm.mLock) {
                    depPackage = mPm.mPackages.get(info.getPackageName());
                    depPackageSetting = mPm.mSettings.getPackageLPr(info.getPackageName());
                }
                if (depPackage != null && depPackageSetting != null) {
                    // TODO: Analyze and investigate if we (should) profile libraries.
                    // 真正干活的方法：pdo.performDexOpt
                    pdo.performDexOpt(depPackage, depPackageSetting, instructionSets,
                            mPm.getOrCreateCompilerPackageStats(depPackage),
                            mPm.getDexManager().getPackageUseInfoOrDefault(
                                    depPackage.getPackageName()), libraryOptions);
                } else {
                    // TODO(ngeoffray): Support dexopting system shared libraries.
                }
            }
        }
		// 真正干活的方法：pdo.performDexOpt
        return pdo.performDexOpt(p, pkgSetting, instructionSets,
                mPm.getOrCreateCompilerPackageStats(p),
                mPm.getDexManager().getPackageUseInfoOrDefault(p.getPackageName()), options);
    }
```

`PackageDexOptimizer.java`

```java
    /**
     * Performs dexopt on all code paths and libraries of the specified package for specified
     * instruction sets.
     *
     * <p>Calls to {@link com.android.server.pm.Installer#dexopt} on {@link #mInstaller} are
     * synchronized on {@link #mInstallLock}.
     */
     /**
     pkg： 包名
     pkgSetting： 包设置信息
     instructionSets： 这个决定是PrimaryCpuAbi还是SecondaryCpuAbi
     packageUseInfo： 包使用信息
     options： dexopt详细信息
     */
    @DexOptResult
    int performDexOpt(AndroidPackage pkg, @NonNull PackageStateInternal pkgSetting,
            String[] instructionSets, CompilerStats.PackageStats packageStats,
            PackageDexUsage.PackageUseInfo packageUseInfo, DexoptOptions options) {
        if (PLATFORM_PACKAGE_NAME.equals(pkg.getPackageName())) {
            throw new IllegalArgumentException("System server dexopting should be done via "
                    + " DexManager and PackageDexOptimizer#dexoptSystemServerPath");
        }
        if (pkg.getUid() == -1) {
            throw new IllegalArgumentException("Dexopt for " + pkg.getPackageName()
                    + " has invalid uid.");
        }
        if (!canOptimizePackage(pkg)) {
            return DEX_OPT_SKIPPED;
        }

        synchronized (mInstallLock) {
            final long acquireTime = acquireWakeLockLI(pkg.getUid());
            try {
                    return performDexOptLI(pkg, pkgSetting, instructionSets,
                        packageStats, packageUseInfo, options);
            } finally {
                releaseWakeLockLI(acquireTime);
            }
        }
    }
```

`performDexOptLI`

```java
/**
     * Performs dexopt on all code paths of the given package.
     * It assumes the install lock is held.
     */
    @GuardedBy("mInstallLock")
    @DexOptResult
    private int performDexOptLI(AndroidPackage pkg, @NonNull PackageStateInternal pkgSetting,
            String[] targetInstructionSets, CompilerStats.PackageStats packageStats,
            PackageDexUsage.PackageUseInfo packageUseInfo, DexoptOptions options) {
                // ... ...
                // Get the dexopt flags after getRealCompilerFilter to make sure we get the correct
                // flags.
                final int dexoptFlags = getDexFlags(pkg, pkgSetting, compilerFilter,
                        useCloudProfile, options);
				// ... ...
                for (String dexCodeIsa : dexCodeInstructionSets) {
                    // 启动dexopt最后的类
                    int newResult = dexOptPath(pkg, pkgSetting, path, dexCodeIsa, compilerFilter,
                            profileAnalysisResult, classLoaderContexts[i], dexoptFlags, sharedGid,
                            packageStats, options.isDowngrade(), profileName, dexMetadataPath,
                            options.getCompilationReason());
				// ... ...
                    if ((result != DEX_OPT_FAILED) && (newResult != DEX_OPT_SKIPPED)) {
                        result = newResult;
                    }
                }
				// ... ...
        return result;
    }

```

`dexOptPath`

```java
 /**
     * Performs dexopt on the {@code path} belonging to the package {@code pkg}.
     *
     * @return
     *      DEX_OPT_FAILED if there was any exception during dexopt
     *      DEX_OPT_PERFORMED if dexopt was performed successfully on the given path.
     *      DEX_OPT_SKIPPED if the path does not need to be deopt-ed.
     */
    @GuardedBy("mInstallLock")
    @DexOptResult
    private int dexOptPath(AndroidPackage pkg, @NonNull PackageStateInternal pkgSetting,
            String path, String isa, String compilerFilter, int profileAnalysisResult,
            String classLoaderContext, int dexoptFlags, int uid,
            CompilerStats.PackageStats packageStats, boolean downgrade, String profileName,
            String dexMetadataPath, int compilationReason) {

        Log.i(TAG, "Running dexopt (dexoptNeeded=" + dexoptNeeded + ") on: " + path
                + " pkg=" + pkg.getPackageName() + " isa=" + isa
                + " dexoptFlags=" + printDexoptFlags(dexoptFlags)
                + " targetFilter=" + compilerFilter + " oatDir=" + oatDir
                + " classLoaderContext=" + classLoaderContext);

        try {
            long startTime = System.currentTimeMillis();

            // TODO: Consider adding 2 different APIs for primary and secondary dexopt.
            // installd only uses downgrade flag for secondary dex files and ignores it for
            // primary dex files.
            String seInfo = AndroidPackageUtils.getSeInfo(pkg, pkgSetting);
            // 调用Installer的dexopt方法
            boolean completed = getInstallerLI().dexopt(path, uid, pkg.getPackageName(), isa,
                    dexoptNeeded, oatDir, dexoptFlags, compilerFilter, pkg.getVolumeUuid(),
                    classLoaderContext, seInfo, /* downgrade= */ false ,
                    pkg.getTargetSdkVersion(), profileName, dexMetadataPath,
                    getAugmentedReasonName(compilationReason, dexMetadataPath != null));

            if (packageStats != null) {
                long endTime = System.currentTimeMillis();
                packageStats.setCompileTime(path, (int)(endTime - startTime));
                //@xxxx-begin [JAZZ_192285]
                spentDexCompileTime += (endTime - startTime);
                // 打印这个apk的dexopt时间
                Log.d(TAG,"[dex2oat compiling time]: "+ pkg.getPackageName() + ":[" + (endTime - startTime)
                        + " ms] , total:[" + spentDexCompileTime + " ms]");
                //@xxxx-end [JAZZ_192285]
            }
            
    }
```

`Installer.java`

```java
    /**
     * Runs dex optimization.
     *
     * @param apkPath Path of target APK
     * @param uid UID of the package
     * @param pkgName Name of the package
     * @param instructionSet Target instruction set to run dex optimization.
     * @param dexoptNeeded Necessary dex optimization for this request. Check
     *        {@link dalvik.system.DexFile#NO_DEXOPT_NEEDED},
     *        {@link dalvik.system.DexFile#DEX2OAT_FROM_SCRATCH},
     *        {@link dalvik.system.DexFile#DEX2OAT_FOR_BOOT_IMAGE}, and
     *        {@link dalvik.system.DexFile#DEX2OAT_FOR_FILTER}.
     * @param outputPath Output path of generated dex optimization.
     * @param dexFlags Check {@code DEXOPT_*} for allowed flags.
     * @param compilerFilter Compiler filter like "verify", "speed-profile". Check
     *                       {@code art/libartbase/base/compiler_filter.cc} for full list.
     * @param volumeUuid UUID of the volume where the package data is stored. {@code null}
     *                   represents internal storage.
     * @param classLoaderContext This encodes the class loader chain (class loader type + class
     *                           path) in a format compatible to dex2oat. Check
     *                           {@code DexoptUtils.processContextForDexLoad} for further details.
     * @param seInfo Selinux context to set for generated outputs.
     * @param downgrade If set, allows downgrading {@code compilerFilter}. If downgrading is not
     *                  allowed and requested {@code compilerFilter} is considered as downgrade,
     *                  the request will be ignored.
     * @param targetSdkVersion Target SDK version of the package.
     * @param profileName Name of reference profile file.
     * @param dexMetadataPath Specifies the location of dex metadata file.
     * @param compilationReason Specifies the reason for the compilation like "install".
     * @return {@code true} if {@code dexopt} is completed. {@code false} if it was cancelled.
     *
     * @throws InstallerException if {@code dexopt} fails.
     */
    public boolean dexopt(String apkPath, int uid, String pkgName, String instructionSet,
            int dexoptNeeded, @Nullable String outputPath, int dexFlags,
            String compilerFilter, @Nullable String volumeUuid, @Nullable String classLoaderContext,
            @Nullable String seInfo, boolean downgrade, int targetSdkVersion,
            @Nullable String profileName, @Nullable String dexMetadataPath,
            @Nullable String compilationReason) throws InstallerException {
        //IBinder binder = ServiceManager.getService("installd");
        return mInstalld.dexopt(apkPath, uid, pkgName, instructionSet, dexoptNeeded, outputPath,
                    dexFlags, compilerFilter, volumeUuid, classLoaderContext, seInfo, downgrade,
                    targetSdkVersion, profileName, dexMetadataPath, compilationReason);
    }
```



`Installer.java`通过**Binder**调用`installd`

`installd`是著名的一个PKMS相关的native service， 里面有专门做DexOpt的入口

实质上还会调用了dex2oat去做实际的代码优化工作以及ART虚拟机。

这一层比较接近底层虚拟机的工作原理。如果感兴趣，可以执行研究。



总结：

![First_boot_dexopt](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/First_boot_dexopt.jpg)

- 决定是否是第一次开机/OTA升级上来的方法：`performPackageDexOptUpgradeIfNeeded`
- 传入包list和过滤重要包的方法： `performPackageDexOptUpgradeIfNeeded`
- 遍历包list的方法：`performDexOptUpgrade`
- 从`performDexOptTraced`开始就是处理单独一个包的方法



### 2.4 系统非首次启动

从上一节可以看出，

- 首次启动： 调用`updatePackagesIfNeeded`会走完流程。
- 非首次启动：而非首次启动/OTA升级，则会直接return掉。

```java
        if (!causeUpgrade && !causeFirstBoot) {
            return;
        }
```

那么普通开机会做部分应用做dexopt优化吗？



先说一下Android 6.0的时候，开机会默认对热应用做dexopt，调用PKMS的`performBootDexOpt`方法

```java
private void startOtherServices() {
    //...
    mPackageManagerService.performBootDexOpt();
    //...  
}
```

有一个参数`mDexOptLRUThresholdInMills`用于决定执行dex优化操作的时间阈，这个参数用于后续的`PKMS.performBootDexOp`过程。

- 对于Eng版本，则只会对30分钟之内使用过的app执行dex优化；
- 对于非Eng版本，则会将用户最近一周内使用过的app执行dex优化；

![image-20240726180110019](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240726180110019.png)

在Android 6.0版本中， `performBootDexOpt`的作用主要有：

1. 判断是否需要磁盘维护，这是通过 `fstrim` 命令完成的

   ![image-20240726180304172](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240726180304172.png)

2. 调用 dexopt 优化核心应用、监听预启动完成的系统应用和近期使用的应用，包优化是通过调用 `performBootDexOpt` 函数的重载版本完成的

   ![image-20240726180352146](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240726180352146.png)

![image-20240731164528410](/home/dl.net/ldeng/.config/Typora/typora-user-images/image-20240731164528410.png)



Android 7及以后的版本中，没有见到`performBootDexOpt`了，应该是被评估删掉了。

至于为什么不选择在开机阶段做了？

我猜大概率是因为随着应用的升级，包越来越大，如果安装的应用多，每次开机都很慢，这个`performBootDexOpt`的缺点就很大。

可以放在开机后，由`BackgroundDexOptService`去做dexopt，这样就可以平衡开机时间和应用的性能表现。



所以，Android 10 - Android 12的代码中，只剩下磁盘数据修剪的操作了。

```java
        t.traceBegin("PerformFstrimIfNeeded");
        try {
            mPackageManagerService.performFstrimIfNeeded();
        } catch (Throwable e) {
            reportWtf("performing fstrim", e);
        }
        t.traceEnd();
```



```java
public void performFstrimIfNeeded() {
        // ...
                final long interval = android.provider.Settings.Global.getLong(
                        mContext.getContentResolver(),
                        android.provider.Settings.Global.FSTRIM_MANDATORY_INTERVAL,
                        DEFAULT_MANDATORY_FSTRIM_INTERVAL);
                if (interval > 0) {
                    final long timeSinceLast = System.currentTimeMillis() - sm.lastMaintenance();
                    if (timeSinceLast > interval) {
                        doTrim = true;
                        Slog.w(TAG, "No disk maintenance in " + timeSinceLast
                                + "; running immediately");
                    }
                }
                if (doTrim) {
                    if (!isFirstBoot()) {
                        if (mDexOptHelper.isDexOptDialogShown()) {
                            try {
                                ActivityManager.getService().showBootMessage(
                                        mContext.getResources().getString(
                                                R.string.android_upgrading_fstrim), true);
                            } catch (RemoteException e) {
                            }
                        }
                    }
                    sm.runMaintenance();
                }
          // ...  
    }
```



总结

- Android 6的非首次开机做DexOpt的流程。

![image-20240726182035589](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240726182035589.png)



- Android 7 及以后不再非首次开机阶段做DexOpt了。



### 2.5 系统空闲

由于非首次开机阶段不再更新DexOpt，这个很影响开机速度，最终将这个工作移至开机后使用后台服务`BackgroundDexOptService`来做，也是相对合理的。

现在主要讲解一下`BackgroundDexOptService`是如何在空闲状态做dex优化的。

首先，`SystemServer`启动`PackageManagerService`， 然后PKMS启动`BackgroundDexOptService`。

`PackageManagerService.java`

```java
final BackgroundDexOptService mBackgroundDexOptService;
... main(){
	(i, pm) -> new BackgroundDexOptService(i.getContext(), i.getDexManager(), pm),
}
public void systemReady() {
    mBackgroundDexOptService.systemReady();
}
```

调用BackgroundDexOptService.的systemReady

`BackgroundDexOptService.java`

```java
    /** Start scheduling job after boot completion */
    public void systemReady() {
        if (mInjector.isBackgroundDexOptDisabled()) {
            return;
        }

        // 监听开机广播 Intent.ACTION_BOOT_COMPLETED
        mInjector.getContext().registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                mInjector.getContext().unregisterReceiver(this);
                // queue both job. JOB_IDLE_OPTIMIZE will not start until JOB_POST_BOOT_UPDATE is
                // completed.
                // 启动计划任务JOB_POST_BOOT_UPDATE ： 开机后更新
                scheduleAJob(JOB_POST_BOOT_UPDATE);
                // 启动计划任务JOB_IDLE_OPTIMIZE ： 空闲状态下更新
                scheduleAJob(JOB_IDLE_OPTIMIZE); 
                // MY Customizations : 启动计划任务JOB_POST_BOOT_UPDATE_CR
                if (isOptimizationDexCR()) {
                    scheduleAJobOneway(JOB_POST_BOOT_UPDATE_CR, DEX_OPT_AFTER_BOOT_DEALY_MS);
                }
                if (DEBUG) {
                    Slog.d(TAG, "BootBgDexopt scheduled");
                }
            }
        }, new IntentFilter(Intent.ACTION_BOOT_COMPLETED));
    }
```



```java
	private static final long IDLE_OPTIMIZATION_PERIOD = TimeUnit.DAYS.toMillis(1);    
	private void scheduleAJob(int jobId) {
        JobScheduler js = mInjector.getJobScheduler();
        JobInfo.Builder builder =
                new JobInfo.Builder(jobId, sDexoptServiceName).setRequiresDeviceIdle(true);
        // 如果是任务JOB_IDLE_OPTIMIZE，需要满足充电条件，并且设置每天检查一次
        if (jobId == JOB_IDLE_OPTIMIZE) {
            builder.setRequiresCharging(true).setPeriodic(IDLE_OPTIMIZATION_PERIOD);
        }
        js.schedule(builder.build());
    }
```



简要总结一下，这些任务的触发条件

|                         | 空闲判断 | 充电判断 | 触发时机       |
| ----------------------- | -------- | -------- | -------------- |
| JOB_IDLE_OPTIMIZE       | √        | √        | 1次/day        |
| JOB_POST_BOOT_UPDATE    | √        | ×        | 开机后         |
| JOB_POST_BOOT_UPDATE_CR | ×        | ×        | 开机后3min以内 |

以上是Android13的触发条件。



查看Android8～Android11的触发条件：

![image-20240729110636430](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240729110636430.png)

- `JOB_POST_BOOT_UPDATE`执行条件：

  开机一分钟内

- `JOB_IDLE_OPTIMIZE`执行条件：

  设备处于空闲，插入充电器，且每一天就检查一次

|                      | 空闲判断 | 充电判断 | 触发时机       |
| -------------------- | -------- | -------- | -------------- |
| JOB_IDLE_OPTIMIZE    | √        | √        | 1次/day        |
| JOB_POST_BOOT_UPDATE | ×        | ×        | 开机后1min以内 |



查看Android12的触发条件：

![image-20240729110605511](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240729110605511.png)

|                      | 空闲判断 | 充电判断 | 触发时机                  |
| -------------------- | -------- | -------- | ------------------------- |
| JOB_IDLE_OPTIMIZE    | √        | √        | 1次/day                   |
| JOB_POST_BOOT_UPDATE | ×        | ×        | 开机后10min-60min左右启动 |



从Android8 ～ Android13， 对于` JOB_IDLE_OPTIMIZE`的判断是没有特别大的区别。

但对于`JOB_POST_BOOT_UPDATE`的判断和界定，就有2次变革：

Android11及以前的，只需要开机1min左右就立即做dexopt遍历 ；

Android12改为开机10min以后做dexopt遍历；

Android13和Android14改为开机后，识别到空闲就做dexopt遍历。

> 大概猜测，谷歌在Android12以前，已经意识到了。一开机做dexopt会一定程度影响到手机刚开机几分钟的性能/功耗。
>
> 所以在Android12把时间推后了，变成10分钟以后。
>
> 到了Android13干脆把时间这个变量去除了，判断是空闲即触发，实测要休眠后30分钟左右才触发。



我们接着查看，是怎么执行dexopt的。

定制核心回调`onStartJob`：

```java
/** For BackgroundDexOptJobService to dispatch onStartJob event */
    /* package */ boolean onStartJob(BackgroundDexOptJobService job, JobParameters params) {
        Slog.i(TAG, "onStartJob:" + params.getJobId());

        boolean isPostBootUpdateJob = params.getJobId() == JOB_POST_BOOT_UPDATE;

        boolean isPostBootUpdateJobDL = params.getJobId() == JOB_POST_BOOT_UPDATE_CR;

        //mtk修改： 保存dalvik.vm.****属性原来的值
        //mtk modify start
        String dex2oat_threads = SystemProperties.get("dalvik.vm.background-dex2oat-threads");
        String cpu_set = SystemProperties.get("dalvik.vm.background-dex2oat-cpu-set");
        //mtk modify end
        // NOTE: PackageManagerService.isStorageLow uses a different set of criteria from
        // the checks above. This check is not "live" - the value is determined by a background
        // restart with a period of ~1 minute.
        PackageManagerService pm = mInjector.getPackageManagerService();
        // 确保存储是否够
        if (pm.isStorageLow()) {
            Slog.w(TAG, "Low storage, skipping this run");
            markPostBootUpdateCompleted(params);
            return false;
        }

        //获取需要做dex优化的包名排序，又是调用DexOptHelper.getOptimizablePackages
        List<String> pkgs = mDexOptHelper.getOptimizablePackages(pm.snapshotComputer());
        if (pkgs.isEmpty()) {
            Slog.i(TAG, "No packages to optimize");
            markPostBootUpdateCompleted(params);
            return false;
        }

        // 确保是否触发温控
        mThermalStatusCutoff = mInjector.getDexOptThermalCutoff();

        synchronized (mLock) {
            if (mDexOptThread != null && mDexOptThread.isAlive()) {
                // Other task is already running.
                return false;
            }
            // 确保还没做，或者正在做其中一个
            if (!isPostBootUpdateJob && !mFinishedPostBootUpdate && !isPostBootUpdateJobDL) {
                // Post boot job not finished yet. Run post boot job first.
                return false;
            }
            // mtk修改： 将做dex优化dalvik.vm.****属性值，在这个dexopt过程中修改为想要的值
            //mtk modify start for idle dex2oat change cup-set and threads
            if (!isPostBootUpdateJob || isPostBootUpdateJobDL) {
                // 设置最大启用4个线程
                SystemProperties.set("dalvik.vm.background-dex2oat-threads", "4");
                // 设置跑在 0,1,2,3 核上
                SystemProperties.set("dalvik.vm.background-dex2oat-cpu-set", "0,1,2,3");
                Slog.i(TAG, "background-dex2oat-threads = " + SystemProperties.get("dalvik.vm.background-dex2oat-threads")
                       + " background-dex2oat-cpu-set = " + SystemProperties.get("dalvik.vm.background-dex2oat-cpu-set"));
            }
            //mtk modify end
            resetStatesForNewDexOptRunLocked(mInjector.createAndStartThread(
                    "BackgroundDexOptService_" + (isPostBootUpdateJob ? "PostBoot" : "Idle"),
                    () -> {
                        TimingsTraceAndSlog tr =
                                new TimingsTraceAndSlog(TAG, Trace.TRACE_TAG_PACKAGE_MANAGER);
                        tr.traceBegin("jobExecution");
                        boolean completed = false;
                        try {
                            //MY Customizations begin
                            /*completed = runIdleOptimization(
                                    pm, pkgs, isPostBootUpdateJob);*/
                            if (isPostBootUpdateJobDL) {
                                
                                // MY Customizations：弹出通知栏，提醒用户正在做dexopt,可能影响性能
                                startNotificationDuringDex();
                                // 同步调用runIdleOptimization真正干活的方法
                                completed = runIdleOptimization(
                                        pm, pkgs, isPostBootUpdateJobDL);
                                // 等待结束，取消通知栏
                                cancelNotificationCompleted();
                                mInjector.getJobScheduler().cancel(JOB_POST_BOOT_UPDATE_CR);
                                if (DEBUG) {
                                    Slog.i(TAG,"All DL boot-dexopt is completed, JOB_POST_BOOT_UPDATE_CR should be cancled!");
                                }
                            } else {
                                // 原生行为：
                                completed = runIdleOptimization(
                                        pm, pkgs, isPostBootUpdateJob);
                            }
                           //MY Customizations end
                        } finally { // Those cleanup should be done always.
                            tr.traceEnd();
                            Slog.i(TAG,
                                    "dexopt finishing. jobid:" + params.getJobId()
                                            + " completed:" + completed);

                            writeStatsLog(params);

                            if (isPostBootUpdateJob && !isPostBootUpdateJobDL) {
                                if (completed) {
                                    markPostBootUpdateCompleted(params);
                                }
                                // Reschedule when cancelled
                                job.jobFinished(params, !completed);
                            } else {
                              //mtk 修改：执行完成之后，将dalvik.vm.****属性值改回来
                              //mtk modify start recover
                                SystemProperties.set("dalvik.vm.background-dex2oat-threads", dex2oat_threads);
                                SystemProperties.set("dalvik.vm.background-dex2oat-cpu-set", cpu_set);
                              //mtk modify end
                                // Periodic job
                                job.jobFinished(params, true);
                            }
                            markDexOptCompleted();
                        }
                    }));
        }
        return true;
    }
```

**mtk为什么要定制为绑定为小核运行？**

主要是限制dexopt执行的cpu资源，不然可能导致系统卡顿。宁可时间长点，也不要影响用户体验。

创建`dalvik.vm.****`属性，可以认为是谷歌提供给了厂商定制的性能的接口，毕竟这一块要结合平台cpu的能力而定。



从这份抓取的这个systrace来看，

以下紫色部分为dex2oat线程，在做dexopt的过程中，确实跑在小核。

![image-20240729113748864](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240729113748864.png)



接下来，查看下`runIdleOptimization`的调用流程：

```java
    /**
     * Returns whether we've successfully run the job. Note that it will return true even if some
     * packages may have failed compiling.
     */
    private boolean runIdleOptimization(
            PackageManagerService pm, List<String> pkgs, boolean isPostBootUpdate) {
        synchronized (mLock) {
            mLastExecutionStartTimeMs = SystemClock.elapsedRealtime();
            mLastExecutionDurationIncludingSleepMs = -1;
            mLastExecutionStartUptimeMs = SystemClock.uptimeMillis();
            mLastExecutionDurationMs = -1;
        }
        long lowStorageThreshold = getLowStorageThreshold();
        //核心方法：idleOptimizePackages
        int status = idleOptimizePackages(pm, pkgs, lowStorageThreshold, isPostBootUpdate);
        //收集dexopt的详细信息
        logStatus(status);
        synchronized (mLock) {
            mLastExecutionStatus = status;
            mLastExecutionDurationIncludingSleepMs =
                    SystemClock.elapsedRealtime() - mLastExecutionStartTimeMs;
            mLastExecutionDurationMs = SystemClock.uptimeMillis() - mLastExecutionStartUptimeMs;
        }

        return status == STATUS_OK || status == STATUS_DEX_OPT_FAILED;
    }
```

`idleOptimizePackages`

```java
 @Status
    private int idleOptimizePackages(PackageManagerService pm, List<String> pkgs,
            long lowStorageThreshold, boolean isPostBootUpdate) {
        ArraySet<String> updatedPackages = new ArraySet<>();

        try {
			// 如果空间不充足，不会针对没有使用过的应用做dexopt
            // Only downgrade apps when space is low on device.
            // Threshold is selected above the lowStorageThreshold so that we can pro-actively clean
            // up disk before user hits the actual lowStorageThreshold.
            long lowStorageThresholdForDowngrade =
                    LOW_THRESHOLD_MULTIPLIER_FOR_DOWNGRADE * lowStorageThreshold;
            boolean shouldDowngrade = shouldDowngrade(lowStorageThresholdForDowngrade);
            if (DEBUG) {
                Slog.d(TAG, "Should Downgrade " + shouldDowngrade);
            }
            if (shouldDowngrade) {
                final Computer snapshot = pm.snapshotComputer();
                Set<String> unusedPackages =
                        snapshot.getUnusedPackages(mDowngradeUnusedAppsThresholdInMillis);
                if (DEBUG) {
                    Slog.d(TAG, "Unsused Packages " + String.join(",", unusedPackages));
                }

                if (!unusedPackages.isEmpty()) {
                   
                    }

                    pkgs = new ArrayList<>(pkgs);
                    // 移除未使用的Packages
                    pkgs.removeAll(unusedPackages);
                }
            }

            // 核心方法：optimizePackages
            return optimizePackages(pkgs, lowStorageThreshold, updatedPackages, isPostBootUpdate);
        } finally {
            // Always let the pinner service know about changes.
            notifyPinService(updatedPackages);
            // Only notify IORap the primary dex opt, because we don't want to
            // invalidate traces unnecessary due to b/161633001 and that it's
            // better to have a trace than no trace at all.
            notifyPackagesUpdated(updatedPackages);
        }
    }
```

`optimizePackages`

```java
@Status
    private int optimizePackages(List<String> pkgs, long lowStorageThreshold,
            ArraySet<String> updatedPackages, boolean isPostBootUpdate) {
        boolean supportSecondaryDex = mInjector.supportSecondaryDex();

        //  ... ...
        // Keep the error if there is any error from any package.
        @Status int status = STATUS_OK;

        // Other than cancellation, all packages will be processed even if an error happens
        // in a package.
        // 遍历updatedPackages
        for (String pkg : pkgs) {
            // Primary Apk ： 常规场景
            // Secondary Apk ： 插件场景
           
            @DexOptResult
            int primaryResult = optimizePackage(pkg, true /* isForPrimaryDex */, isPostBootUpdate);

            @DexOptResult
            int secondaryResult =
                    optimizePackage(pkg, false /* isForPrimaryDex */, isPostBootUpdate);
        }
        return status;
    }
```

`optimizePackage`

```java
/**
     *
     * Optimize package if needed. Note that there can be no race between
     * concurrent jobs because PackageDexOptimizer.performDexOpt is synchronized.
     * @param pkg The package to be downgraded.
     * @param isForPrimaryDex Apps can have several dex file, primary and secondary.
     * @param isPostBootUpdate is post boot update or not.
     * @return PackageDexOptimizer#DEX_OPT_*
     */
    @DexOptResult
    private int optimizePackage(String pkg, boolean isForPrimaryDex, boolean isPostBootUpdate) {
        int reason = isPostBootUpdate ? PackageManagerService.REASON_POST_BOOT
                                      : PackageManagerService.REASON_BACKGROUND_DEXOPT;
        int dexoptFlags = DexoptOptions.DEXOPT_BOOT_COMPLETE;
        // 针对非boot优化， 添加flag
        if (!isPostBootUpdate) {
            dexoptFlags |= DexoptOptions.DEXOPT_CHECK_FOR_PROFILES_UPDATES
                    | DexoptOptions.DEXOPT_IDLE_BACKGROUND_JOB;
        }

        // System server share the same code path as primary dex files.
        // PackageManagerService will select the right optimization path for it.
        if (isForPrimaryDex || PLATFORM_PACKAGE_NAME.equals(pkg)) {
            // 系统应用大部分都是PrimaryDex， 调用performDexOptPrimary
            return performDexOptPrimary(pkg, reason, dexoptFlags, isPostBootUpdate);
        } else {
            return performDexOptSecondary(pkg, reason, dexoptFlags, isPostBootUpdate);
        }
    }
```

`performDexOptPrimary`

```java
    private int performDexOptPrimary(String pkg, int reason, int dexoptFlags, boolean isPostBootUpdate) {
        DexoptOptions dexoptOptions = new DexoptOptions(pkg, reason, dexoptFlags);
        // MY Customizations： 如果是boot后空闲优化， 将默认使用speed-profile方式，而不是verify方式
        if (isPostBootUpdate) {
            dexoptOptions = new DexoptOptions(pkg, reason, SystemProperties.get("pm.dexopt.bg-dexopt", "speed-profile"), null, dexoptFlags);
        }
        DexoptOptions finalDexoptOptions = dexoptOptions;
        // 最终使用回调执行DexOptHelper.performDexOptWithStatus
        return trackPerformDexOpt(pkg, /*isForPrimaryDex=*/true,
                () -> mDexOptHelper.performDexOptWithStatus(finalDexoptOptions));
    }
```

`DexOptHelper.java`

```java
/**
     * Perform dexopt on the given package and return one of following result:
     * {@link PackageDexOptimizer#DEX_OPT_SKIPPED}
     * {@link PackageDexOptimizer#DEX_OPT_PERFORMED}
     * {@link PackageDexOptimizer#DEX_OPT_CANCELLED}
     * {@link PackageDexOptimizer#DEX_OPT_FAILED}
     */
    @PackageDexOptimizer.DexOptResult
    /* package */ int performDexOptWithStatus(DexoptOptions options) {
        return performDexOptTraced(options);
    }

    private int performDexOptTraced(DexoptOptions options) {
        /// M: Add for Mtprof tool
        mPm.sMtkSystemServerIns.addBootEvent("PMS:performDexOpt:" + options.getPackageName());
        Trace.traceBegin(TRACE_TAG_PACKAGE_MANAGER, "dexopt");
        try {
            // 最后调用到了performDexOptInternal， 和前面分析OTA升级做dex优化的方法是同一个了
            return performDexOptInternal(options);
        } finally {
            Trace.traceEnd(TRACE_TAG_PACKAGE_MANAGER);
        }
    }
```

紧接着调用`performDexOptInternalWithDependenciesLI`等一系列。

总结以上完整的流程：

![Boot_idle_DexOpt.jpg](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/Boot_idle_DexOpt.jpg)

### 2.6 应用安装 

PKMS安装应用的流程比较长，本文不重点讲解此部分。

简要陈述安装流程就是，安装本质上是通过封装`InstallParams`，然后给PKMS主线程发送`Handler`消息进行安装，然后`HandlerParams`处理消息，再回调`InstallPackageHelper`接口进行安装。这个handler消息就是**INIT_COPY**。

`PackageHandler.java`

```java
void doHandleMessage(Message msg) {
        switch (msg.what) {
           case INIT_COPY: {
                HandlerParams params = (HandlerParams) msg.obj;
                if (params != null) {
                    if (DEBUG_INSTALL) Slog.i(TAG, "init_copy: " + params);
                    Trace.asyncTraceEnd(TRACE_TAG_PACKAGE_MANAGER, "queueInstall",
                            System.identityHashCode(params));
                    Trace.traceBegin(TRACE_TAG_PACKAGE_MANAGER, "startCopy");
                    // 处理安装流程
                    params.startCopy();
                    Trace.traceEnd(TRACE_TAG_PACKAGE_MANAGER);
                }
                break;
            }
			//  ......
            case POST_INSTALL: {
                //  ......
                // 处理安装完之后的流程
                mInstallPackageHelper.handlePackagePostInstall(data.res, data.args, didRestore);
                //  ......
            } break;
```

`HandlerParams.java`

```java
    final void startCopy() {
        if (DEBUG_INSTALL) Slog.i(TAG, "startCopy " + mUser + ": " + this);
        handleStartCopy();
        handleReturnCode();
    }
```

PKMS分为两个大阶段：

- 拷贝： `handleStartCopy()`
- 装载： `handleReturnCode()`

而DexOpt发生在装载阶段。

`InstallParams.java`

```java
    void handleReturnCode() {
        processPendingInstall();
    }

    private void processPendingInstall() {
        // ... ...
            processInstallRequestsAsync(
                    res.mReturnCode == PackageManager.INSTALL_SUCCEEDED,
                    Collections.singletonList(new InstallRequest(args, res)));
    }
    private void processInstallRequestsAsync(boolean success,
            List<InstallRequest> installRequests) {
        mPm.mHandler.post(() -> {
            mInstallPackageHelper.processInstallRequests(success, installRequests);
        });
    }
```

调用`InstallPackageHelper.processInstallRequests`方法

`InstallPackageHelper.java`

```java
public void processInstallRequests(boolean success, List<InstallRequest> installRequests) {
    // ... ...
	synchronized (mPm.mInstallLock) {
                installPackagesTracedLI(apkInstallRequests);
            }
    // ... ...
}
    @GuardedBy("mPm.mInstallLock")
private void installPackagesTracedLI(List<InstallRequest> requests) {
    try {
        Trace.traceBegin(TRACE_TAG_PACKAGE_MANAGER, "installPackages");
        installPackagesLI(requests);
    } finally {
        Trace.traceEnd(TRACE_TAG_PACKAGE_MANAGER);
    }
}

    /**
     * Installs one or more packages atomically. This operation is broken up into four phases:
     * <ul>
     *     <li><b>Prepare</b>
     *         <br/>Analyzes any current install state, parses the package and does initial
     *         validation on it.</li>
     *     <li><b>Scan</b>
     *         <br/>Interrogates the parsed packages given the context collected in prepare.</li>
     *     <li><b>Reconcile</b>
     *         <br/>Validates scanned packages in the context of each other and the current system
     *         state to ensure that the install will be successful.
     *     <li><b>Commit</b>
     *         <br/>Commits all scanned packages and updates system state. This is the only place
     *         that system state may be modified in the install flow and all predictable errors
     *         must be determined before this phase.</li>
     * </ul>
     *
     * Failure at any phase will result in a full failure to install all packages.
     */
    @GuardedBy("mPm.mInstallLock")
	private void installPackagesLI(List<InstallRequest> requests) {
         //阶段1：prepare
         prepareResult = preparePackageLI(request.mArgs, request.mInstallResult);
         //阶段2：scan
         final ScanResult result = scanPackageTracedLI(
                            prepareResult.mPackageToScan, prepareResult.mParseFlags,
                            prepareResult.mScanFlags, System.currentTimeMillis(),
                            request.mArgs.mUser, request.mArgs.mAbiOverride);
         //阶段3：Reconcile
         reconciledPackages = ReconcilePackageUtils.reconcilePackages(
                            reconcileRequest, mSharedLibraries,
                            mPm.mSettings.getKeySetManagerService(), mPm.mSettings);
         //阶段4：Commit并安装
         commitRequest = new CommitRequest(reconciledPackages,
                            mPm.mUserManager.getUserIds()); 
        // Modify state for the given package setting
         executePostCommitSteps(commitRequest);            
    }
```

做DexOpt主要就是在`executePostCommitSteps`方法中做，

```java
 /**
     * On successful install, executes remaining steps after commit completes and the package lock
     * is released. These are typically more expensive or require calls to installd, which often
     * locks on {@link com.android.server.pm.PackageManagerService.mLock}.
     */
    private void executePostCommitSteps(CommitRequest commitRequest) {
            // ... ... 
            //步骤1：prof文件写入
            // Prepare the application profiles for the new code paths.
            // This needs to be done before invoking dexopt so that any install-time profile
            // can be used for optimizations.
            mArtManagerService.prepareAppProfiles(pkg,
                    mPm.resolveUserIds(reconciledPkg.mInstallArgs.mUser.getIdentifier()),
                    /* updateReferenceProfileCnotallow= */ true);
             //步骤2：dex优化，在开启baseline profile优化之后compilation-reasnotallow=install-dm
             // Compute the compilation reason from the installation scenario.
            final int compilationReason =
                    mDexManager.getCompilationReasonForInstallScenario(
                            reconciledPkg.mInstallArgs.mInstallScenario);
        	// ... ... 
            final int dexoptFlags = DexoptOptions.DEXOPT_BOOT_COMPLETE
                    | DexoptOptions.DEXOPT_INSTALL_WITH_DEX_METADATA_FILE
                    | (isBackupOrRestore ? DexoptOptions.DEXOPT_FOR_RESTORE : 0);
            DexoptOptions dexoptOptions =
                    new DexoptOptions(packageName, compilationReason, dexoptFlags);

            // Check whether we need to dexopt the app.
            //
            // NOTE: it is IMPORTANT to call dexopt:
            //   - after doRename which will sync the package data from AndroidPackage and
            //     its corresponding ApplicationInfo.
            //   - after installNewPackageLIF or replacePackageLIF which will update result with the
            //     uid of the application (pkg.applicationInfo.uid).
            //     This update happens in place!
            //
            // We only need to dexopt if the package meets ALL of the following conditions:
            //   1) it is not an instant app or if it is then dexopt is enabled via gservices.
            //   2) it is not debuggable.
            //   3) it is not on Incremental File System.
            //
            // Note that we do not dexopt instant apps by default. dexopt can take some time to
            // complete, so we skip this step during installation. Instead, we'll take extra time
            // the first time the instant app starts. It's preferred to do it this way to provide
            // continuous progress to the useur instead of mysteriously blocking somewhere in the
            // middle of running an instant app. The default behaviour can be overridden
            // via gservices.
            //
            // Furthermore, dexopt may be skipped, depending on the install scenario and current
            // state of the device.
            //
            // TODO(b/174695087): instantApp and onIncremental should be removed and their install
            //       path moved to SCENARIO_FAST.
            // 判断是否做dexopt，同时满足以下条件如下：
            // 1. 不是带有instant flag的apk（谷歌推出的类似于微信小程序）， 或者INSTANT_APP_DEXOPT_ENABLED被enabled
            // 2. 应用不是调试版本
            // 3. 不在差分文件系统中
            final boolean performDexopt =
                    (!instantApp || android.provider.Settings.Global.getInt(
                            mContext.getContentResolver(),
                            android.provider.Settings.Global.INSTANT_APP_DEXOPT_ENABLED, 0) != 0)
                            && !pkg.isDebuggable()
                            && (!onIncremental)
                            && dexoptOptions.isCompilationEnabled();

            if (performDexopt) {
                // ... ... 
                // 调用PackageDexOptimizer的performDexOpt方法，做dex优化
                mPackageDexOptimizer.performDexOpt(pkg, realPkgSetting,
                        null /* instructionSets */,
                        mPm.getOrCreateCompilerPackageStats(pkg),
                        mDexManager.getPackageUseInfoOrDefault(packageName),
                        dexoptOptions);
                Trace.traceEnd(TRACE_TAG_PACKAGE_MANAGER);
            }
        }
    }
```

`PackageDexOptimizer.performDexOpt`这个方法和上面的方法重叠了。

总结安装过程中的流程为：

![Installation_DexOpt.jpg](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/Installation_DexOpt.jpg)

### 2.7 应用启动

先说结论， 

- 在Android 13已经移除了应用启动阶段去做dex优化的内容了，但是MTK平台还是有相关定制化的代码。

- 大概率还是启动应用阶段会做dex优化，会影响启动性能，所以Android高版本默认移除了。



从opengrok的代码来看，Android 6 / 7 /8.0版本有这个流程， Android 8.1就已经移除了。

在应用进程去创建一个Application的时候，会去attach创建，此时会先优化app。

![image-20240729175310767](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240729175310767.png)

```java
  private final boolean attachApplicationLocked(IApplicationThread thread,
            int pid) {
      		// ... ...
  	          ensurePackageDexOpt(app.instrumentationInfo != null
                      ? app.instrumentationInfo.packageName
                      : app.info.packageName);
              if (app.instrumentationClass != null) {
                  ensurePackageDexOpt(app.instrumentationClass.getPackageName());
              } 
      		// ... ...
            
  }
```

在 `attachApplicationLocked`阶段去执行`pm.performDexOptIfNeeded`

![image-20240730100343776](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240730100343776.png)

最终还是调用了 `PackageDexOptimizer.java的performDexOpt`方法。



Android 13 MTK平台的代码中，还是找到了有做dex优化的动作。

`ActivityManagerService.java`

```java
    /// M: MTK AMS
    public AmsExt mAmsExt = MtkSystemServiceFactory.getInstance().makeAmsExt();

    public AmsExt makeAmsExt() {
        return new AmsExt();
    }
```



`MtkSystemServiceFactory`会进行实例化`MtkSystemServiceFactoryImpl`

```java
public class MtkSystemServiceFactoryImpl extends MtkSystemServiceFactory {
    private static final String TAG = "MtkSystemServiceFactoryImpl";
	// ... ...
    private AmsExt mAmsExt = new AmsExtImpl();
 	// ... ...
}
```

好好看下`AmsExtImpl.java`

```java
public AmsExtImpl() {
         // ... ...
         mDexOptExt = DexOptExtFactory.getInstance().makeDexOpExt();
        // ... ...
   }

// 应用刚启动的时候，就会调用mDexOptExt.onStartProcess
@Override
public void onStartProcess(String hostingType, String packageName) {
        // ... ...

        if(mDexOptExt != null){
            mDexOptExt.onStartProcess(hostingType, packageName);
        }

        // ... ...
}

public DexOptExt makeDexOpExt() {
    return new DexOptExt();
}
```



`onStartProcess`什么时候才调用呢？

`services/core/java/com/android/server/am/ProcessList.java`

```java
startProcessLocked（）{
        /// M: onStartProcess @{
        mService.mAmsExt.onStartProcess(hostingRecord.getType(), app.info.packageName);
        /// M: onStartProcess @}
}
```



来看`DexOptExt`的实现类`DexOptExtImpl.java`

```java
public class DexOptExtImpl extends DexOptExt {
    private DexOptExtImpl() {
        // ... ...
        initHandlerAndStartHandlerThread();
    }
    
    private void initHandlerAndStartHandlerThread() {
        mHandlerThread = new HandlerThread("DexOptExt");
        mHandlerThread.start();
        mDexoptExtHandler = new Handler(mHandlerThread.getLooper(), new DexOptExtHandler());
    }

    class DexOptExtHandler implements Handler.Callback{
        @Override
        public boolean handleMessage(Message msg) {
            String pkg = (String)msg.obj;
            switch(msg.what) {
                case MSG_ON_PROCESS_START:
                    handleProcessStart(pkg);
                    break;
                case MSG_DO_DEXOPT:
                    handleDoDexopt(msg);
                    break;
            }
            return true;
        }
    }
    
    private void handleProcessStart(String pkg) {
        //"install" means that the app have not been dexopt after installation
        // 这里过滤只针对于使用 install 和 install-dm的方式安装的应用。  
        // 因为有界面的安装应用，是默认做过dexopt的。
        if (!isDexoptReasonInstall(pkg))
            return;
        // ... ...
        mDexoptExtHandler.sendMessageDelayed(msg, mTryDex2oatInterval);
   }

   private boolean isDexoptReasonInstall(String pkg) {
        // ... ...
        ArtManagerInternal artManager = LocalServices.getService(ArtManagerInternal.class);
        int reason = artManager.getPackageOptimizationInfo(appInfo, abi, "fakeactivity").getCompilationReason();
         /**
         *     private static final int TRON_COMPILATION_REASON_INSTALL = 4;
         *     private static final int TRON_COMPILATION_REASON_INSTALL_WITH_DM = 9;
         * **/
        Slog.d(TAG,pkg + " reason is " + reason + " abi is " + abi);
        // in ArtManagerService.java: 4 is install,9 is install-dm
        switch (reason) {
            case 4:
            case 9:
                return true;
            default:
                break;
        }
        return false;
   }
    
    private void handleDoDexopt(Message msg) {
        // 选择使用speed-profile方式优化
        String targetCompilerFilter = COMPILERFILTER_SPEED_PROFILE;
        // ... ...
        // 调用PKMS的performDexOptWithStatusByOption -> performDexOptWithStatus -> performDexOptTraced -> performDexOptInternal -> performDexOptInternalWithDependenciesLI -> PackageDexOptimizer.performDexOpt
        result = mPm.performDexOptWithStatusByOption(new DexoptOptions(pkg,
                            REASON_AGRESSIVE, targetCompilerFilter, null, flags));
        // ... ...
   }
    
}
```

可以大致推测MTK这个定制化代码是针对于采用“install”和"install-dm"这两种方式的应用，在启动应用时，默认执行DexOpt流程。

而用户普通安装应用，是会走进上一节所述的dexopt的。

```
    /**
     * Installation scenario providing the fastest “install button to launch" experience possible.
     */
    public static final int INSTALL_SCENARIO_FAST = 1;
```

4和9 貌似是针对于那种快速安装的应用，在安装阶段跳过做DexOpt，在此不做过多详细的研究。



## 3 结语

最后罗嗦几句：

- DexOpt每个Android版本都有比较大的变更了，本文比较适用于Android 13，而Android 14对这一块还有更大的更新
- DexOpt的触发流程，整体来说流程还是比较清晰，难点在于怎么准备好去调用dex2oat
- DexOpt对于ART虚拟机运行的性能有很大提升， 核心还是在art虚拟机和dex2oat这块
- 随着高性能CPU时代的到来，DEX优化几乎默认都做。而Dex优化对于低端平台显示出来的差异就很明显



___________________________________________

**【更多干货分享】**

- 微信公众号"Lucas-Den"(Lucas.D)

<img src=https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20240324122812628.png width=300 height=300 />

- 个人主页：[@Lucas.D](https://kingofhubgit.github.io/)
- GitHub：[@KingofHubGit](https://github.com/KingofHubGit)
- CSDN：[@Lucas.Deng](https://blog.csdn.net/dengtonglong)
- 掘金：[@LucasD](https://juejin.cn/user/3362755788151736)
- 知乎：[@Lucas.D](https://www.zhihu.com/people/lucas.deng)