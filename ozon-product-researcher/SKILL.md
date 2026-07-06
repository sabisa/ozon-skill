# Ozon Product Researcher

Ozon 电商平台选品研究工具，帮助中国卖家快速分析蓝海市场机会。

## 功能

- 🎯 自动搜索 Ozon 商品
- 💰 价格区间筛选（支持 1500-3000₽ 等范围）
- 🌍 原产国筛选（中国制造）
- 📊 数据抓取（商品名、价格、评论数、评分）
- 💵 利润计算（基于佣金、物流、汇率）
- 📄 生成 Markdown 分析报告
- 🐱 **布丁猫插件集成**（获取上架时间、销量等核心数据）

## 使用方法

### 第一步：连接浏览器

```bash
# 启动带调试端口的 Chrome（如果未启动）
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 &

# 连接浏览器
playwright-cli attach --cdp=http://localhost:9222
```

### 第二步：执行搜索

```bash
# 基础搜索
playwright-cli goto https://www.ozon.ru

# 带筛选的搜索
playwright-cli goto "https://www.ozon.ru/search/?text={品类关键词}&currency_price={最小价格}.000%3B{最大价格}.000&country=20"
```

### 第三步：抓取数据

```bash
# 获取页面文本（包含商品信息）
playwright-cli eval "document.body.innerText"

# 提取商品链接
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 50), url: el.href.split('?')[0]})))"

# 截图
playwright-cli screenshot --filename=ozon-results.png
```

---

## 🐱 布丁猫插件使用指南

### 布丁猫 OZON 选品助手

布丁猫是一个 Chrome 浏览器插件，可以分析 Ozon 商品的核心数据。

**安装**：在 Chrome 应用商店搜索「布丁猫 OZON 选品助手」

### 使用步骤

1. **打开商品详情页**
   ```bash
   # 进入某个商品页面
   playwright-cli goto https://www.ozon.ru/product/xxx
   ```

2. **激活布丁猫插件**
   - 点击浏览器右上角的布丁猫插件图标
   - 或直接在商品页面上等待插件加载数据

3. **获取核心数据**
   布丁猫插件会显示：
   | 数据 | 说明 | 参考标准 |
   |------|------|---------|
   | 上架时间 | 商品首次上架日期 | 3-12 个月为佳 |
   | 近30天销量 | 最近一个月的销售量 | > 500 件/月 |
   | 累计销量 | 商品总销量 | 越多越好 |
   | 评论数 | 用户评价数量 | 100-1000 竞争小 |
   | 评分 | 商品评分 | 4.0-4.3 有改进空间 |

4. **提取数据方法**
   ```bash
   # 方法1：手动查看插件界面（截图）
   playwright-cli screenshot --filename=product-analysis.png

   # 方法2：提取页面 DOM 中的数据（如果插件注入到页面）
   playwright-cli eval "document.body.innerText"
   ```

### 批量获取商品数据

```bash
# 1. 先提取商品链接列表
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"

# 2. 逐个打开商品页面，手动查看布丁猫数据
# 3. 截图保存每个商品的数据
playwright-cli screenshot --filename=product-1.png
```

---

## 📊 选品核心数据指标

### 一、市场竞争度指标

| 指标 | 说明 | 蓝海标准 | 红海警告 |
|------|------|---------|---------|
| 搜索结果数 | 品类总商品数 | < 100 | > 300 |
| 头部评论数 | TOP10 商品评论总量 | < 10000 | > 20000 |
| 新品比例 | 3个月内上架商品占比 | > 20% | < 5% |
| 价格集中度 | 大部分商品价格区间 | 分散则有机会 | 高度集中 |

### 二、商品销售力指标（布丁猫数据）

| 指标 | 说明 | 优质标准 | 风险警告 |
|------|------|---------|---------|
| **近30天销量** | 月销 | 100-500 | < 50 或 > 2000 |
| **上架时间** | 首发日期 | 3个月-2年 | < 1个月或 > 3年 |
| **评论数** | 累计评价 | 50-2000 | < 10 或 > 5000 |
| **评分** | 1-5 星 | 3.8-4.5 | < 3.5 或 > 4.7 |
| **好评率** | 排除差评 | 85-95% | < 80% 或 > 98% |

### 三、利润空间指标

| 指标 | 计算方式 | 参考标准 |
|------|---------|---------|
| 利润率 | (售价 - 成本 - 佣金 - 物流) / 售价 | > 25% |
| 客单价 | 商品售价区间 | 1000-4000₽ |
| 目标利润 | 净利润（¥） | ≥ 30¥ |

### 四、蓝海商品潜力股特征

```
⭐ 潜力股1：月销100-300 + 评论<100 + 上架<6个月
   → 典型蓝海：竞争小，处于上升期，容易切入

⭐ 潜力股2：月销200-500 + 评分3.8-4.2 + 有差评共性
   → 改进机会：找到差评原因，做差异化选品

⭐ 潜力股3：月销300-500 + 上架1-2年 + 评论500-1500
   → 稳定需求：市场需求稳定，竞争可控
```

### 五、选品优先级（新手友好版）

| 梯队 | 月销 | 评论数 | 上架时间 | 评分 | 适合 |
|------|------|--------|---------|------|------|
| 🥇 第一梯队 | 100-500 | 50-500 | 3-12个月 | 3.8-4.4 | 新手容易出单 |
| 🥈 第二梯队 | 50-300 | < 200 | < 6个月 | 4.0-4.5 | 蓝海机会 |
| 🥉 第三梯队 | 300-800 | 500-2000 | 6个月-2年 | 4.0-4.5 | 稳定需求 |

**避开**：月销 < 50、评论 > 5000、上架 > 3年、评分 > 4.7

---

## 📖 完整使用手册

### 1. 浏览器连接

#### 启动 Chrome 并开启调试模式

```bash
# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-ozon &

# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

#### 连接浏览器

```bash
playwright-cli attach --cdp=http://localhost:9222
```

**注意**：连接成功后会显示已打开的标签页列表。

---

### 2. 导航与搜索

#### 基本导航

```bash
# 打开 Ozon 首页
playwright-cli goto https://www.ozon.ru

# 直接打开搜索结果页
playwright-cli goto https://www.ozon.ru/search/?text=儿童玩具
```

#### URL 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `text` | 搜索关键词 | `text=детские+игрушки` |
| `currency_price` | 价格区间 | `currency_price=1500.000%3B3000.000` |
| `country` | 原产国代码 | `country=20`（中国） |
| `from_global` | 全局搜索 | `from_global=true` |

**原产国代码**：
- `country=20` = 中国
- `country=0` = 俄罗斯
- `country=12` = 白俄罗斯

---

### 3. 价格筛选（重要技巧）

#### ⚠️ URL 参数可能不生效

Ozon 的价格筛选器在 URL 参数中可能不稳定，建议通过 **UI 操作**设置：

```bash
# 1. 获取页面快照，找到价格输入框
playwright-cli snapshot

# 2. 找到价格区域，常见 ref 格式
# textbox [ref=xxx]: "22"  (最小价格)
# textbox [ref=xxx]: "590 053"  (最大价格)

# 3. 点击最大价格输入框
playwright-cli click {最大价格输入框ref}

# 4. 全选并输入新值（macOS 用 Meta，Windows 用 Control）
playwright-cli press Meta+a
playwright-cli type "3000"
playwright-cli press Enter
```

**关键技巧**：必须先 `Meta+a` 全选，否则输入会追加而不是替换！

---

### 4. 原产国筛选

```bash
# 获取快照找到"中国"选项
playwright-cli snapshot

# 找到类似这样的结构：
# generic "Китай"
#   checkbox [ref=xxx]

# 点击"中国"文本
playwright-cli click {中国选项ref}

# URL 会自动添加 country=20
```

---

### 5. 滚动加载更多商品

```bash
# 多次滚动，每次 800 像素
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done
```

---

### 6. 数据提取

#### 提取商品列表（文本格式）

```bash
playwright-cli eval "document.body.innerText.slice(0, 10000)"
```

#### 提取商品链接（JSON 格式）

```bash
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"
```

#### 查看当前 URL

```bash
playwright-cli eval "document.URL"
```

---

### 7. 等待与调试

```bash
# 等待页面加载
sleep 5

# 刷新页面
playwright-cli reload

# 获取页面快照
playwright-cli snapshot

# 截图
playwright-cli screenshot --filename=page.png
```

---

### 8. 常见问题排查

#### 问题 1：价格筛选不生效

**原因**：URL 参数被忽略，需要 UI 操作

**解决**：
```bash
playwright-cli click {价格输入框ref}
playwright-cli press Meta+a
playwright-cli type "3000"
playwright-cli press Enter
sleep 3
playwright-cli eval "document.URL"  # 确认 URL 是否更新
```

#### 问题 2：页面加载慢

**解决**：
```bash
sleep 5
playwright-cli snapshot
```

#### 问题 3：元素找不到

**解决**：先获取完整快照
```bash
playwright-cli snapshot --depth=5
```

---

## 工作流程示例

```
1. 连接浏览器
   └─> playwright-cli attach --cdp=http://localhost:9222

2. 导航到 Ozon
   └─> playwright-cli goto https://www.ozon.ru

3. 执行搜索
   └─> playwright-cli goto "https://www.ozon.ru/search/?text=детские+игрушки"

4. 设置价格筛选（通过 UI）
   └─> 点击价格输入框 → Meta+a → 输入3000 → Enter

5. 设置原产国（中国）
   └─> playwright-cli click {中国ref}

6. 滚动加载
   └─> playwright-cli mousewheel 0 800 (重复几次)

7. 抓取数据
   └─> playwright-cli eval "document.body.innerText"

8. 提取链接
   └─> playwright-cli eval "..."
```

---

## 基础参数

| 项目 | 数值 |
|------|------|
| 汇率 | 1 ₽ ≈ 0.08 ¥ |
| Ozon 佣金 | 约 8-15% |
| 物流成本 | 约 250-350 ₽/件 |

## 利润计算公式

```
净利润 = 售价 - 采购价 - 佣金 - 物流费
       = (售价 × 0.92) - 采购价 - 物流费
```

其中：
- 佣金约 8-15%（基础品类约 12%）
- 物流费约 280₽（小件商品）

**快速估算**（目标利润 ≥ 50¥）：
```
最低售价 ≈ 1,250 ₽（含佣金、物流）
```

## 目录结构

```
ozon-product-researcher/
├── SKILL.md              # 本文件（使用手册）
├── prompts/
│   ├── research.md       # 研究流程提示词
│   └── report.md         # 报告模板
├── references/
│   ├── categories.md     # 品类参考
│   ├── certification.md  # 认证要求
│   └── pricing.md        # 定价公式
└── templates/
    └── report-template.md # 报告模板
```

## 适用品类

### ✅ 推荐品类（认证要求低）
- 磁性钓鱼玩具
- 儿童医生套装
- 儿童工具套装
- 儿童收银机
- 木质玩具
- 积木/拼图
- 儿童厨房玩具

### ⚠️ 需认证品类
- 纸尿裤/尿布（需国家注册）
- 电动吸奶器
- 儿童安全座椅
- 电动牙刷
- 儿童食品/护肤品

## 蓝海市场判断标准

| 指标 | 蓝海 | 红海 |
|------|------|------|
| 搜索结果数 | < 30 | > 100 |
| 头部评论数 | < 5000 | > 10000 |
| 新品比例 | > 30% | < 10% |
| 竞争程度 | ⭐⭐ | ⭐⭐⭐⭐ |

## 报告输出格式

生成 Markdown 格式报告，包含：
- 筛选条件
- 市场数据概览
- 头部商品 TOP 10
- 利润分析
- 蓝海机会
- 风险提示
- 选品建议
- 商品链接汇总

---

## 🌐 跨平台兼容性

### macOS vs Windows 差异

| 功能 | macOS | Windows |
|------|-------|---------|
| Chrome 启动路径 | `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` | `C:\Program Files\Google\Chrome\Application\chrome.exe` |
| 全选快捷键 | `Meta+a` | `Control+a` |
| 用户数据目录 | `/tmp/chrome-ozon` | `C:\temp\chrome-ozon` |
| Shell 提示符 | `$` | `>` |

### Windows 详细配置

#### 1. 启动 Chrome

```powershell
# PowerShell 或 CMD
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

或在 Claude Code 中运行：
```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

#### 2. 键盘快捷键

```bash
# macOS
playwright-cli press Meta+a

# Windows ⚠️ 重要
playwright-cli press Control+a
```

#### 3. 完整 Windows 工作流

```bash
# 1. 启动 Chrome（Windows）
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222

# 2. 连接浏览器
playwright-cli attach --cdp=http://localhost:9222

# 3. 导航
playwright-cli goto https://www.ozon.ru

# 4. 价格筛选（⚠️ Windows 用 Control+a）
playwright-cli click {价格输入框ref}
playwright-cli press Control+a
playwright-cli type "3000"
playwright-cli press Enter

# 5. 提取数据
playwright-cli eval "document.body.innerText"
```

### 常见 Windows 问题

| 问题 | 解决方案 |
|------|---------|
| Chrome 路径找不到 | 确认 Chrome 安装位置，或使用完整路径 |
| Control+a 不生效 | 确保焦点在输入框上，先点击输入框 |
| 路径中有空格 | 用引号包裹路径 |

---

## 相关资源

- [Ozon Seller 后台](https://seller.ozon.ru)
- [Ozon 儿童玩具分类](https://www.ozon.ru/category/igrushki-i-igry-7108/)
- [playwright-cli 文档](https://github.com/browser-use/browser-harness)
- [Windows Chrome 安装位置](https://support.google.com/chrome/answer/95414)
