import Cocoa
import Foundation
import UniformTypeIdentifiers

struct ChineseApp: Codable, Equatable {
    let bundleIdentifier: String
    let name: String
}

/// 持久化保存需要使用中文输入法的 App。
final class ChineseAppList {

    private let defaultsKey = "ChineseInputAppList"
    private let defaults = UserDefaults.standard

    private(set) var apps: [ChineseApp]

    init() {
        guard
            let data = defaults.data(forKey: defaultsKey),
            let savedApps = try? JSONDecoder().decode([ChineseApp].self, from: data)
        else {
            apps = []
            return
        }
        apps = savedApps
    }

    func contains(bundleIdentifier: String?) -> Bool {
        guard let bundleIdentifier else { return false }
        return apps.contains { $0.bundleIdentifier == bundleIdentifier }
    }

    func add(bundleIdentifier: String, name: String) {
        guard !apps.contains(where: { $0.bundleIdentifier == bundleIdentifier }) else { return }
        apps.append(ChineseApp(bundleIdentifier: bundleIdentifier, name: name))
        save()
    }

    func remove(at index: Int) {
        guard apps.indices.contains(index) else { return }
        apps.remove(at: index)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(apps) else { return }
        defaults.set(data, forKey: defaultsKey)
    }
}

final class ChineseAppSettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {

    private let appList: ChineseAppList
    private let tableView = NSTableView()
    private let removeButton = NSButton(title: "移除", target: nil, action: nil)

    init(appList: ChineseAppList) {
        self.appList = appList

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 380),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "中文输入法 App"
        window.isReleasedWhenClosed = false
        super.init(window: window)

        buildView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildView() {
        guard let contentView = window?.contentView else { return }

        let description = NSTextField(
            labelWithString: "名单中的 App 使用中文拼音，其他 App 使用英文 ABC。"
        )
        description.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(description)

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ChineseApp"))
        column.title = "中文输入法 App"
        tableView.addTableColumn(column)
        tableView.headerView = nil
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 28
        tableView.allowsEmptySelection = true
        tableView.allowsMultipleSelection = false
        tableView.frame = NSRect(x: 0, y: 0, width: 500, height: 220)
        tableView.autoresizingMask = [.width]

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.documentView = tableView
        contentView.addSubview(scrollView)

        let addButton = NSButton(title: "添加 App…", target: self, action: #selector(addApp))
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.bezelStyle = .rounded
        contentView.addSubview(addButton)

        removeButton.target = self
        removeButton.action = #selector(removeApp)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.bezelStyle = .rounded
        removeButton.isEnabled = false
        contentView.addSubview(removeButton)

        NSLayoutConstraint.activate([
            description.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            description.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            description.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            removeButton.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 8),
            removeButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
        ])

        tableView.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        appList.apps.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTableCellView()
        let app = appList.apps[row]
        let textField = NSTextField(labelWithString: "\(app.name)  (\(app.bundleIdentifier))")
        textField.lineBreakMode = .byTruncatingTail
        textField.frame = NSRect(x: 8, y: 3, width: tableView.bounds.width - 16, height: 22)
        textField.autoresizingMask = [.width]
        cell.addSubview(textField)
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        removeButton.isEnabled = tableView.selectedRow >= 0
    }

    @objc private func addApp() {
        let panel = NSOpenPanel()
        panel.title = "选择使用中文输入法的 App"
        panel.prompt = "添加"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [UTType.application]

        guard let window else { return }
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let self else { return }

            for url in panel.urls {
                guard
                    let bundle = Bundle(url: url),
                    let bundleIdentifier = bundle.bundleIdentifier
                else { continue }

                let name = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
                    ?? (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String)
                    ?? url.deletingPathExtension().lastPathComponent
                self.appList.add(bundleIdentifier: bundleIdentifier, name: name)
            }
            self.tableView.reloadData()
        }
    }

    @objc private func removeApp() {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else { return }
        appList.remove(at: selectedRow)
        tableView.reloadData()
        removeButton.isEnabled = false
    }
}
