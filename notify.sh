#!/bin/bash

# Claude Code 完成操作通知腳本
# 當 Claude 需要輸入或空閒時觸發

# 取得當前目錄名稱
current_dir=$(basename "$PWD")

# 取得當前時間
current_time=$(date "+%H:%M:%S")

# 方法 1：使用 terminal-notifier（最可靠的 macOS 通知方式）
if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -message "Claude 等待您的輸入 ($current_dir)" -title "Claude Code" -subtitle "$current_time" -sound default 2>/dev/null
else
    # 方法 1b：如果沒有 terminal-notifier，回退到 osascript
    osascript -e "display notification \"Claude 等待您的輸入 ($current_dir)\" with title \"Claude Code\" subtitle \"$current_time\"" 2>/dev/null
    
    # 方法 2：如果通知失敗，嘗試 alert
    if [ $? -ne 0 ]; then
        osascript -e "display alert \"Claude Code\" message \"等待您的輸入 ($current_dir) - $current_time\" giving up after 3" 2>/dev/null &
    fi
fi

# 方法 3：播放提示音
osascript -e 'beep' 2>/dev/null

# 方法 4：Warp Terminal 特殊通知
if [ "$TERM_PROGRAM" = "WarpTerminal" ]; then
    printf "\033]777;notify;Claude Code;等待您的輸入 ($current_dir)\033\\"
fi

# 方法 5：語音提示（已關閉）
# say "Claude Code 等待輸入" 2>/dev/null &

# 方法 6：終端視覺提示
echo -e "\033[1;32m🔔 Claude Code: 等待您的輸入 ($current_dir) - $current_time\033[0m"