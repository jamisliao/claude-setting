#!/bin/bash

# ccusage + Claude Code 簡化狀態列
# 只顯示模型、5h區間成本和剩餘時間、token 使用量

# 讀取來自 Claude Code 的 JSON 輸入
input=$(cat)

# 獲取基本資訊
model_name=$(echo "$input" | jq -r '.model.display_name // "unknown"')
current_dir_full=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
# 顯示最後兩層路徑
current_dir=$(echo "$current_dir_full" | awk -F'/' '{
    if (NF >= 2) {
        print $(NF-1) "/" $NF
    } else if (NF == 1) {
        print $NF
    } else {
        print "~"
    }
}')

# 獲取目前活躍區間的資訊
blocks_data=$(ccusage blocks --json 2>/dev/null)
current_tokens=""
block_cost=""
remaining_time=""

if [ $? -eq 0 ] && [ -n "$blocks_data" ]; then
    # 獲取活躍區間的資訊
    block_info=$(echo "$blocks_data" | jq -r '
        .blocks[] | 
        select(.isActive == true) | 
        {
            cost: .costUSD,
            current_tokens: .totalTokens,
            projected_tokens: (.projection.totalTokens // null),
            remaining_minutes: (.projection.remainingMinutes // null)
        }
    ')
    
    if [ -n "$block_info" ]; then
        # 格式化成本
        block_cost=$(echo "$block_info" | jq -r '.cost' | awk '{printf "%.2f", $1}')
        
        # 格式化剩餘時間
        remaining_minutes=$(echo "$block_info" | jq -r '.remaining_minutes // 0')
        if [ "$remaining_minutes" != "0" ] && [ "$remaining_minutes" != "null" ]; then
            hours=$((remaining_minutes / 60))
            mins=$((remaining_minutes % 60))
            remaining_time="${hours}h ${mins}m left"
        fi
        
        # 格式化 token 數量
        current_raw=$(echo "$block_info" | jq -r '.current_tokens')
        
        # 使用固定的限制 19,352,756 tokens (19.4M)
        limit_tokens=13532756
        
        current_fmt=$(echo "$current_raw" | awk '{
            if ($1 >= 1000000) printf "%.1fM", $1/1000000
            else if ($1 >= 1000) printf "%.1fK", $1/1000
            else printf "%d", $1
        }')
        
        limit_fmt=$(echo "$limit_tokens" | awk '{
            if ($1 >= 1000000) printf "%.1fM", $1/1000000
            else if ($1 >= 1000) printf "%.1fK", $1/1000
            else printf "%d", $1
        }')
        
        current_tokens="${current_fmt}/${limit_fmt}"
    fi
fi

# 組合輸出
output="📁 $current_dir | 🤖 $model_name"

if [ -n "$block_cost" ]; then
    output="$output | 💰 \$${block_cost} 5h區間"
    if [ -n "$remaining_time" ]; then
        output="$output ($remaining_time)"
    fi
fi

if [ -n "$current_tokens" ]; then
    output="$output | 🔢 ${current_tokens} tokens"
fi

echo "$output"
exit 0