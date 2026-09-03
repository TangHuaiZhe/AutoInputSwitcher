import Carbon
import Foundation

/// 负责把当前键盘输入源强制切换到英文 ABC。
final class InputSourceSwitcher {

    /// 目标输入源 ID：纯英文 ABC 键盘布局。
    private let targetID = "com.apple.keylayout.ABC"

    /// 缓存的 ABC 输入源，启动时查一次即可复用。
    private let abcSource: TISInputSource?

    init() {
        abcSource = InputSourceSwitcher.findInputSource(id: targetID)
    }

    /// 若当前输入源已是 ABC 则跳过，否则切到 ABC。
    func switchToABC() {
        guard let abcSource else { return }

        if currentInputSourceID() == targetID {
            return
        }
        TISSelectInputSource(abcSource)
    }

    /// 读取当前键盘输入源的 ID。
    private func currentInputSourceID() -> String? {
        guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }
        return InputSourceSwitcher.inputSourceID(of: current)
    }

    /// 在所有可用输入源里按 ID 找到匹配的那一个。
    private static func findInputSource(id: String) -> TISInputSource? {
        guard let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        return list.first { inputSourceID(of: $0) == id }
    }

    /// 从 TISInputSource 取出它的 kTISPropertyInputSourceID 字符串。
    private static func inputSourceID(of source: TISInputSource) -> String? {
        guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else {
            return nil
        }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }
}
