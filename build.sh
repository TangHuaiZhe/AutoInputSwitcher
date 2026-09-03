#!/bin/bash
set -euo pipefail

# 项目根目录（脚本所在目录）
cd "$(dirname "$0")"

APP_NAME="AutoInputSwitcher"
BUILD_DIR="build"
APP_BUNDLE="${APP_NAME}.app"
MACOS_DIR="${APP_BUNDLE}/Contents/MacOS"
RESOURCES_DIR="${APP_BUNDLE}/Contents/Resources"

echo "==> 清理旧产物"
rm -rf "${BUILD_DIR}" "${APP_BUNDLE}"
mkdir -p "${BUILD_DIR}" "${MACOS_DIR}" "${RESOURCES_DIR}"

echo "==> 编译 Swift 源码"
swiftc src/*.swift \
	-o "${BUILD_DIR}/${APP_NAME}" \
	-framework Cocoa \
	-framework Carbon \
	-target arm64-apple-macosx13.0

echo "==> 组装 .app bundle"
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}"
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp Assets/AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"

echo "==> 对本地 .app 做 ad-hoc 签名"
codesign --force --deep --sign - "${APP_BUNDLE}"

echo "==> 完成：${APP_BUNDLE}"
echo "    运行：open ./${APP_BUNDLE}"
