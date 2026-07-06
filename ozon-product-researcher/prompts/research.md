# Ozon 选品研究流程（实战版）

## 完整工作流程

### 步骤 1：启动浏览器

```bash
# macOS - 启动带调试端口的 Chrome
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-ozon &
```

### 步骤 2：连接浏览器

```bash
# 使用 playwright-cli 连接
playwright-cli attach --cdp=http://localhost:9222
```

**成功标志**：显示已打开的标签页列表

### 步骤 3：导航到 Ozon

```bash
# 方法 1：直接搜索
playwright-cli goto "https://www.ozon.ru/search/?text={编码的关键词}&currency_price={最小}.000%3B{最大}.000&country=20"

# 方法 2：先打开首页，再搜索
playwright-cli goto https://www.ozon.ru
```

### 步骤 4：等待页面加载

```bash
sleep 5
```

### 步骤 5：滚动加载更多商品

Ozon 使用无限滚动，需要多次滚动：

```bash
# 滚动 5 次，每次 800 像素
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done
```

### 步骤 6：提取商品列表

```bash
# 提取商品链接列表
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"
```

### 步骤 7：逐个分析商品（布丁猫插件）

对于每个候选商品：

1. **打开商品详情页**
   ```bash
   playwright-cli goto {商品URL}
   sleep 3
   ```

2. **查看布丁猫插件数据**
   - 点击浏览器右上角布丁猫插件图标
   - 记录以下数据：
     - 上架时间
     - 近30天销量
     - 累计销量
     - 评论数
     - 评分

3. **截图保存**
   ```bash
   playwright-cli screenshot --filename=product-{编号}.png
   ```

4. **提取页面基本信息**
   ```bash
   playwright-cli eval "document.body.innerText"
   ```

### 步骤 8：汇总分析

根据布丁猫数据，评估每个商品的选品价值：

| 数据 | 优秀 | 合格 | 差 |
|------|------|------|-----|
| 月销 | 100-500 | 50-100 或 500-1000 | < 50 或 > 2000 |
| 上架时间 | 3个月-1年 | 1-2年或<3个月 | > 3年 |
| 评论数 | 50-500 | 500-2000 | > 5000 |
| 评分 | 3.8-4.3 | 3.5-3.8 或 4.3-4.7 | < 3.5 或 > 4.7 |

**重点关注的潜力股**：
- ⭐ 月销 100-300 + 评论 < 100 + 上架 < 6个月 → 典型蓝海
- ⭐ 月销 200-500 + 评分 3.8-4.2 + 有差评共性 → 改进机会
- ⭐ 月销 300-500 + 上架 1-2年 + 评论 500-1500 → 稳定需求

---

## 🐱 布丁猫插件使用

### 安装
在 Chrome 应用商店搜索「布丁猫 OZON 选品助手」安装

### 数据提取方法

由于布丁猫是浏览器插件，数据显示在插件面板中：

1. **手动查看** - 在商品页面上点击插件图标查看
2. **截图记录** - 使用 `playwright-cli screenshot` 截取插件显示的数据
3. **手动记录** - 将数据手动记录到分析表格

### 批量分析流程

```bash
# 1. 获取商品链接列表
LINKS=$(playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 10).map(el => el.href.split('?')[0])))")

# 2. 逐个打开分析（循环）
# 对每个链接：
playwright-cli goto {URL}
sleep 3
playwright-cli screenshot --filename=analysis-{N}.png

# 3. 回到列表继续
playwright-cli goback
sleep 2
```

---

## ⚠️ 关键技巧：价格筛选

### URL 参数可能不生效

**问题**：Ozon 的价格筛选器可能忽略 URL 中的 `currency_price` 参数

**解决**：通过 UI 操作设置

```bash
# 1. 获取页面快照
playwright-cli snapshot

# 2. 找到价格输入框的 ref
# 查找格式类似：
#   textbox [ref=xxx]: "22"           (最小价格，当前值)
#   textbox [ref=xxx]: "590 053"      (最大价格，当前值)

# 3. 点击价格输入框区域
playwright-cli click {价格区域ref}

# 4. 点击最大价格输入框
playwright-cli click {最大价格输入框ref}

# 5. 关键！必须先全选（macOS 用 Meta+a，Windows 用 Control+a）
playwright-cli press Meta+a

# 6. 输入新值
playwright-cli type "3000"

# 7. 按 Enter 确认
playwright-cli press Enter

# 8. 等待页面更新
sleep 3

# 9. 确认 URL 已更新
playwright-cli eval "document.URL"
```

**预期结果**：URL 中包含 `currency_price=1500.000%3B3000.000`

---

## 原产国筛选（中国）

```bash
# 1. 获取快照
playwright-cli snapshot

# 2. 找到"Страна-изготовитель"区域下的"Китай"选项
# 格式：
#   generic "Китай"
#     checkbox [ref=xxx]

# 3. 点击"Китай"文本（不是 checkbox 本身）
playwright-cli click {ref of "Китай"}

# 4. 等待筛选生效
sleep 3

# 5. 确认 URL 包含 country=20
playwright-cli eval "document.URL"
```

---

## 滚动加载更多商品

Ozon 使用无限滚动，需要多次滚动：

```bash
# 滚动 5 次，每次 800 像素
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done

# 或单次滚动
playwright-cli mousewheel 0 1000
```

---

## 数据提取

### 提取页面文本（包含商品信息）

```bash
playwright-cli eval "document.body.innerText"
```

**输出示例**：
```
Скидки недели
2 161 ₽
15 999 ₽
−86%
103 шт осталось
Синтезатор детский с микрофоном пианино 61 клавиша
4.8
1 184 отзыва
Завтра
```

### 提取商品链接（JSON 格式）

```bash
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"
```

**输出示例**：
```json
[
  {"title": "Синтезатор детский", "url": "https://www.ozon.ru/product/sintezator-detskiy-..."},
  {"title": "Магнитная рыбалка", "url": "https://www.ozon.ru/product/magnitnaya-rybalka-..."}
]
```

---

## 截图保存

```bash
# 截图保存到当前目录
playwright-cli screenshot --filename=ozon-results.png

# 保存到指定路径
playwright-cli screenshot --filename=/Users/kyra.w/Desktop/Ozon/result.png
```

---

## 页面操作

### 刷新页面
```bash
playwright-cli reload
sleep 3
```

### 获取页面快照
```bash
# 完整快照
playwright-cli snapshot

# 限制深度
playwright-cli snapshot --depth=3

# 快照特定元素
playwright-cli snapshot e34
```

### 查看当前 URL
```bash
playwright-cli eval "document.URL"
```

---

### ⚠️ Windows 注意事项

**键盘快捷键差异**：
```bash
# macOS
playwright-cli press Meta+a

# Windows
playwright-cli press Control+a
```

**Chrome 启动路径**：
```bash
# Windows
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

---

## 常见问题

### Q1：价格筛选不生效？

**原因**：URL 参数被忽略

**解决方案**：
1. 使用 UI 操作设置价格
2. 或者刷新页面后重试
3. 确认输入后按了 Enter

### Q2：页面加载慢？

**解决方案**：
```bash
sleep 5
playwright-cli snapshot
```

### Q3：反爬拦截？

**解决方案**：
```bash
playwright-cli reload
sleep 5
```

### Q4：元素找不到？

**解决方案**：
```bash
# 获取更详细的快照
playwright-cli snapshot --depth=5
```

---

## 完整示例

### 研究儿童玩具（磁性钓鱼）

```bash
# 1. 启动浏览器
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 &
sleep 3

# 2. 连接
playwright-cli attach --cdp=http://localhost:9222

# 3. 搜索
playwright-cli goto "https://www.ozon.ru/search/?text=%D0%BC%D0%B0%D0%B3%D0%BD%D0%B8%D1%82%D0%BD%D0%B0%D1%8F+%D1%80%D1%8B%D0%B1%D0%B0%D0%BB%D0%BA%D0%B0&currency_price=1500.000%3B3000.000&country=20"

# 4. 等待加载
sleep 5

# 5. 滚动加载
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done

# 6. 截图
playwright-cli screenshot --filename=magnetic-fishing.png

# 7. 提取数据
playwright-cli eval "document.body.innerText"

# 8. 提取链接
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 10).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"
```

---

## 输出数据格式

### 文本数据解析

```
商品名称
评分
评论数
售价
原价
折扣百分比
库存
```

### JSON 数据格式

```json
{
  "products": [
    {
      "name": "磁性钓鱼玩具",
      "price": 1818,
      "originalPrice": 6000,
      "discount": "69%",
      "reviews": 237,
      "rating": 4.9,
      "url": "https://www.ozon.ru/product/magnitnaya-rybalka-dlya-detey-xxx"
    }
  ]
}
```

---

## 利润计算

### 公式

```python
# 基础参数
exchange_rate = 0.08  # 1₽ ≈ 0.08¥
commission = 0.12  # 12%
logistics = 280  # ₽

# 计算
selling_price = 2000  # ₽
cost_in_yuan = 30  # ¥

profit_rub = selling_price * (1 - commission) - logistics - cost_in_yuan / exchange_rate
profit_yuan = profit_rub * exchange_rate

print(f"净利润: {profit_rub:.0f}₽ ≈ {profit_yuan:.0f}¥")
```

### 快速对照表

| 售价(₽) | 佣金(12%) | 物流 | 采购(¥) | 利润(₽) | 利润(¥) |
|---------|-----------|------|---------|---------|---------|
| 1500 | -180 | -280 | 25 | 765 | 61 |
| 1800 | -216 | -280 | 30 | 924 | 74 |
| 2000 | -240 | -280 | 35 | 1035 | 83 |
| 2500 | -300 | -320 | 45 | 1325 | 106 |
| 3000 | -360 | -350 | 55 | 1635 | 131 |

**目标：利润 ≥ 50¥**
