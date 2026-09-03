# AutoInputSwitcher

一个极简的 macOS 菜单栏小工具：切换到指定 App 时使用中文输入法，否则自动切回英文 ABC。

## 特点

- 菜单栏后台常驻，无 Dock 图标、无主窗口。
- **零系统授权**：不需要辅助功能授权，开箱即用。
- 监听前台 app 切换事件：名单中的 App 切到 `com.apple.inputmethod.SCIM.ITABC`，其他 App 切到 `com.apple.keylayout.ABC`。
- 通过菜单栏图标 →「中文 App 设置…」自定义中文输入法 App 名单，配置保存在本机用户偏好中。

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

## 开机自启动

构建完成后执行：

```bash
./enable-login-item.sh
```

脚本会为当前用户安装 LaunchAgent，登录 macOS 后自动启动本项目中的 `AutoInputSwitcher.app`。

## 工作原理

- 用 `NSWorkspace.didActivateApplicationNotification` 监听前台 app 切换。
- 用 Carbon 的 `TISSelectInputSource` 把键盘输入源切到 ABC。
- 已是 ABC 时跳过，避免无谓调用。

## 第一版范围

- 默认名单为空，所有 app 使用英文 ABC；可通过设置添加需要中文输入法的 App。
- 无开机自启动（可后续加 LaunchAgent）。
- 无偏好设置窗口。
