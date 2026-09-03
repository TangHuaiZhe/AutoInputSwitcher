import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// 同时提供主窗口和状态栏入口，确保设置与退出始终可达。
app.setActivationPolicy(.regular)

app.run()
