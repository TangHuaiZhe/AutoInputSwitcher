import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

    private let switcher = InputSourceSwitcher()
    private var statusItem: NSStatusItem?

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
    }

    /// 每次切换到任意 app，都把输入法切回英文 ABC。
    @objc private func appDidActivate(_ notification: Notification) {
        switcher.switchToABC()
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: "keyboard",
                accessibilityDescription: "自动切换输入法"
            )
        }

        let menu = NSMenu()
        menu.addItem(
            withTitle: "退出",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        item.menu = menu

        statusItem = item
    }
}
