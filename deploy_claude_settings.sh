#!/bin/bash

# 部署 Claude 設定檔案腳本
# 將當前目錄的檔案複製到指定使用者的 ~/.claude 目錄

# 檢查是否提供了使用者名稱參數
if [ $# -eq 0 ]; then
    echo "錯誤：請提供使用者名稱作為參數"
    echo "用法：$0 <username>"
    echo "範例：$0 john"
    exit 1
fi

USERNAME=$1
TARGET_DIR="/Users/${USERNAME}/.claude"

# 檢查目標使用者的家目錄是否存在
if [ ! -d "/Users/${USERNAME}" ]; then
    echo "錯誤：使用者目錄 /Users/${USERNAME} 不存在"
    exit 1
fi

echo "準備部署 Claude 設定檔案..."
echo "目標使用者: ${USERNAME}"
echo "目標目錄: ${TARGET_DIR}"
echo ""

# 如果目標 .claude 目錄不存在，建立它
if [ ! -d "${TARGET_DIR}" ]; then
    echo "建立目標目錄 ${TARGET_DIR}..."
    mkdir -p "${TARGET_DIR}"
    if [ $? -ne 0 ]; then
        echo "錯誤：無法建立目標目錄"
        exit 1
    fi
fi

# 詢問是否要備份現有檔案
if [ -d "${TARGET_DIR}" ] && [ "$(ls -A ${TARGET_DIR} 2>/dev/null)" ]; then
    echo "警告：目標目錄 ${TARGET_DIR} 已存在且包含檔案"
    read -p "是否要備份現有檔案？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "備份現有檔案到 ${BACKUP_DIR}..."
        cp -R "${TARGET_DIR}" "${BACKUP_DIR}"
        echo "✓ 備份完成"
    fi
fi

echo ""
echo "開始複製檔案..."

# 使用 rsync 進行複製
# 注意：這裡不排除任何資料夾，因為我們假設當前目錄已經是篩選過的
rsync -av --progress \
  ./ \
  "${TARGET_DIR}/" \
  --exclude='.git/' \
  --exclude='.DS_Store' \
  --exclude='*.sh' \
  --exclude='.gitignore' \
  --exclude='.kiro/' \
  --exclude='.claude/' \
  --exclude='.claude-workflow/'

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 部署完成！"
    echo ""
    echo "已複製的內容："
    echo "  - agents/ (AI 代理設定)"
    echo "  - wake-up-cc/ (喚醒 Claude 設定)"
    echo "  - CLAUDE.md (Claude 文件)"
    echo "  - settings.json (設定檔)"
    echo "  - statusline-ccusage.sh (狀態列腳本)"
    echo ""
    echo "檔案已成功部署到 ${TARGET_DIR}"
else
    echo ""
    echo "✗ 部署過程中發生錯誤"
    exit 1
fi
