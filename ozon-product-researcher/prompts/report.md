# 报告生成提示词

## 用于生成 Ozon 选品分析报告

### 输入数据格式

```json
{
  "research_info": {
    "category": "儿童玩具",
    "price_min": 1500,
    "price_max": 3000,
    "country": "China",
    "date": "2026-07-06"
  },
  "products": [
    {
      "name": "磁性钓鱼玩具",
      "price": 1723,
      "original_price": 3000,
      "reviews": 5666,
      "rating": 4.9,
      "discount": "42%",
      "url": "https://www.ozon.ru/product/...",
      "seller": "Ozon"
    }
  ],
  "competitors": {
    "total_results": 50,
    "top_sellers": ["Ozon", "Яндекс Фабрика", "EveryToys"]
  }
}
```

### 输出模板

生成一份完整的 Ozon 选品分析报告，包含以下部分：

1. **执行摘要** - 关键发现和建议
2. **筛选条件** - 研究参数
3. **市场概览** - 数据统计
4. **头部商品** - TOP 10 商品分析
5. **利润分析** - 各品类利润估算
6. **蓝海机会** - 竞争度分析和推荐
7. **风险提示** - 认证要求和竞争风险
8. **选品建议** - 具体行动建议
9. **商品链接** - 达标商品汇总

### 格式要求

- 使用 Markdown 格式
- 包含表格展示数据
- 使用 emoji 增强可读性
- 价格使用 ₽ 符号
- 链接不带追踪参数（去掉 ?at=... 部分）
