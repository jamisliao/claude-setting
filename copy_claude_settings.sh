#!/bin/bash

# 複製 Claude 設定檔案腳本
# 從 ~/.claude 複製檔案到當前目錄，排除指定的資料夾

echo "開始複製 Claude 設定檔案..."
echo "來源目錄: /Users/jamis.liao/.claude"
echo "目標目錄: ./"
echo ""
echo "將排除以下資料夾:"
echo "  - ide"
echo "  - local"
echo "  - projects"
echo "  - shell-snapshots"
echo "  - statsig"
echo "  - todos"
echo ""

# 使用 rsync 進行複製，排除指定的資料夾
rsync -av --progress \
  --exclude='ide/' \
  --exclude='local/' \
  --exclude='projects/' \
  --exclude='shell-snapshots/' \
  --exclude='statsig/' \
  --exclude='todos/' \
  /Users/jamis.liao/.claude/ \
  ./

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 複製完成！"
else
    echo ""
    echo "✗ 複製過程中發生錯誤"
    exit 1
fi
