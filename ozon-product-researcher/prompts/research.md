# Ozon 选品研究流程提示词

## 研究目标

分析 Ozon 电商平台，找出适合中国卖家的蓝海商品类别，并获取竞品关键词用于优化。

## 筛选条件

- 价格区间：1500-3000₽
- 原产国：中国制造（country=20）
- 目标利润：≥ 40¥/件
- 竞争程度：蓝海市场（评论少、上架时间短）

## 完整工作流程

### 1. 浏览器连接

```bash
# 启动 Chrome
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 &

# 连接
playwright-cli attach --cdp=http://localhost:9222
```

### 2. 搜索与筛选

```bash
# 搜索商品（URL编码关键词）
playwright-cli goto "https://www.ozon.ru/search/?text={关键词}&currency_price=1500.000%3B3000.000"

# 如果 URL 参数不生效，使用 UI 操作
playwright-cli snapshot
# 找到价格输入框，点击，Meta+a，输入3000，Enter
```

### 3. 滚动加载

```bash
for i in 1 2 3 4 5; do
  playwright-cli mousewheel 0 800
  sleep 1
done
```

### 4. 数据提取

```bash
# 提取商品列表
playwright-cli eval "document.body.innerText.slice(0, 10000)"

# 提取链接
playwright-cli eval "JSON.stringify([...document.querySelectorAll('a[href*=\"/product/\"]')].filter(el => el.href.match(/\/product\/.+\//)).slice(0, 20).map(el => ({title: el.textContent?.trim().slice(0, 60), url: el.href.split('?')[0]})))"
```

### 5. 商品详情分析（布丁猫 + Seerfar）

对每个候选商品执行以下操作：

```bash
# 5.1 打开商品详情页
playwright-cli goto {商品URL}
sleep 3

# 5.2 使用布丁猫插件查看数据
# 点击布丁猫插件图标，查看：
# - 上架时间
# - 近30天销量
# - 评论数
# - 评分
# - 退货率
# - 推广费用占比
# - 跟卖数量

# 5.3 截图保存布丁猫数据
playwright-cli screenshot --filename=puding-{N}.png

# 5.4 使用 Seerfar 插件获取关键词
# 点击 Seerfar 图标 → SKU Reverse → 输入SKU → 分析
# 等待 5-10 秒数据加载

# 5.5 截图保存关键词数据
playwright-cli screenshot --filename=seerfar-{N}.png

# 5.6 提取页面信息
playwright-cli eval "document.body.innerText"
```

### 6. 汇总分析 → 生成报告

---

## 布丁猫数据采集

布丁猫插件提供以下核心数据：

| 数据 | 说明 | 参考标准 |
|------|------|---------|
| 上架时间 | 商品首次上架日期 | 3-12个月为佳 |
| 近30天销量 | 月销 | 100-500 |
| 评论数 | 累计评价 | 50-2000 |
| 评分 | 1-5星 | 3.8-4.5 |
| 退货率 | 退货比例 | <10% |
| 推广费用占比 | 广告支出 | <10% |
| 跟卖数量 | 竞争卖家数 | <30 |

---

## Seerfar 关键词采集

Seerfar 的 SKU Reverse 模块可以获取商品的搜索关键词：

### 功能说明

| 功能 | 说明 |
|------|------|
| SKU Reverse | 输入商品SKU，获取该商品的搜索关键词 |
| 关键词分析 | 显示每个关键词的搜索量、竞争度等数据 |

### 关键词使用场景

1. **选品参考**：通过关键词判断商品的市场定位和竞争态势
2. **标题优化**：参考高搜索量关键词优化商品标题
3. **广告投放**：使用关键词进行 Ozon 广告投放
4. **竞争分析**：对比同类商品的关键词布局

### 数据记录格式

```markdown
### 商品：{{商品名称}}

**关键词**：
- 关键词1（搜索量：高，竞争度：中）
- 关键词2（搜索量：中，竞争度：低）
- 关键词3（搜索量：低，竞争度：低）

**应用建议**：...
```

---

## 利润计算

```python
# 基础参数
exchange_rate = 0.08  # 1₽ ≈ 0.08¥
commission = 0.12     # 12%
logistics = 280       # ₽

# 利润计算
selling_price = 2000  # ₽
cost_in_yuan = 30     # ¥

profit_rub = selling_price * (1 - commission) - logistics - cost_in_yuan / exchange_rate
profit_yuan = profit_rub * exchange_rate

# 采购成本上限（目标利润≥40¥）
max_cost_yuan = (selling_price * (1 - commission) - logistics) * exchange_rate - 40
```

---

## 评估标准

### 商品评分维度

| 维度 | 权重 | 优秀标准 |
|------|------|---------|
| 月销 | 25% | 100-500件 |
| 评论数 | 20% | 50-500条 |
| 上架时间 | 20% | 3-12个月 |
| 评分 | 15% | 3.8-4.3 |
| 利润空间 | 20% | ≥40¥ |

### 潜力股特征

```
⭐ 月销 100-300 + 评论 < 100 + 上架 < 6个月 → 典型蓝海
⭐ 月销 200-500 + 评分 3.8-4.2 + 有差评共性 → 改进机会
⭐ 月销 300-500 + 上架 1-2年 + 评论 500-1500 → 稳定需求
```

---

## 输出格式

生成 Markdown 格式报告，包含：

1. **蓝海选品总览** - 品类排名表
2. **品类详情** - 每个品类2-3个推荐商品
3. **关键词分析** - 每个商品的搜索关键词
4. **利润计算** - 采购成本上限
5. **试单建议** - 首批测试商品清单
6. **风险提示** - 认证、物流、竞争风险
7. **商品链接汇总** - 所有推荐商品链接和关键词

---

## 研究品类建议

### 儿童玩具类
- 磁性钓鱼玩具
- 儿童医生套装
- 儿童工具套装
- 儿童收银机
- 儿童厨房玩具

### 汽车用品类
- 车载收纳袋
- EVA汽车脚垫
- 车载手机支架
- 仿皮座椅套
- 遮阳防晒帘
- 车载扶手箱
- 车载垃圾桶
- 方向盘套

### 其他潜力品类
- 家居收纳
- 墙上装饰
- 厨房小工具
- 户外运动用品

---

## 注意事项

1. **价格筛选**：URL 参数可能不生效，需使用 UI 操作
2. **滚动加载**：Ozon 使用无限滚动，需多次滚动
3. **布丁猫数据**：插件数据显示在浏览器中，需截图记录
4. **Seerfar 关键词**：等待 5-10 秒数据加载，截图保存
5. **跟卖数量**：影响竞争程度，越少越好
6. **退货率**：影响售后成本，越低越好
