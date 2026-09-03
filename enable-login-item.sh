#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_PATH="${PROJECT_DIR}/AutoInputSwitcher.app"
LABEL="com.yanzu.autoinputswitcher"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_PATH="${LAUNCH_AGENTS_DIR}/${LABEL}.plist"
USER_ID="$(id -u)"

if [[ ! -x "${APP_PATH}/Contents/MacOS/AutoInputSwitcher" ]]; then
	echo "请先运行 ./build.sh 生成 ${APP_PATH}"
	exit 1
fi

mkdir -p "${LAUNCH_AGENTS_DIR}"

TEMP_DIR="$(mktemp -d /tmp/autoinputswitcher-launch-agent.XXXXXX)"
TEMP_PLIST="${TEMP_DIR}/${LABEL}.plist"
/usr/bin/plutil -create xml1 "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :Label string ${LABEL}" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments array" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments:0 string /usr/bin/open" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments:1 string -g" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments:2 string -a" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments:3 string ${APP_PATH}" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :RunAtLoad bool true" "${TEMP_PLIST}"
/usr/libexec/PlistBuddy -c "Add :ProcessType string Interactive" "${TEMP_PLIST}"
mv "${TEMP_PLIST}" "${PLIST_PATH}"

launchctl bootout "gui/${USER_ID}/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/${USER_ID}" "${PLIST_PATH}"
launchctl enable "gui/${USER_ID}/${LABEL}"

echo "已设置开机自启动：${APP_PATH}"
echo "LaunchAgent：${PLIST_PATH}"
