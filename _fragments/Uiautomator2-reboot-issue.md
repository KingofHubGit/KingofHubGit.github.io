---
layout: fragment
title: uiautomator2 is valid after the device reboot
categories: [linux, android]
description: UIautomator2测试的时候，一旦和device端断连，就需要手动重启UIautomator2才能继续测试。本文提供在这种情况下的解决方案。
keywords: uiautomator, unittest
mermaid: false
sequence: false
flow: false
mathjax: false
mindmap: false
mindmap2: false
---



# UIautomator2 is valid after the device reboot

![uiautomator](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/uiautomator.png)



# UIautomator2提示需强制重启的解决方案

> UIautomator2测试的时候，一旦和device端断连，就需要手动重启UIautomator2才能继续测试。本文提供在这种情况下的解决方案。



UIautomator是google原生的自动化测试工具，由于只支持java，所以后面推出了支持python语言的UIautomator2。

UIautomator2测试环境，需要在device端安装一个atx应用，用于和PC端通讯。

在某些情况，比如手机重启，或者usb插拔，UIautomator2的测试没法进行了，提示如下错误：

```
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 486, in _jsonrpc_retry_call
    return self._jsonrpc_call(*args, **kwargs)
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 556, in _jsonrpc_call
    raise err
uiautomator2.exceptions.UiAutomationNotConnectedError: ({'code': -32001, 'message': 'java.lang.IllegalStateException', 'data': 'java.lang.IllegalStateException: UiAutomation not connected, UiAutomation@7e49b9d[id=-1, flags=0]\n\tat android.app.UiAutomation.throwIfNotConnectedLocked(UiAutomation.java:1239)\n\tat android.app.UiAutomation.waitForIdle(UiAutomation.java:800)\n\tat androidx.test.uiautomator.QueryController.waitForIdle(QueryController.java:532)\n\tat androidx.test.uiautomator.QueryController.waitForIdle(QueryController.java:523)\n\tat androidx.test.uiautomator.UiDevice.waitForIdle(UiDevice.java:621)\n\tat androidx.test.uiautomator.UiDevice.pressRecentApps(UiDevice.java:488)\n\tat com.github.uiautomator.stub.AutomatorServiceImpl.pressKey(AutomatorServiceImpl.java:558)\n\tat java.lang.reflect.Method.invoke(Native Method)\n\tat com.googlecode.jsonrpc4j.JsonRpcBasicServer.invoke(JsonRpcBasicServer.java:467)\n\tat com.googlecode.jsonrpc4j.JsonRpcBasicServer.handleObject(JsonRpcBasicServer.java:352)\n\tat com.googlecode.jsonrpc4j.JsonRpcBasicServer.handleJsonNodeRequest(JsonRpcBasicServer.java:283)\n\tat com.googlecode.jsonrpc4j.JsonRpcBasicServer.handleRequest(JsonRpcBasicServer.java:251)\n\tat com.github.uiautomator.stub.AutomatorHttpServer.serve(AutomatorHttpServer.java:100)\n\tat fi.iki.elonen.NanoHTTPD.serve(NanoHTTPD.java:2244)\n\tat fi.iki.elonen.NanoHTTPD$HTTPSession.execute(NanoHTTPD.java:945)\n\tat fi.iki.elonen.NanoHTTPD$ClientHandler.run(NanoHTTPD.java:192)\n\tat java.lang.Thread.run(Thread.java:923)\n'}, 'pressKey')

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/ldeng/code/PythonProjects/DLTest/OtaTest.py", line 27, in setUp
    device_utils.clear_all_tasks(self.device)
  File "/home/ldeng/code/PythonProjects/DLTest/utils/device_utils.py", line 78, in clear_all_tasks
    device.press("recent")
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 1164, in press
    return self.jsonrpc.pressKey(key)
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 479, in __call__
    return self.server._jsonrpc_retry_call(self.method, params,
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 488, in _jsonrpc_retry_call
    self.reset_uiautomator(str(e))  # uiautomator可能出问题了，强制重启一下
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 640, in reset_uiautomator
    ok = self._force_reset_uiautomator_v2(
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 667, in _force_reset_uiautomator_v2
    if self._is_apk_required():
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 711, in _is_apk_required
    if self._package_version("com.github.uiautomator.test") is None:
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/uiautomator2/__init__.py", line 735, in _package_version
    return packaging.version.parse(m.group('name') if m else "")
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/packaging/version.py", line 54, in parse
    return Version(version)
  File "/home/ldeng/code/PythonProjects/DLTest/venv/lib/python3.10/site-packages/packaging/version.py", line 200, in __init__
    raise InvalidVersion(f"Invalid version: '{version}'")
packaging.version.InvalidVersion: Invalid version: ''

----------------------------------------------------------------------
```



## 手动解决方案：

点开ATX应用，点击“启动UIAUTOMATOR”，重新测试即可。

![image-20231216113801529](https://raw.githubusercontent.com/KingofHubGit/ImageFactory/main/Public/image-20231216113801529.png)



## 自动化解决方案：

UIautomator2用于自动化测试，设备重启就需要手动操作，是不是有点不自动？

其实思路很简单，用adb来跑这段手动逻辑， python代码如下：

```python
DL_ATX_APK="com.github.uiautomator"
DL_ATX_MAIN="com.github.uiautomator.MainActivity"
START_ATX_SERVER="./atx/start_atx.sh"
    
def restartUiautomotor(self):
    time.sleep(5)
    # unlock screen
    utils.shell_cmd("adb shell input keyevent 224")
    time.sleep(2)
    utils.shell_cmd("adb shell input keyevent 82")
    time.sleep(2)
    # start atx service on device
    utils.shell_cmd(START_ATX_SERVER)
    time.sleep(5)
    # start atx app on device
    self.device.app_start(DL_ATX_APK, DL_ATX_MAIN)
    time.sleep(2)
    # click “启动UIAUTOMATOR” on device
    utils.shell_cmd("adb shell input tap 185 450")
    time.sleep(2)
    # back to home
    self.device.press("back")
    print("restart Uiautomotor success!")
    pass
```



脚本start_atx.sh

```shell
adb push atx-agent /data/local/tmp
adb shell chmod 755 /data/local/tmp/atx-agent
# launch atx-agent in daemon mode
adb shell /data/local/tmp/atx-agent server -d
# stop already running atx-agent and start daemon
adb shell /data/local/tmp/atx-agent server -d --stop
```



完美解决问题~!







