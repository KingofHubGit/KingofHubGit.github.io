---
layout: post
title: How to decorate/manage/improve your Ubuntu
categories: [linux, android]
description: How to decorate your Ubuntu 
keywords: keyword1, keyword2
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# Ubuntu必备15款应用+6大技巧，根本不需要Windows了

> 不少从事于AOSP/前后端/AI开发的朋友都在用Ubuntu系统，大部分人反馈桌面系统不如Windows/Mac好用，应用不全。
>
> 其实Ubuntu也可以很美观 大气 全面，看看我是怎么装修我的Ubuntu的（附MAC高端风+极客风教程）！
>
> Ubuntu都更新到24版本了，不要停留在以前的刻板影响，我以一个AOSP开发者角度，提供我的装修思路。



## Oerview

废话不多说，先上图：

> MAC高端风+极客风



#### 【银灰高逼格】

![image-20231118184049507](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118184049507.png)



#### 【毛玻璃文件管理系统】

![image-20231118185246252](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118185246252.png)



#### 【浅绿+迈阿密粉主题配色】

![Screenshot from 2023-11-18 18-56-29](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/Screenshot%20from%202023-11-18%2018-56-29.png)



#### 【内置Windows系统】

有些工作内容必须在Windows完成，但大部分时候，你可以在Ubuntu环境码所欲为。

![image-20231118190401282](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118190401282.png)



但话说会来，电脑配置也要高，不然没法再流畅地跑一个windows系统。

![image-20231118190616784](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118190616784.png)

- 本机涵盖了基本的码农作业条件：
  - 工作沟通：teams + 微信 + 邮箱
  - 浏览器：百年不变的Chrome
  - 终端：我习惯用termination
  - VPN：anyconnect + Clash
  - 音乐：Rhythmbox(本地) + Spotify（在线）
  - 代码开发：Jetbrain全家桶 + Sublime + notepad + gedit + vim
  - 办公环境：Vitual box + Win10 
  - 截图工具：flameshot + 系统自带screenshot
  - 文档： LibreOffice + 浏览器



接下来我主要讲讲优化Ubuntu PC 的关键应用+关键技巧。



> **Note：**
>
> 本文不会教你具体怎么干，是指明方向，具体操作自行网上百度+google



## Applications（15款应用）

### Tweaks

整体风格可以像MacOS，主要得益于Tweaks+自带的Appearence，剩下的就是作这以下几个工作：

- 选文件主题（需要区外网站下载）
- 选Shell主题
- 选壁纸
- 选锁屏背景
- 关闭侧边docker，开启底部任务栏
- 开启毛玻璃特效，依赖于GNOME的Extations——Blur my Shell



```shell
gnome-tweaks  &
```

这个是我的主题选择：

![image-20231118192821355](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118192821355.png)



### Virtualbox

用来安装Windows系统的，基本功能都是免费的

注意3点：

- 需要安装高级扩展插件Oracle_VM_VirtualBox_Extension_Pack-xxxx.vbox-extpack，才能使用全屏等功能

- 安装Guest Additions，用于Windows可以使用Ubuntu的USB3.0

  参考文章：

  [https://blog.csdn.net/dengtonglong/article/details/134310550](https://blog.csdn.net/dengtonglong/article/details/134310550)

  

- 需要配置一下usb权限，audio，共享目录等

- 制作snapshot，以防windows出现无法开机的情况。

![image-20231029030107015](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029030107015.png)



### Terminator

关于终端的选择，仁者见仁，有很多可以选择。

比如系统自带的Gnome-Terminal就很好用，Xshell，Windterm，tmux， CRT等等，但我还是觉得Terminator是里面的王者！

自定义风格，布局，command这些作的比较好，各个会话并可以相互隔离。

![image-20231118193646795](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118193646795.png)



### Spotify

Ubuntu有自带的听音乐的应用，但是没法搜索在线的歌曲，已经不能阻挡互联网音乐的风格了。

Spotify是一款支持多个系统的客户端，并且有很多免费中英文歌曲的应用，效果满分。

![image-20231118194258819](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118194258819.png)



### Evolution

虽然Ubuntu有自己的邮件应用ThuderBird，但是确实不好用，且不能上公司的邮箱，体验做的不是很好。

在这里安利一款可以添加多个账户，并且可以关联Ubuntu的日历的邮件app——Evolution。

![image-20231118194707759](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118194707759.png)

会根据会议安排，在Ubuntu系统下定时通知：

![image-20231118194945030](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118194945030.png)



### Typora

Typora是毫无疑问的  人尽皆知

- 最大的优点是：

风格很清爽，大部分能get到美感+极客风。

- 最大的缺点是：

图片无法添加到文档，这个核心问题，后面解决了，可以通过PicGo上传到图床。

具体方法，稍微查一查可以找到你要的答案。

![image-20231118195525215](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118195525215.png)



### Docker-DoChat

邮件有了，teams有了，现在就差微信了。

大概总结了一下微信for linux版本：

1. 最常见的wine版
2. 网页版本
3. docker wechat
4. 盒子微信（DoChat）

wine版问题频出，网页版后面不支持聊天了，docker wechat很难用，起不来。

这里推荐使用DoChat，比较清爽，问题少。

但是docker就需要自行学习和百度了。

![image-20231118200130240](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118200130240.png)



### system-indecter

有的时候，想要很快知道整个系统的网络上行/下行速度，CPU使用情况，内存情况。

这个时候就可以安装system-indecter，

![image-20231118200616042](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118200616042.png)



这个可以启动我们系统的gnome-system-monitor。这个是查看系统进程情况的，相当于Windows的任务管理器。

![image-20231118200647508](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118200647508.png)





### Parcellite

都说程序员只会ctrl+c, ctrl+v， 说明复制是一件很关键重要的功能。

频繁的复制，会经常丢失之前复制的内容，这个时候就需要复制粘贴板。

Parcellite可以达到这个效果，复制历史记录：

![image-20231118200920613](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118200920613.png)



### Albert

Albert相当于Windows的everything， 可以快速搜索，并且弹出，例如：

![image-20231118201115146](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118201115146.png)

![image-20231118201043050](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118201043050.png)

支持的范围比较广：

![image-20231118201300352](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118201300352.png)



此外，还有一些好工具，就不一一列举了，比如：

```
stick-note   便签工具

Ubuntu Cleaner  清理应用缓存 临时数据的工具

Clash   代理应用

Bcompare  文本/二进制/文件夹比较工具，非常全面

notepadqq  notepad++的Linux版本，我喜欢用这个看log

```



## Skills（6大技巧）

### 技巧一：desktop桌面图标

可以将你想要的任意应用，显示在桌面上，可以以这个格式建立图标：

```vim
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=Android Studio For Platform
Exec=/opt/android-studio-for-platform/bin/studio.sh
TryExec=/opt/android-studio-for-platform/bin/studio.sh
Comment=Android Studio For Platform
Terminal=false
Categories=Qt;Development;
Icon=/opt/android-studio-for-platform/bin/studio.png
Type=Application
```

也可以根据你的需求，定制图标和执行的命令。

如果想要和Windows的cmd/bat脚本一样，可以点击即自行某个sh脚本，该如何弄呢？

```
[Desktop Entry]
Encoding=UTF-8
#快捷方式显示名称
Name = anyconnect
#对该快捷方式的注释说明
Comment= anyconnect shortcut
#待执行.sh文件路径
Exec = /xxx/auto_xxxx.sh
#快捷方式显示图标路径
Icon = xxxx/execute.png
#是否显示终端，为确保.sh文件的echo能够被看到，此处要选择true
Terminal = true
#快捷方式类型
Type = Application
```



### 技巧二：auto startup开机自启动

如何自启动某些应用+进程+sh脚本+配置？

可以参考这篇我写的文章：

https://blog.csdn.net/dengtonglong/article/details/134310414



### 技巧三：crotab 定时执行

如果定时执行某些进程/sh/命令，可以借助crontab完成你想要的内容。

可以参考这篇我写的文章：

[https://blog.csdn.net/dengtonglong/article/details/133716920](https://blog.csdn.net/dengtonglong/article/details/133716920)



### 技巧四：alias别名

虽然很多人都知道alias，但是使用都不够广泛，甚至觉得有些鸡肋。

但是alias是可以提供很多便利的，

比如创建一个alias，可以一键kill掉相关的进程，你可以参考这篇文章：

[https://blog.csdn.net/dengtonglong/article/details/133819383](https://blog.csdn.net/dengtonglong/article/details/133819383)

此外还有一个注意的点：

> alias文件需要做到解耦，这个很关键，方便移植，不然每次都要重新修改+适配。



### 技巧五：支持连接蓝牙耳机

很多人都喜欢，带着蓝牙耳机上班，那种酷酷的感觉，懂得都懂。

我测试成功了，但是有几个点要注意：

- 要提前知道蓝牙设备的mac地址 
- 要启动音乐相关的

```shell
sudo apt install pulseaudio -k-module-bluetooth 
pulseaudio -k
pulseaudio --start
```

- 要使用blueman bluetoothctl等

```shell
sudo apt install blueman
```

- 最重要的一点，有的时候，需要重启电脑，才能识别到蓝牙设备，不然都是瞎折腾！

![image-20231118203508906](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231118203508906.png)



### 技巧六：系统/数据备份机制

等系统的一切都已经就位，还有重要的一步就是怎么保存劳动果实。

- 建立Ubuntu的snapshot，用timeshift保存系统配置

  ```
  sudo apt-add-repository -y ppa:teejee2008/ppa
  
  sudo apt update
  
  sudo apt install timeshift
  ```

  

-  使用rsync同步备份重要的代码+数据。



我的分享到此为止，希望有一千个哈姆勒特的风格吧。

> 别忘了一键收藏/点赞/关注，谢谢你了～

