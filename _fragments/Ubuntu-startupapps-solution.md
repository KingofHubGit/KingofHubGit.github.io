---
layout: fragment
title: Ubuntu开机自启动进程解决方案
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

#  Ubuntu开机自启动进程解决方案

## 配置Startup Applications



![image-20231029152511510](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029152511510.png)

![image-20231029152758224](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231029152758224.png)

这个APP也可以通过gnome-session-properties来启用。

配置文件存储在~/.config/autostart下面：

```shell
ldeng@lucas-d:~/.config/autostart$ cat  reboot_startup.sh.desktop 
[Desktop Entry]
Type=Application
Exec=/home/ldeng/Lucas.D/Lucas.D-labs/Protect/AllScript/LucasScript/timer_tasks/reboot_startup.sh
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





## 编写脚本



reboot_startup.sh

```
#!/bin/bash

echo "[startup application]: start task after reboot..."

virtualboxvm --startvm DL-Win10 &

sleep 10;

terminator &

gnome-system-monitor  &

gedit ~/Workspace/temp/paste.txt &
```















