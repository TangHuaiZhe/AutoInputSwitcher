import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private let switcher = InputSourceSwitcher()
    private let chineseAppList = ChineseAppList()
    private var statusItem: NSStatusItem?
    private var settingsWindowController: ChineseAppSettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()

        // 监听前台 app 切换：注意必须用 NSWorkspace 专属的 notificationCenter，
        // 而不是默认的 NotificationCenter.default，否则收不到通知。
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        switchInputSourceForFrontmostApplication()
    }

    /// 名单中的 App 使用中文，其他 App 使用英文 ABC。
    @objc private func appDidActivate(_ notification: Notification) {
        switchInputSourceForFrontmostApplication(notification: notification)
    }

    private func switchInputSourceForFrontmostApplication(notification: Notification? = nil) {
        let application = notification?.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            ?? NSWorkspace.shared.frontmostApplication
        if chineseAppList.contains(bundleIdentifier: application?.bundleIdentifier) {
            switcher.switchToChinese()
        } else {
            switcher.switchToEnglish()
        }
    }

    @objc private func showChineseAppSettings() {
        if settingsWindowController == nil {
            settingsWindowController = ChineseAppSettingsWindowController(appList: chineseAppList)
        }
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.center()
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns")
            let icon = iconURL.flatMap { NSImage(contentsOf: $0) }
                ?? NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)
            icon?.size = NSSize(width: 18, height: 18)
            icon?.isTemplate = false
            button.image = icon
            button.imageScaling = .scaleProportionallyDown
            button.toolTip = "自动切换输入法"
        }

        let menu = NSMenu()

        let settingsItem = NSMenuItem(
            title: "中文 App 设置…",
            action: #selector(showChineseAppSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "退出",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = NSApp
        menu.addItem(
            quitItem
        )
        item.menu = menu

        statusItem = item
    }
}
