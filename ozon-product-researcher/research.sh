#!/bin/bash
# Ozon Product Researcher - macOS/Linux 启动脚本
# 使用方法: ./research.sh <品类关键词> [最低价] [最高价]

CATEGORY="${1:-детские+игрушки}"
PRICE_MIN="${2:-1500}"
PRICE_MAX="${3:-3000}"

echo "========================================"
echo " Ozon Product Researcher - macOS/Linux"
echo "========================================"
echo ""
echo "品类: $CATEGORY"
echo "价格区间: $PRICE_MIN - $PRICE_MAX ₽"
echo ""

# 编码搜索关键词
ENCODED_CATEGORY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$CATEGORY'))")

# 构建搜索 URL
SEARCH_URL="https://www.ozon.ru/search/?text=$ENCODED_CATEGORY&currency_price=${PRICE_MIN}.000%3B${PRICE_MAX}.000&country=20"

echo "正在打开浏览器..."
echo "搜索链接: $SEARCH_URL"
echo ""

# 启动 Chrome（macOS）
if [[ "$OSTYPE" == "darwin"* ]]; then
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-ozon "$SEARCH_URL" &
else
    # Linux 或其他系统
    google-chrome --remote-debugging-port=9222 "$SEARCH_URL" &
fi

echo "========================================"
echo " 下一步操作:"
echo " 1. 等待浏览器加载完成"
echo " 2. 在 Claude Code 中运行:"
echo "    playwright-cli attach --cdp=http://localhost:9222"
echo " 3. 设置筛选和抓取数据"
echo ""
echo " 提示: 输入 /help 查看更多命令"
echo "========================================"
