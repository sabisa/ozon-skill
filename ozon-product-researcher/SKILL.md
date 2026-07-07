# Ozon Product Researcher

Ozon 电商平台选品研究工具，帮助中国卖家快速分析蓝海市场机会。

## 功能

- 🎯 自动搜索 Ozon 商品
- 💰 价格区间筛选（支持 1500-3000₽ 等范围）
- 🌍 原产国筛选（中国制造）
- 📊 数据抓取（商品名、价格、评论数、评分）
- 💵 利润计算（基于佣金、物流、汇率）
- 📄 生成 Markdown 分析报告
- 🐱 **布丁猫插件** - 获取上架时间、销量等核心数据
- 🔍 **Seerfar插件** - 获取商品关键词（SKU Reverse）

## 快速开始

### 1. 启动浏览器

```bash
# macOS
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 &

# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

### 2. 连接浏览器

```bash
playwright-cli attach --cdp=http://localhost:9222
```

### 3. 开始研究

```bash
# 搜索商品（示例：儿童玩具）
playwright-cli goto "https://www.ozon.ru/search/?text=детские+игрушки"
```

---

## 🐱 布丁猫插件使用

布丁猫 OZON 选品助手是核心工具，可获取：
- 上架时间
- 近30天销量
- 评论数
- 评分
- 退货率
- 推广费用占比
- 跟卖数量

**安装**：Chrome 应用商店搜索「布丁猫 OZON 选品助手」

---

## 🔍 Seerfar 插件使用（关键词获取）

Seerfar 是为 Ozon 和 Wildberries 卖家打造的运营工具，其 **SKU Reverse** 模块可以获取竞品商品的搜索关键词。

### 功能说明

| 功能 | 说明 |
|------|------|
| SKU Reverse | 输入商品SKU，获取该商品的搜索关键词 |
| 关键词分析 | 显示每个关键词的搜索量、竞争度等数据 |

### 使用步骤

1. **安装插件**
   - Chrome 应用商店搜索「Seerfar - 为Ozon和Wildberries卖家量身打造的运营插件工具」

2. **打开商品详情页**
   ```bash
   playwright-cli goto {商品URL}
   sleep 3
   ```

3. **激活 Seerfar 插件**
   - 点击浏览器右上角的 Seerfar 插件图标
   - 选择「SKU Reverse」功能

4. **获取关键词**
   - 在插件中输入或自动识别商品 SKU
   - 点击「搜索」或「分析」
   - 等待数据加载（通常需要 5-10 秒）

5. **提取关键词数据**
   ```bash
   # 截图保存关键词
   playwright-cli screenshot --filename=keywords.png

   # 提取页面文本（可能包含关键词）
   playwright-cli eval "document.body.innerText"
   ```

### 关键词使用建议

- **选品参考**：通过关键词判断商品的市场定位
- **优化标题**：参考高搜索量关键词优化商品标题
- **广告投放**：使用关键词进行 Ozon 广告投放
- **竞争分析**：对比同类商品的关键词布局

---

## 📊 选品核心指标

### 商品评估标准

| 指标 | 优秀 | 合格 | 差 |
|------|------|------|-----|
| 月销 | 100-500 | 50-100 或 500-1000 | < 50 或 > 2000 |
| 上架时间 | 3个月-1年 | 1-2年或<3个月 | > 3年 |
| 评论数 | 50-500 | 500-2000 | > 5000 |
| 评分 | 3.8-4.3 | 3.5-3.8 或 4.3-4.7 | < 3.5 或 > 4.7 |

### 蓝海潜力股特征

```
⭐ 月销 100-300 + 评论 < 100 + 上架 < 6个月 → 典型蓝海
⭐ 月销 200-500 + 评分 3.8-4.2 + 有差评共性 → 改进机会
⭐ 月销 300-500 + 上架 1-2年 + 评论 500-1500 → 稳定需求
```

### 选品梯队

| 梯队 | 月销 | 评论数 | 上架时间 | 评分 | 适合 |
|------|------|--------|---------|------|------|
| 🥇 第一梯队 | 100-500 | 50-500 | 3-12个月 | 3.8-4.4 | 新手容易出单 |
| 🥈 第二梯队 | 50-300 | < 200 | < 6个月 | 4.0-4.5 | 蓝海机会 |
| 🥉 第三梯队 | 300-800 | 500-2000 | 6个月-2年 | 4.0-4.5 | 稳定需求 |

**避开**：月销 < 50、评论 > 5000、上架 > 3年、评分 > 4.7

---

## 基础参数

| 项目 | 数值 |
|------|------|
| 汇率 | 1 ₽ ≈ 0.08 ¥ |
| Ozon 佣金 | 约 8-15% |
| 物流成本 | 约 250-350 ₽/件 |

## 利润计算公式

```
净利润(¥) = (售价 × 0.88 - 物流费 - 采购成本/0.08) × 0.08

简化版（目标利润 ≥ 40¥）：
采购成本上限(¥) = (售价 × 0.88 - 物流费) × 0.08 - 40
```

---

## 适用品类

### ✅ 推荐品类（认证要求低）

**儿童玩具**：
- 磁性钓鱼玩具 ⭐⭐⭐⭐⭐
- 儿童医生套装 ⭐⭐⭐⭐
- 儿童工具套装 ⭐⭐⭐⭐
- 儿童收银机 ⭐⭐⭐（需差异化）
- 儿童厨房玩具 ⭐⭐⭐⭐

**汽车用品**：
- 车载收纳袋 ⭐⭐⭐⭐⭐
- EVA汽车脚垫 ⭐⭐⭐⭐⭐
- 车载手机支架 ⭐⭐⭐⭐
- 仿皮座椅套 ⭐⭐⭐⭐
- 遮阳防晒帘 ⭐⭐⭐⭐

### ⚠️ 需认证品类

- 电动玩具（EAC认证）
- 儿童安全座椅
- 婴儿推车
- 电动吸奶器
- 护肤品/彩妆

---

## 蓝海市场判断标准

| 指标 | 蓝海 | 红海 |
|------|------|------|
| 搜索结果数 | < 100 | > 300 |
| 头部评论数 | < 10000 | > 20000 |
| 新品比例 | > 20% | < 5% |
| 竞争程度 | ⭐⭐ | ⭐⭐⭐⭐ |

---

## 完整工作流程

### 步骤 1：连接浏览器

```bash
playwright-cli attach --cdp=http://localhost:9222
```

### 步骤 2：导航与搜索

```bash
# 直接搜索
playwright-cli goto "https://www.ozon.ru/search/?text={关键词}&currency_price=1500.000%3B3000.000"

# 或先打开首页
playwright-cli goto https://www.ozon.ru
```

### 步骤 3：设置筛选

```bash
# 价格筛选（UI操作）
playwright-cli snapshot
# 找到价格输入框，点击，Meta+a，输入3000，Enter

# 原产国筛选
playwright-cli snapshot
# 找到"Китай"选项，点击
```

### 步骤 4：滚动加载

```bash
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done
```

### 步骤 5：提取数据

```bash
# 提取商品列表（文本）
playwright-cli eval "document.body.innerText.slice(0, 10000)"

# 提取商品链接（JSON）
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"

# 截图
playwright-cli screenshot --filename=results.png
```

### 步骤 6：分析商品详情（布丁猫 + Seerfar）

对每个候选商品执行以下操作：

```bash
# 6.1 打开商品详情页
playwright-cli goto {商品URL}
sleep 3

# 6.2 查看布丁猫插件数据（截图）
playwright-cli screenshot --filename=puding-{N}.png

# 6.3 激活 Seerfar 插件获取关键词
# 点击 Seerfar 图标 → SKU Reverse → 输入SKU → 分析

# 6.4 截图保存关键词
playwright-cli screenshot --filename=seerfar-{N}.png

# 6.5 提取页面信息
playwright-cli eval "document.body.innerText"
```

### 步骤 7：汇总分析 → 生成报告

---

## 常见问题

### 价格筛选不生效？

**解决**：
```bash
playwright-cli click {价格输入框ref}
playwright-cli press Meta+a  # Windows: Control+a
playwright-cli type "3000"
playwright-cli press Enter
```

### 页面加载慢？

```bash
sleep 5
playwright-cli snapshot
```

### 元素找不到？

```bash
playwright-cli snapshot --depth=5
```

### Seerfar 关键词获取失败？

**可能原因**：
- 插件未安装或未激活
- 网络问题导致数据加载失败
- SKU 格式不正确

**解决**：
1. 确认插件已安装并启用
2. 刷新页面后重试
3. 手动输入 SKU 进行查询

---

## 🌐 跨平台差异

| 功能 | macOS | Windows |
|------|-------|---------|
| Chrome 启动 | `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` | `C:\Program Files\Google\Chrome\...` |
| 全选快捷键 | `Meta+a` | `Control+a` |
| 用户数据目录 | `/tmp/chrome-ozon` | `C:\temp\chrome-ozon` |

---

## 📁 目录结构

```
ozon-product-researcher/
├── SKILL.md              # 本文件（使用手册）
├── prompts/
│   ├── research.md       # 研究流程提示词
│   └── report.md         # 报告模板
├── references/
│   ├── categories.md     # 品类参考（儿童玩具+汽车用品）
│   ├── certification.md  # 认证要求
│   └── pricing.md        # 定价公式
└── templates/
    └── report-template.md # 报告模板
```

---

## 相关资源

- [Ozon Seller 后台](https://seller.ozon.ru)
- [Ozon 儿童玩具分类](https://www.ozon.ru/category/igrushki-i-igry-7108/)
- [playwright-cli 文档](https://github.com/browser-use/browser-harness)
- [Seerfar 插件](https://chrome.google.com/webstore) - 搜索 "Seerfar Ozon Wildberries"
