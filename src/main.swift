import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 纯菜单栏 App：不显示 Dock 图标、不占用主菜单。
app.setActivationPolicy(.accessory)

app.run()
