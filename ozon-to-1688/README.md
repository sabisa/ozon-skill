# Ozon to 1688 以图搜图

通过 Ozon 商品链接，使用 1688 以图搜图功能找到对应的 1688 供应商。

## 使用方式

```
/ozon-to-1688 <Ozon商品链接>
```

或直接提供 Ozon 商品链接，我会自动执行以图搜图。

## 示例

```
/ozon-to-1688 https://www.ozon.ru/product/detskiy-derevyannyy-igrovoy-nabor-igraem-v-doktora-v-sumochke-i-kostyumom-doktora-nabor-631094897/
```

## 工作流程

1. 连接已登录 1688 的 Chrome 浏览器
2. 打开 Ozon 商品页，提取产品主图 URL
3. 用图片 URL 在 1688 以图搜图
4. 分析搜索结果，筛选最匹配的供应商
5. 生成对比报告（含利润测算）

## 前置要求

1. **Chrome 浏览器已开启远程调试**（推荐，已登录1688）
   ```bash
   playwright-cli attach --cdp=chrome
   ```

2. 或启动新浏览器
   ```bash
   playwright-cli open
   ```

详细文档请查看 [SKILL.md](SKILL.md)
