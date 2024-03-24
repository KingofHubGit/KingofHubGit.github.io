---
layout: fragment
title: How to auto start shell scripts in Ubuntu
categories: [linux]
description: some word here
keywords: usb, linux, Ubuntu
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



#  Linux开机自启动shell脚本

众所周知，每次开启Ubuntu，都有一些软件/进程/配置，是默认需要开启的，本文提供一种开启自启动shell脚本的方式。



## 配置Startup Applications



![image-20231029152511510](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029152511510.png)

![image-20231029152758224](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029152758224.png)

这个APP也可以通过gnome-session-properties来启用。

配置文件存储在~/.config/autostart下面：

```shell
ldeng@lucas-d:~/.config/autostart$ cat  reboot_startup.sh.desktop 
[Desktop Entry]
Type=Application
Exec=/home/XXXX/XXXX/timer_tasks/reboot_startup.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=reboot_stratup.sh
Name=reboot_stratup.sh
Comment[en_US]=reboot_stratup.sh
Comment=reboot_stratup.sh
```

所以，tweak也可以识别：

![image-20231029161323524](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029161323524.png)





## reboot_startup脚本



reboot_startup.sh

```
#!/bin/bash

echo "[startup application]: start task after reboot..."

# 启动虚拟机
virtualboxvm --startvm DL-Win10 & 

sleep 10;

# 启动终端
terminator &

# 启动性能监视器
gnome-system-monitor  &

# 打开常用文件
gedit ~/XXXX/temp/paste.txt &

```















