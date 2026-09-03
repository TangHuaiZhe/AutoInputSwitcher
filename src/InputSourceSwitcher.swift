import Carbon
import Foundation

/// 负责在英文 ABC 和中文拼音输入源之间切换。
final class InputSourceSwitcher {

    /// macOS 自带的英文 ABC 键盘布局。
    private let englishID = "com.apple.keylayout.ABC"

    /// macOS 自带的简体中文拼音输入法。
    private let chineseID = "com.apple.inputmethod.SCIM.ITABC"

    /// 输入源在启动时查一次即可复用。
    private let abcSource: TISInputSource?
    private let chineseSource: TISInputSource?

    init() {
        abcSource = InputSourceSwitcher.findInputSource(id: englishID)
        chineseSource = InputSourceSwitcher.findInputSource(id: chineseID)
    }

    /// 切换到中文拼音输入法；当前已是目标输入源时跳过。
    func switchToChinese() {
        switchTo(source: chineseSource, id: chineseID)
    }

    /// 切换到英文 ABC；当前已是目标输入源时跳过。
    func switchToEnglish() {
        switchTo(source: abcSource, id: englishID)
    }

    private func switchTo(source: TISInputSource?, id: String) {
        guard let source, currentInputSourceID() != id else { return }
        TISSelectInputSource(source)
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
