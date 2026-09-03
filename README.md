# AutoInputSwitcher

一个极简的 macOS 菜单栏小工具：**每当你切换到任意 app 时，自动把输入法切回英文 ABC**。

## 特点

- 菜单栏后台常驻，无 Dock 图标、无主窗口。
- **零系统授权**：不需要辅助功能授权，开箱即用。
- 监听前台 app 切换事件，强制切到 `com.apple.keylayout.ABC`。

## 构建

```bash
cd AutoInputSwitcher
./build.sh
```

生成 `AutoInputSwitcher.app`。

## 运行

```bash
open ./AutoInputSwitcher.app
```

菜单栏右上角会出现一个键盘图标。点它 →「退出」即可关闭。

## 工作原理

- 用 `NSWorkspace.didActivateApplicationNotification` 监听前台 app 切换。
- 用 Carbon 的 `TISSelectInputSource` 把键盘输入源切到 ABC。
- 已是 ABC 时跳过，避免无谓调用。

## 第一版范围

- 所有 app 切换都强制 ABC（无白名单/黑名单）。
- 无开机自启动（可后续加 LaunchAgent）。
- 无偏好设置窗口。
