---
name: ozon-to-1688
description: 通过 Ozon 商品链接，使用 1688 以图搜图功能找到同款产品并提取采购信息
allowed-tools: Bash(playwright-cli:*) Bash(npx:*) Bash(npm:*)
---

# Ozon to 1688 以图搜图

通过 Ozon 商品链接，使用 1688 以图搜图功能找到对应的 1688 供应商，并提取采购价格、物流信息和包装规格。

## 快速开始

### 1. 连接浏览器（推荐已登录1688的Chrome）

```bash
# 方式一：连接 Chrome 远程调试（推荐，已登录1688）
playwright-cli attach --cdp=chrome

# 方式二：启动新浏览器
playwright-cli open
```

### 2. 执行以图搜图

```
/ozon-to-1688 https://www.ozon.ru/product/产品链接
```

或直接提供 Ozon 商品链接，我会自动执行以图搜图。

---

## 实战工作流程

### 步骤 1：连接 Chrome 并打开 Ozon 产品页

```bash
# 连接 Chrome（已登录状态）
playwright-cli attach --cdp=chrome

# 打开 Ozon 产品页
playwright-cli --s=chrome open "https://www.ozon.ru/product/产品ID"
```

### 步骤 2：提取 Ozon 产品主图 URL

从 Ozon 页面提取产品图片 URL（用于 1688 以图搜图）：

```bash
# 提取产品图片 URL（1000px大图）
playwright-cli --s=chrome eval "el => JSON.stringify([...document.querySelectorAll('img[src*=\"multimedia\"]')].map(img => img.src.replace('/wc50/', '/wc1000/')).filter((v, i, a) => a.indexOf(v) === i).slice(0, 3))"
```

输出示例：
```json
["https://ir-21.ozonru.cn/s3/multimedia-b/wc1000/6827910059.jpg","https://ir-21.ozonru.cn/s3/multimedia-o/wc1000/6827906004.jpg"]
```

### 步骤 3：提取 Ozon 产品信息

获取产品关键数据用于后续对比：

```bash
# 获取产品标题
playwright-cli --s=chrome eval "document.querySelector('h1')?.textContent"

# 获取价格（卢布）
playwright-cli --s=chrome eval "document.body.innerText.match(/\\d+\\s*₽/)?.[0]"

# 获取评分和评论数
playwright-cli --s=chrome eval "document.body.innerText.match(/\\d\\.\\d\\s*\\/\\s*\\d+\\s*отзывов/)?.[0]"

# 获取重量
playwright-cli --s=chrome eval "document.body.innerText.match(/\\d+\\s*г/g)?.[0]"

# 获取尺寸
playwright-cli --s=chrome eval "document.body.innerText.match(/\\d+×\\d+×\\d+мм/)?.[0]"
```

### 步骤 4：用图片 URL 在 1688 以图搜图

使用提取的图片 URL 直接在 1688 以图搜图：

```bash
# 直接用图片 URL 打开 1688 以图搜图
playwright-cli --s=chrome open "https://air.1688.com/kapp/1688-search/pc-image-search/?tab=imageSearch&imageAddress=https%3A%2F%2Fir-21.ozonru.cn%2Fs3%2Fmultimedia-b%2Fwc1000%2F6827910059.jpg"

# 等待图片加载和搜索结果
sleep 8

# 获取搜索结果快照
playwright-cli --s=chrome snapshot
```

### 步骤 5：分析 1688 搜索结果

从搜索结果提取供应商信息：

```bash
# 滚动查看更多结果
playwright-cli --s=chrome mousewheel 0 500

# 提取供应商列表信息
# 关键数据：
# - 产品名称
# - 价格（¥）
# - 销量
# - 回头率
# - 入驻年限
# - 商家名称
```

### 步骤 6：对比分析并生成报告

将 1688 供应商与 Ozon 产品进行对比：

| 对比项 | Ozon | 1688 | 匹配度 |
|--------|------|------|--------|
| 产品类型 | | | |
| 材质 | | | |
| 包含配件 | | | |
| 尺寸规格 | | | |
| 颜色选项 | | | |
| 价格 | | | |

---

## 1688 以图搜图结果提取要点

搜索结果页面中，每个产品卡片包含：

```
- 产品名称（如：木制儿童仿真布袋医药箱...）
- 材质（玩具材质:木）
- 功能类型（特色功能:角色扮演）
- 价格（¥39）
- 起批量（1件起批）
- 销量（1.8万+件）
- 回头率（49%）
- 商家入驻年限（入驻11年）
- 商家名称（云和县雅晨玩具厂）
```

---

## 输出格式

完成调研后，输出以下格式的报告：

```markdown
## 产品对比报告

### Ozon产品
- URL: [链接]
- 名称: [俄语产品名]
- 品牌: MamaZaToy
- 价格: X,XXX ₽ (≈ ¥XXX)
- 评分: ⭐ X.X / X,XXX 评论
- 月销量: ~XXX 件
- 重量: XXX g
- 尺寸: XXX×XXX×XXXmm
- 颜色选项: 白色、蓝色等 X 种

### 1688同款供应商推荐

#### 🥇 推荐供应商 1：[商家名称]
| 项目 | 信息 |
|------|------|
| 1688链接 | https://detail.1688.com/offer/XXXXXXXX.html |
| 产品名称 | [中文名] |
| 材质 | 木质 |
| 单价 | ¥XX（首单减X元）|
| 销量 | X万+件 |
| 回头率 | XX% |
| 入驻年限 | X年老店 |
| 特色 | [促销信息] |

匹配度：⭐⭐⭐⭐⭐

#### 🥈 推荐供应商 2：[商家名称]
...

### 匹配分析

| 对比项 | Ozon | 1688 | 匹配度 |
|--------|------|------|--------|
| 产品类型 | 医生玩具套装 | 医药箱套装 | ✅ |
| 材质 | 木材 | 木材 | ✅ |
| 包含配件 | 医生包+医生服+听诊器 | 需确认 | 待确认 |

### 利润测算

| 项目 | 金额 |
|------|------|
| Ozon售价 | X,XXX ₽ |
| Ozon佣金(~9%) | -XXX ₽ |
| 物流费(FBO) | -XXX ₽ |
| 实际到账 | ~XXX ₽ (≈¥XXX) |
| 1688采购价 | ¥XX |
| 净利润 | ~¥XX/件 |
| 利润率 | 约 XX% |

### 建议

1. **优先联系**：[供应商名称] - X年老店、X万+件销量、XX%回头率
2. **索取样品**：确认产品质量和配件内容
3. **对比尺寸**：联系卖家确认包装尺寸是否匹配
4. **确认款式**：确认是否包含医生包和医生服装套装
```

---

## 完整命令示例

```bash
# 1. 连接 Chrome 并打开 Ozon 产品页
playwright-cli attach --cdp=chrome
playwright-cli --s=chrome open "https://www.ozon.ru/product/detskiy-derevyannyy-igrovoy-nabor-igraem-v-doktora-v-sumochke-i-kostyumom-doktora-nabor-631094897/"

# 2. 提取产品图片 URL
playwright-cli --s=chrome eval "el => JSON.stringify([...document.querySelectorAll('img[src*=\"multimedia\"]')].map(img => img.src.replace('/wc50/', '/wc1000/')).filter((v, i, a) => a.indexOf(v) === i).slice(0, 3))"

# 3. 用图片 URL 在 1688 以图搜图
playwright-cli --s=chrome open "https://air.1688.com/kapp/1688-search/pc-image-search/?tab=imageSearch&imageAddress=https%3A%2F%2Fir-21.ozonru.cn%2Fs3%2Fmultimedia-b%2Fwc1000%2F6827910059.jpg"
sleep 8
playwright-cli --s=chrome snapshot

# 4. 滚动查看更多结果
playwright-cli --s=chrome mousewheel 0 500
playwright-cli --s=chrome snapshot
```

---

## 注意事项

### 防反爬策略

1. **Ozon 反爬**：
   - 可能触发 "Antibot Captcha" 页面，请手动验证
   - 页面显示" нет соединения"时，尝试刷新或等待后重试

2. **1688 反爬**：
   - 图片搜索可能需要等待几秒加载
   - 产品详情页需要登录才能查看
   - 可能触发滑块验证码

### 浏览器连接

```bash
# 推荐：使用已登录 1688 的 Chrome
playwright-cli attach --cdp=chrome

# 查看当前标签页
playwright-cli --s=chrome tab-list

# 切换标签页
playwright-cli --s=chrome tab-select 0

# 关闭标签页
playwright-cli --s=chrome tab-close 1

# 在新标签页打开链接
playwright-cli --s=chrome tab-new "https://..."
```

### 登录处理

- **推荐使用 Chrome 远程调试**：已有 1688 登录状态
- 新浏览器会话需要手动登录
- 登录信息只在当前会话有效

### 图片 URL 提取技巧

Ozon 图片 URL 格式：
```
https://ir-21.ozonru.cn/s3/multimedia-1-5/wc50/9646501289.jpg
                                 └─ 变更这里改尺寸
https://ir-21.ozonru.cn/s3/multimedia-1-5/wc1000/9646501289.jpg
```

常用尺寸：
- `wc50` - 缩略图
- `wc100` - 小图
- `wc500` - 中图
- `wc1000` - 大图（推荐用于以图搜图）

---

## 常见问题

**Q: 1688 需要登录怎么办？**
A: 使用已登录的 Chrome 会话 `playwright-cli attach --cdp=chrome`，或在当前会话手动登录。

**Q: 以图搜图找不到完全匹配的产品？**
A: 可以尝试：
1. 尝试产品的不同角度图片（Ozon 页面有多张图片）
2. 在搜索结果中筛选同款或相似款
3. 联系 1688 卖家确认是否有相同款式
4. 使用关键词组合搜索

**Q: 如何确定 Ozon 产品对应 1688 哪个 SKU？**
A:
1. 对比产品主图的颜色和外观
2. 查看 Ozon 描述中的功能特性
3. 检查 1688 的 SKU 颜色选项
4. 确认包含配件是否一致（医生包、医生服等）
5. 如仍无法确定，联系 1688 卖家确认

**Q: 利润如何计算？**
A:
```
Ozon售价(₽) × 0.88(扣佣金) - 物流费(₽) = 实际到账(₽)
实际到账(₽) × 0.0887(汇率) - 1688采购价(¥) = 净利润(¥)
```

---

## 前置要求

1. **Chrome 浏览器已开启远程调试**（推荐，已登录1688）
   - macOS: `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222 &`
   - Windows: `"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222`

2. 安装 playwright-cli:
   ```bash
   npm install -g @playwright/cli@latest
   ```

3. 下载 Playwright 浏览器支持（如需要）
   ```bash
   playwright install
   ```
