# Ozon Product Researcher

Ozon 电商平台选品研究工具，帮助中国卖家快速分析蓝海市场机会。

## 功能

- 🎯 自动搜索 Ozon 商品
- 💰 价格区间筛选（支持 1500-3500₽ 等范围）
- 📊 **布丁猫完整数据提取**（35+字段）
  - 基础信息：SKU、品牌、一级类目、三级类目、国家、卖家
  - 商品规格：重量(g)、长度(mm)、宽度(mm)、高度(mm)
  - 销售数据：月销量、月销售额、月销售变化、退货率、推广费用占比
  - 转化率：购物车转换率、搜索转换率、曝光转化率
  - 流量数据：详情页访问量、搜索曝光UV、曝光次数
  - 佣金数据：RFBS佣金（0-1500/1500-5000/5000+）、FBP佣金（多档）
  - 价格数据：人民币价格、美元价格、卢布价格、后台估算价
  - 竞争数据：跟卖数量、跟卖最低价
  - 其他：创建时间、变体数量、配送方式、期末库存、开启促销天数
- 🔥 **蓝海商品自动识别**（评论数≤100 + 尺寸过滤）
- 💵 利润计算（基于佣金、物流、汇率）
- 📄 自动生成 Markdown 分析报告（含尺寸和三级类目）
- 🌐 **独立Chrome** - 不影响现有浏览器会话

---

## 🚀 快速开始

### 1. 启动独立浏览器

```bash
# macOS
mkdir -p /tmp/chrome-ozon-research
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --user-data-dir=/tmp/chrome-ozon-research \
  --remote-debugging-port=9223 \
  --no-first-run \
  --no-default-browser-check > /dev/null 2>&1 &
sleep 3

# Windows
mkdir C:\temp\chrome-ozon
"C:\Program Files\Google\Chrome\Application\chrome.exe" \
  --user-data-dir=C:\temp\chrome-ozon \
  --remote-debugging-port=9223
```

### 2. 一键提取商品数据

```bash
browser-use <<'PY'
import time
import json
import re

def extract_all_data(url):
    """提取商品完整数据"""
    goto_url(url)
    time.sleep(3)
    text = js("document.body.innerText")
    
    data = {}
    
    # SKU从URL提取
    match = re.search(r'/product/[\w-]+-(\d+)', url)
    data['sku'] = match.group(1) if match else ''
    data['url'] = url
    
    # 价格
    price_match = re.search(r'(\d{3,5})\s*₽', text)
    data['price'] = int(price_match.group(1)) if price_match else None
    
    # 评论数
    reviews_match = re.search(r'(\d+)\s*отзыв', text)
    data['reviews'] = int(reviews_match.group(1)) if reviews_match else None
    
    # 评分
    rating_match = re.search(r'Рейтинг[:\s]*(\d[.,]\d)', text)
    data['rating'] = float(rating_match.group(1).replace(',', '.')) if rating_match else None
    
    # 月销量（布丁猫）
    sales_match = re.search(r'月销量[：:]?\s*([\d.]+)', text)
    data['monthly_sales'] = float(sales_match.group(1)) if sales_match else None
    
    # 创建时间（布丁猫）
    date_match = re.search(r'创建时间[：:]?\s*(\d{4}年\d{2}月\d{2}日)', text)
    data['create_date'] = date_match.group(1) if date_match else None
    
    # 退货率（布丁猫）
    return_match = re.search(r'退货率[：:]?\s*([\d.]+)%', text)
    data['return_rate'] = float(return_match.group(1)) if return_match else None
    
    return data

# 示例：提取商品数据
url = "https://www.ozon.ru/product/..."
data = extract_all_data(url)
print(json.dumps(data, ensure_ascii=False, indent=2))
PY
```

---

## 📦 布丁猫完整数据提取

布丁猫插件可获取以下完整数据字段：

### 支持的数据字段（布丁猫35+字段）

| 类别 | 字段 | 正则模式 | 说明 |
|------|------|---------|------|
| **基础信息** | sku | `SKU:\s*(\d+)` | 商品唯一标识 |
| | brand | `品牌:\s*(.+)` | 品牌名称 |
| | category_1 | `一级类目:\s*(.+)` | 一级分类 |
| | category_3 | `三级类目:\s*(.+)` | 三级分类 |
| | country | `国家:\s*(.+)` | 原产国 |
| | seller | `卖家:\s*(.+)` | 卖家名称 |
| **商品规格** ⭐ | weight_g | `重量,?\s*g:\s*(\d+)` | 重量(克) |
| | length_mm | `长,?\s*mm:\s*(\d+)` | 长度(mm) |
| | width_mm | `宽,?\s*mm:\s*(\d+)` | 宽度(mm) |
| | height_mm | `高,?\s*mm:\s*(\d+)` | 高度(mm) |
| **销售数据** | monthly_sales | `月销量:\s*([\d.]+)` | 近30天销量 |
| | monthly_revenue | `月销售额:\s*([\d.]+)` | 月销售额(₽) |
| | sales_change | `月销售变化:\s*([\d.-]+)%` | 环比变化% |
| | return_rate | `退货率:\s*([\d.]+)%` | 退货率% |
| | promotion_rate | `推广费用占比:\s*([\d.]+)%` | 广告费用占比% |
| **转化率数据** | cart_rate | `购物车转换率:\s*([\d.]+)` | 加购率 |
| | search_rate | `搜索转换率:\s*([\d.]+)` | 搜索转化率 |
| | exposure_rate | `曝光转化率:\s*([\d.]+)%` | 曝光转化率% |
| **流量数据** | detail_views | `详情页访问量:\s*(\d+)` | 详情页UV |
| | search_views | `搜索结果的详情页访问量:\s*(\d+)` | 搜索曝光UV |
| | exposure | `曝光次数:\s*(\d+)` | 曝光次数 |
| **佣金数据** | commission_rfbs | `RFBS佣金[^\d]*(\d+)%` | RFBS佣金率 |
| | commission_fbp | `FBP佣金[^\d]*(\d+)%` | FBP佣金率 |
| **价格数据** | price_cny | `人民币价格:\s*([\d.]+)` | 人民币价格 |
| | price_usd | `美元价格:\s*([\d.]+)` | 美元价格 |
| | price_rub | `卢布价格:\s*(\d+)` | 卢布价格 |
| | price_backend | `后台价格\(估\),\s*¥:\s*([\d.]+)` | 后台估算价 |
| **竞争数据** | competitors | `跟卖数量:\s*(.+)` | 跟卖卖家数 |
| | competitor_price | `跟卖最低价,\s*¥:\s*([\d.]+)` | 跟卖最低价 |
| **其他** | create_date | `创建时间:\s*(\d{4}年\d{2}月\d{2}日)` | 上架时间 |
| | variants | `变体数量:\s*(\d+)` | 变体数量 |
| | fulfillment | `配送方式:\s*(FBO\|FBS)` | 配送方式 |
| | stock | `期末库存:\s*(\d+)` | 当前库存 |
| | promo_days | `开启促销天数:\s*(\d+)` | 促销天数 |
| | shipping_time | `平均运输时间:\s*(\d+)` | 平均运输时间 |
| | promo_revenue_rate | `促销收入占比:\s*([\d.]+)%` | 促销收入占比 |

### 完整数据提取函数

```bash
browser-use <<'PY'
import time
import json
import re

def extract_full_data(url):
    """提取布丁猫完整数据（35+字段）"""
    goto_url(url)
    time.sleep(3)
    text = js("document.body.innerText")
    
    data = {'url': url}
    
    # ========== 基础信息 ==========
    m = re.search(r'SKU:\s*(\d+)', text)
    if m: data['sku'] = m.group(1)
    
    m = re.search(r'品牌:\s*(.+)', text)
    if m: data['brand'] = m.group(1).strip()
    
    m = re.search(r'一级类目:\s*(.+)', text)
    if m: data['category_1'] = m.group(1).strip()
    
    m = re.search(r'三级类目:\s*(.+)', text)
    if m: data['category_3'] = m.group(1).strip()
    
    m = re.search(r'国家:\s*(.+)', text)
    if m: data['country'] = m.group(1).strip()
    
    m = re.search(r'卖家:\s*(.+)', text)
    if m: data['seller'] = m.group(1).strip()
    
    # ========== 商品规格 ⭐ ==========
    m = re.search(r'重量,?\s*g:\s*(\d+)', text)
    if m: data['weight_g'] = int(m.group(1))
    
    m = re.search(r'长,?\s*mm:\s*(\d+)', text)
    if m: data['length_mm'] = int(m.group(1))
    
    m = re.search(r'宽,?\s*mm:\s*(\d+)', text)
    if m: data['width_mm'] = int(m.group(1))
    
    m = re.search(r'高,?\s*mm:\s*(\d+)', text)
    if m: data['height_mm'] = int(m.group(1))
    
    # ========== 销售数据 ==========
    m = re.search(r'月销量:\s*([\d.]+)', text)
    if m: data['monthly_sales'] = float(m.group(1))
    
    m = re.search(r'月销售额:\s*([\d.]+)', text)
    if m: data['monthly_revenue'] = float(m.group(1))
    
    m = re.search(r'月销售变化:\s*([\d.-]+)%', text)
    if m: data['sales_change'] = float(m.group(1))
    
    m = re.search(r'退货率:\s*([\d.]+)%', text)
    if m: data['return_rate'] = float(m.group(1))
    
    m = re.search(r'推广费用占比:\s*([\d.]+)%', text)
    if m: data['promotion_rate'] = float(m.group(1))
    
    # ========== 转化率数据 ==========
    m = re.search(r'购物车转换率:\s*([\d.]+)', text)
    if m: data['cart_rate'] = float(m.group(1))
    
    m = re.search(r'搜索转换率:\s*([\d.]+)', text)
    if m: data['search_rate'] = float(m.group(1))
    
    m = re.search(r'曝光转化率:\s*([\d.]+)%', text)
    if m: data['exposure_rate'] = float(m.group(1))
    
    # ========== 流量数据 ==========
    m = re.search(r'详情页访问量:\s*(\d+)', text)
    if m: data['detail_views'] = int(m.group(1))
    
    m = re.search(r'搜索结果的详情页访问量:\s*(\d+)', text)
    if m: data['search_views'] = int(m.group(1))
    
    m = re.search(r'曝光次数:\s*(\d+)', text)
    if m: data['exposure'] = int(m.group(1))
    
    # ========== 价格数据 ==========
    m = re.search(r'人民币价格:\s*([\d.]+)', text)
    if m: data['price_cny'] = float(m.group(1))
    
    m = re.search(r'美元价格:\s*([\d.]+)', text)
    if m: data['price_usd'] = float(m.group(1))
    
    m = re.search(r'卢布价格:\s*(\d+)', text)
    if m: data['price_rub'] = int(m.group(1))
    
    m = re.search(r'后台价格\(估\),\s*¥:\s*([\d.]+)', text)
    if m: data['price_backend'] = float(m.group(1))
    
    # ========== 竞争数据 ==========
    m = re.search(r'跟卖数量:\s*(.+)', text)
    if m: data['competitors'] = m.group(1).strip()
    
    m = re.search(r'跟卖最低价,\s*¥:\s*([\d.]+)', text)
    if m: data['competitor_price'] = float(m.group(1))
    
    # ========== 其他 ==========
    m = re.search(r'创建时间:\s*(\d{4}年\d{2}月\d{2}日)', text)
    if m: data['create_date'] = m.group(1)
    
    m = re.search(r'变体数量:\s*(\d+)', text)
    if m: data['variants'] = int(m.group(1))
    
    m = re.search(r'配送方式:\s*(FBO|FBS)', text)
    if m: data['fulfillment'] = m.group(1)
    
    m = re.search(r'期末库存:\s*(\d+)', text)
    if m: data['stock'] = int(m.group(1))
    
    m = re.search(r'开启促销天数:\s*(\d+)', text)
    if m: data['promo_days'] = int(m.group(1))
    
    m = re.search(r'平均运输时间:\s*(\d+)', text)
    if m: data['shipping_time'] = int(m.group(1))
    
    m = re.search(r'促销收入占比:\s*([\d.]+)%', text)
    if m: data['promo_revenue_rate'] = float(m.group(1))
    
    # 评论数和价格（页面原始）
    m = re.search(r'(\d+)\s*отзыв', text)
    if m: data['reviews'] = int(m.group(1))
    
    price_match = re.search(r'(\d{3,5})\s*₽', text)
    if price_match: data['price'] = int(price_match.group(1))
    
    return data

# 示例
url = "https://www.ozon.ru/product/..."
data = extract_full_data(url)
print(json.dumps(data, ensure_ascii=False, indent=2))
PY
```

### 批量提取（含尺寸和三级类目）

```bash
browser-use <<'PY'
import time
import json
import re

def batch_extract_full(urls):
    """批量提取完整商品数据"""
    results = []
    for i, url in enumerate(urls):
        goto_url(url)
        time.sleep(2)
        text = js("document.body.innerText")
        
        data = {'url': url}
        
        # SKU
        m = re.search(r'SKU:\s*(\d+)', text)
        if m: data['sku'] = m.group(1)
        
        # 三级类目 ⭐
        m = re.search(r'三级类目:\s*(.+)', text)
        if m: data['category_3'] = m.group(1).strip()
        
        # 尺寸 ⭐
        m = re.search(r'重量,?\s*g:\s*(\d+)', text)
        if m: data['weight_g'] = int(m.group(1))
        m = re.search(r'长,?\s*mm:\s*(\d+)', text)
        if m: data['length_mm'] = int(m.group(1))
        m = re.search(r'宽,?\s*mm:\s*(\d+)', text)
        if m: data['width_mm'] = int(m.group(1))
        m = re.search(r'高,?\s*mm:\s*(\d+)', text)
        if m: data['height_mm'] = int(m.group(1))
        
        # 基础数据
        m = re.search(r'品牌:\s*(.+)', text)
        if m: data['brand'] = m.group(1).strip()
        m = re.search(r'一级类目:\s*(.+)', text)
        if m: data['category_1'] = m.group(1).strip()
        m = re.search(r'月销量:\s*([\d.]+)', text)
        if m: data['monthly_sales'] = float(m.group(1))
        m = re.search(r'退货率:\s*([\d.]+)%', text)
        if m: data['return_rate'] = float(m.group(1))
        m = re.search(r'创建时间:\s*(\d{4}年\d{2}月\d{2}日)', text)
        if m: data['create_date'] = m.group(1)
        
        # 评论数和价格
        m = re.search(r'(\d+)\s*отзыв', text)
        if m: data['reviews'] = int(m.group(1))
        price_match = re.search(r'(\d{3,5})\s*₽', text)
        if price_match: data['price'] = int(price_match.group(1))
        
        results.append(data)
        print(f"完成 {i+1}/{len(urls)}: {data.get('category_3','?')} | {data.get('weight_g','?')}g | {data.get('reviews','?')}评论")
    
    return results

# 使用示例
urls = [...]  # 商品URL列表
data = batch_extract_full(urls)

with open('/tmp/products_full.json', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"\n总计: {len(data)}个商品")
PY
```

---

## 🔥 蓝海商品识别

### 自动识别标准

| 指标 | 蓝海标准 | 说明 |
|------|---------|------|
| 评论数 | ≤100 | 竞争极低 |
| 价格 | 300-2000₽ | 利润空间合理 |
| 月销量 | 0-300 或 无数据 | 未饱和或新品 |
| 重量 | ≤1000g | 物流成本友好 |
| 体积 | 长+宽+高 ≤ 1200mm | 节省仓储空间 |

### 蓝海识别脚本（含尺寸过滤）

```bash
browser-use <<'PY'
import json

# 读取商品数据
with open('/tmp/products_full.json', 'r') as f:
    products = json.load(f)

def is_blue_ocean(p):
    """判断是否为蓝海商品"""
    reviews = p.get('reviews', 0)
    sales = p.get('monthly_sales', 0)
    price = p.get('price', 0)
    weight = p.get('weight_g', 0)
    length = p.get('length_mm', 0)
    width = p.get('width_mm', 0)
    height = p.get('height_mm', 0)
    
    # 评论少
    low_reviews = isinstance(reviews, (int, float)) and 0 < reviews <= 100
    
    # 价格合理
    reasonable_price = isinstance(price, (int, float)) and 300 <= price <= 2000
    
    # 销量适中（未饱和）
    has_demand = isinstance(sales, (int, float)) and (0 <= sales <= 300 or sales is None)
    
    # 重量友好（≤1000g）
    light_weight = isinstance(weight, int) and weight <= 1000
    
    # 体积小巧（长+宽+高 ≤ 1200mm）
    compact_size = isinstance(length, int) and isinstance(width, int) and isinstance(height, int)
    compact_size = compact_size and (length + width + height) <= 1200
    
    return low_reviews and reasonable_price and has_demand

# 筛选蓝海商品
blue_ocean = [p for p in products if is_blue_ocean(p)]
blue_ocean.sort(key=lambda x: x.get('reviews', 9999))

print(f"蓝海商品: {len(blue_ocean)}/{len(products)}")
print("\n🔥 蓝海商品列表:")
for i, p in enumerate(blue_ocean[:10], 1):
    size_str = f"{p.get('length_mm','?')}x{p.get('width_mm','?')}x{p.get('height_mm','?')}mm"
    print(f"{i}. {p.get('category_3','?')} | 评论={p.get('reviews','?')} | 月销={p.get('monthly_sales','?')} | {size_str} | {p.get('weight_g','?')}g")

# 保存蓝海商品
with open('/tmp/blue_ocean_full.json', 'w') as f:
    json.dump(blue_ocean, f, ensure_ascii=False, indent=2)
PY
```

---

## 📊 选品核心指标

### 商品评估标准

| 指标 | 优秀 | 合格 | 差 |
|------|------|------|-----|
| 月销 | 100-500 | 50-100 或 500-1000 | < 50 或 > 2000 |
| 评论数 | 50-500 | 500-2000 | > 5000 |
| 上架时间 | 3个月-1年 | 1-2年或<3个月 | > 3年 |
| 评分 | 3.8-4.3 | 3.5-3.8 或 4.3-4.7 | < 3.5 或 > 4.7 |
| 退货率 | < 5% | 5-10% | > 10% |

### 🔥 蓝海商品标准（重点）

```
评论数 ≤ 100 + 价格 300-2000₽ → 典型蓝海机会！

典型案例：
⭐ 评论1 + 月销- + 价格705₽ → 磁性钓鱼玩具（超级蓝海）
⭐ 评论30 + 月销- + 价格658₽ → 折叠衣架
⭐ 评论31 + 月销35 + 价格876₽ → 磁性钓鱼玩具
⭐ 评论36 + 月销2 + 价格573₽ → 浴室防水收纳
⭐ 评论49 + 月销216 + 价格664₽ → 鞋拔（低评论高销量！）
```

### 选品梯队

| 梯队 | 评论数 | 月销 | 上架时间 | 适合 |
|------|--------|------|---------|------|
| 🥇 第一梯队 | ≤100 | 50-300 | <1年 | **立即上架** |
| 🥈 第二梯队 | 100-500 | 30-500 | <6个月 | 蓝海机会 |
| 🥉 第三梯队 | 500-2000 | 100-500 | 6个月-2年 | 稳定需求 |

**避开**：评论 > 5000、上架 > 3年、退货率 > 10%

---

## 💰 利润计算

### 基础参数

| 项目 | 数值 |
|------|------|
| 汇率 | 1 ₽ ≈ 0.08 ¥ |
| Ozon 佣金 | 约 8-15% |
| 物流费（Standard） | 约 250-350 ₽/件 ≈ 50-65¥ |

### 利润公式

```
净利润(¥) = (售价 × 0.88 - 物流费₽) × 0.08 - 采购成本

简化版（目标利润 ≥ 40¥）：
采购成本上限(¥) = (售价 × 0.88 - 55₽) × 0.08 - 40

示例：售价1000₽
= (1000 × 0.88 - 55) × 0.08 - 40
= (880 - 55) × 0.08 - 40
= 825 × 0.08 - 40
= 66 - 40 = 26¥ ← 利润过低！
```

### 达标判定

| 毛利值 | 评价 | 推荐度 |
|--------|------|---------|
| ≥ 80¥ | ⭐⭐⭐⭐⭐ 优秀 | ✅ 强烈推荐 |
| 60-80¥ | ⭐⭐⭐⭐ 良好 | ✅ 优先考虑 |
| 40-60¥ | ⭐⭐⭐ 合格 | ✅ 可选 |
| < 40¥ | ⭐⭐ 淘汰 | ❌ 不推荐 |

---

## 🏆 推荐品类（2026年验证）

### 🥇 第一梯队（评论≤100，超级蓝海）

| 品类 | 评论数 | 月销 | 价格范围 | 采购上限 |
|------|--------|------|---------|---------|
| 磁性钓鱼玩具 | 1-31 | 35 | 705-876₽ | ≤35¥ |
| 折叠衣架 | 30 | - | 658₽ | ≤40¥ |
| 窗帘绑带 | 31-94 | 4 | 631-680₽ | ≤35¥ |
| 浴室防水收纳 | 36 | 2 | 573₽ | ≤30¥ |
| 浴室防滑垫 | 37 | 17 | 589₽ | ≤30¥ |
| 鞋拔 | 49 | 216 | 664₽ | ≤35¥ |
| 桌面理线器 | 81 | 15 | 543₽ | ≤25¥ |
| 透明鞋盒 | 84 | 44 | 632₽ | ≤30¥ |

### 🥈 第二梯队（评论100-500，良好蓝海）

| 品类 | 评论数 | 月销 | 价格范围 | 采购上限 |
|------|--------|------|---------|---------|
| 旅行收纳包 | 99-830 | 9-125 | 592-734₽ | ≤30¥ |
| 厨房纸巾架 | 2-373 | 17-44 | 277-961₽ | ≤45¥ |
| 厨房调料架 | 36-4411 | 10-104 | 76-860₽ | ≤50¥ |
| 厨房防滑垫 | 2017-16895 | 25-135 | 178-841₽ | ≤40¥ |
| 折叠脏衣篓 | 293-8538 | 25-197 | 561₽ | ≤30¥ |

### ⚠️ 需认证品类（慎入）

- 电动玩具（EAC认证）
- 儿童安全座椅
- 婴儿推车
- 护肤品/彩妆

---

## 📄 自动生成报告

### 报告生成脚本（完整版）

```python
#!/usr/bin/env python3
"""生成蓝海选品报告（包含尺寸和三级类目）"""

import json
from datetime import datetime

# 读取数据
with open('/tmp/products_full.json', 'r') as f:
    products = json.load(f)

# 读取蓝海商品
with open('/tmp/blue_ocean_full.json', 'r') as f:
    blue_ocean = json.load(f)

# 生成报告
report = f"""# 🚗 Ozon 蓝海选品报告

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M')}
**商品总数**: {len(products)}
**蓝海商品**: {len(blue_ocean)}

---

# 🔥 蓝海商品速览（含尺寸）

| 序号 | 三级类目 | SKU | 评论 | 月销 | 价格 | 重量 | 尺寸(LxWxH) | 链接 |
|------|----------|-----|------|------|------|------|-------------|------|
"""

for i, p in enumerate(blue_ocean[:18], 1):
    url = p.get('url', '')
    sku = p.get('sku', '')
    cat3 = p.get('category_3', '?')
    reviews = p.get('reviews', '?')
    sales = p.get('monthly_sales', '?')
    price = p.get('price', '?')
    weight = p.get('weight_g', '?')
    l, w, h = p.get('length_mm', '?'), p.get('width_mm', '?'), p.get('height_mm', '?')
    size = f"{l}x{w}x{h}" if all(isinstance(x, int) for x in [l, w, h]) else '?'
    sales_str = str(int(sales)) if isinstance(sales, (int, float)) and sales > 0 else '-'
    report += f"| {i} | {cat3} | {sku} | {reviews} | {sales_str} | {price}₽ | {weight}g | {size}mm | [查看]({url}) |\n"

report += f"""
---

# 📊 所有商品数据（完整字段）

| SKU | 三级类目 | 价格 | 评论 | 月销 | 退货率 | 重量 | 尺寸 | 创建时间 |
|-----|----------|------|------|------|--------|------|------|----------|
"""

for p in products:
    sku = p.get('sku', '')
    cat3 = p.get('category_3', '?')
    price = p.get('price', '?')
    reviews = p.get('reviews', '?')
    sales = p.get('monthly_sales', '?')
    return_rate = p.get('return_rate', '?')
    weight = p.get('weight_g', '?')
    l, w, h = p.get('length_mm', 0), p.get('width_mm', 0), p.get('height_mm', 0)
    size = f"{l}x{w}x{h}" if all(isinstance(x, int) for x in [l, w, h]) else '?'
    date = p.get('create_date', '?')
    sales_str = str(int(sales)) if isinstance(sales, (int, float)) and sales > 0 else '-'
    return_str = f"{return_rate}%" if isinstance(return_rate, (int, float)) else '?'
    report += f"| {sku} | {cat3} | {price}₽ | {reviews} | {sales_str} | {return_str} | {weight}g | {size}mm | {date} |\n"

# 保存
output_path = '/Users/kyra.w/Desktop/ozon/Ozon蓝海选品报告-完整版.md'
with open(output_path, 'w') as f:
    f.write(report)

print(f"报告已生成: {output_path}")
```

### 执行报告生成

```bash
python3 /path/to/generate_report.py
```

---

## 🛠️ 常用代码模板

### 1. 搜索并提取商品链接

```bash
browser-use <<'PY'
import json

new_tab("https://www.ozon.ru/search/?text=关键词&currency_price=1500.000%3B3500.000")
time.sleep(3)

products = js("""
const links = [];
document.querySelectorAll('a').forEach(a => {
    const href = a.href;
    if (href.includes('/product/')) {
        const match = href.match(/\\/product\\/[\\w-]+-(\\d+)/);
        if (match) {
            const text = a.textContent.trim();
            if (text.length > 10 && text.length < 150) {
                links.push({
                    sku: match[1],
                    text: text.slice(0, 80),
                    url: href.split('?')[0]
                });
            }
        }
    }
});
const seen = new Set();
return JSON.stringify(links.filter(l => {
    if(seen.has(l.sku)) return false;
    seen.add(l.sku);
    return true;
}).slice(0, 8));
""")

data = json.loads(products)
for p in data:
    print(f"- {p['text']} | SKU: {p['sku']}")
PY
```

### 2. 分批搜索多品类

```bash
browser-use <<'PY'
import json

categories = [
    ("旅行收纳包", "органайзер+дорожный"),
    ("厨房防油贴纸", "наклейка+защита+кухня"),
    ("透明鞋盒", "коробка+для+обуви+прозрачная"),
    ("折叠脏衣篓", "корзина+для+белья+складная"),
    ("门后挂钩", "крючок+дверной+навесной"),
]

all_data = {}
for cat, keyword in categories:
    new_tab(f"https://www.ozon.ru/search/?text={keyword}&currency_price=1500.000%3B3500.000")
    time.sleep(3)
    
    links = js("""
    const links = [];
    document.querySelectorAll('a').forEach(a => {
        const href = a.href;
        if (href.includes('/product/')) {
            const match = href.match(/\\/product\\/[\\w-]+-(\\d+)/);
            if (match) {
                const text = a.textContent.trim();
                if (text.length > 10 && text.length < 150) {
                    links.push({
                        sku: match[1],
                        text: text.slice(0, 80),
                        url: href.split('?')[0]
                    });
                }
            }
        }
    });
    const seen = new Set();
    return JSON.stringify(links.filter(l => {
        if(seen.has(l.sku)) return false;
        seen.add(l.sku);
        return true;
    }).slice(0, 6));
    """)
    
    all_data[cat] = json.loads(links)
    print(f"=== {cat}: {len(json.loads(links))}个商品 ===")

# 保存
with open('/tmp/ozon_batch.json', 'w') as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print(f"\n总计: {sum(len(v) for v in all_data.values())}个商品")
PY
```

### 3. 提取布丁猫完整数据

```bash
browser-use <<'PY'
import json
import re

def get_budingmao_data(url):
    goto_url(url)
    time.sleep(3)
    text = js("document.body.innerText")
    
    data = {
        'sku': re.search(r'/product/[\w-]+-(\d+)', url).group(1),
        'url': url
    }
    
    # 评论数
    m = re.search(r'(\d+)\s*отзыв', text)
    if m: data['reviews'] = int(m.group(1))
    
    # 评分
    m = re.search(r'Рейтинг[:\s]*(\d[.,]\d)', text)
    if m: data['rating'] = float(m.group(1).replace(',', '.'))
    
    # 月销量
    m = re.search(r'月销量[：:]?\s*([\d.]+)', text)
    if m: data['monthly_sales'] = float(m.group(1))
    
    # 创建时间
    m = re.search(r'创建时间[：:]?\s*(\d{4}年\d{2}月\d{2}日)', text)
    if m: data['create_date'] = m.group(1)
    
    # 退货率
    m = re.search(r'退货率[：:]?\s*([\d.]+)%', text)
    if m: data['return_rate'] = float(m.group(1))
    
    # 推广费占比
    m = re.search(r'推广费占比[：:]?\s*([\d.]+)%', text)
    if m: data['promotion_rate'] = float(m.group(1))
    
    return data

# 示例
urls = [...]  # 商品URL列表
results = [get_budingmao_data(url) for url in urls]

with open('/tmp/budingmao_data.json', 'w') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)
PY
```

---

## ❓ 常见问题

### Q: 价格提取失败？
**解决**：增加等待时间 `time.sleep(4)`，或使用更灵活的正则：
```python
price_match = re.search(r'(\d{3,5})\s*₽', text)
```

### Q: 月销量数据为空？
**解决**：确保布丁猫插件已安装并开启，页面需要滚动加载数据。

### Q: 如何提高数据获取速度？
**解决**：批量处理时使用 `time.sleep(2)`，商品详情页数据通常在2-3秒内加载完成。

### Q: 评论数正则匹配失败？
**解决**：尝试多种模式：
```python
# 模式1
re.search(r'(\d+)\s*отзыв', text)
# 模式2  
re.search(r'(\d+)\s*отзывов', text)
# 模式3
re.search(r'отзывов?[:\s]*(\d+)', text)
```

---

## 🌐 跨平台差异

| 功能 | macOS | Windows |
|------|-------|---------|
| Chrome 路径 | `/Applications/...` | `C:\Program Files\...` |
| 用户目录 | `/tmp/chrome-ozon-research` | `C:\temp\chrome-ozon` |
| 调试端口 | 9223 | 9223 |

---

## 📁 目录结构

```
ozon-product-researcher/
├── SKILL.md              # 本文件
├── prompts/
│   ├── research.md       # 研究流程
│   └── report.md         # 报告模板
└── references/
    ├── categories.md     # 品类参考
    └── pricing.md        # 定价公式
```

---

## 🔗 相关资源

- [Ozon Seller](https://seller.ozon.ru)
- [布丁猫物流计算器](https://www.bdmozon.com/analysis/calculator)
- [布丁猫选品助手](https://chrome.google.com/webstore) - Chrome应用商店
- [browser-use](https://github.com/browser-use/browser-harness)

---

**更新**: 2026-07-09
**数据验证**: 基于72个商品实际数据
**蓝海商品**: 18个（评论数≤100）
