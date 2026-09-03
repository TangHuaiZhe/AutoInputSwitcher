import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private let switcher = InputSourceSwitcher()
    private let chineseAppList = ChineseAppList()
    private var statusItem: NSStatusItem?
    private var settingsWindowController: ChineseAppSettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupApplicationMenu()
        setupStatusItem()
        showChineseAppSettings()

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

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        showChineseAppSettings()
        return true
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

    private func setupApplicationMenu() {
        let appMenu = NSMenu()
        let appMenuItem = NSMenuItem(title: "AutoInputSwitcher", action: nil, keyEquivalent: "")
        appMenuItem.submenu = appMenu

        let settingsItem = NSMenuItem(
            title: "中文 App 设置…",
            action: #selector(showChineseAppSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        appMenu.addItem(settingsItem)
        appMenu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "退出 AutoInputSwitcher",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = NSApp
        appMenu.addItem(quitItem)

        let mainMenu = NSMenu()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.isVisible = true
        if let button = item.button {
            let icon = NSImage(
                systemSymbolName: "keyboard",
                accessibilityDescription: "自动切换输入法"
            )
            icon?.size = NSSize(width: 16, height: 16)
            icon?.isTemplate = true
            button.image = icon
            button.title = icon == nil ? "⌨︎" : ""
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
