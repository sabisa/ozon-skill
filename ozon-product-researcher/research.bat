@echo off
REM Ozon Product Researcher - Windows 启动脚本
REM 使用方法: research.bat <品类关键词> [最低价] [最高价]

set CATEGORY=%1
set PRICE_MIN=%2
set PRICE_MAX=%3

if "%CATEGORY%"=="" set CATEGORY=детские+игрушки
if "%PRICE_MIN%"=="" set PRICE_MIN=1500
if "%PRICE_MAX%"=="" set PRICE_MAX=3000

echo ========================================
echo  Ozon Product Researcher - Windows
echo ========================================
echo.
echo 品类: %CATEGORY%
echo 价格区间: %PRICE_MIN% - %PRICE_MAX% ₽
echo.

REM 编码搜索关键词（使用 PowerShell）
for /f "delims=" %%i in ('powershell -Command "[System.Web.HttpUtility]::UrlEncode('%CATEGORY%')"') do set ENCODED_CATEGORY=%%i

REM 构建搜索 URL
set SEARCH_URL=https://www.ozon.ru/search/?text=%ENCODED_CATEGORY%&currency_price=%PRICE_MIN%.000^;%PRICE_MAX%.000&country=20

echo 正在打开浏览器...
echo 搜索链接: %SEARCH_URL%
echo.

REM 启动 Chrome 并打开搜索页面
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 "%SEARCH_URL%"

echo ========================================
echo  下一步操作:
echo  1. 等待浏览器加载完成
echo  2. 在 Claude Code 中运行:
echo     playwright-cli attach --cdp=http://localhost:9222
echo  3. 设置筛选和抓取数据
echo.
echo  提示: 输入 /help 查看更多命令
echo ========================================

pause
